#!/usr/bin/env python3
"""앱 아이콘(로고) 후보 생성 — 티니핑 3캐릭터 블러 + "?" 3개"""
import os
import sys
from pathlib import Path
from PIL import Image, ImageFilter
from google import genai
from google.genai import types

# 경로 설정
PROJECT_ROOT = Path(__file__).parent.parent
OUTPUT_DIR = PROJECT_ROOT / "design_asset" / "raw" / "manual"
ASSETS_DIR = PROJECT_ROOT / "assets" / "images" / "tiniping"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# API 키
API_KEY = None
env_file = PROJECT_ROOT / ".env"
if env_file.exists():
    for line in env_file.read_text().splitlines():
        if line.startswith("GOOGLE_AI_API_KEY="):
            API_KEY = line.split("=", 1)[1].strip()
            break
API_KEY = os.environ.get("GOOGLE_AI_API_KEY", API_KEY)

if not API_KEY:
    print("ERROR: GOOGLE_AI_API_KEY not found")
    sys.exit(1)

client = genai.Client(api_key=API_KEY)

# 대표 캐릭터 블러 이미지 (참고용 첨부)
CHAR_FILES = [
    ASSETS_DIR / "heartsping_blur.webp",   # 하츄핑
    ASSETS_DIR / "dadaping_blur.webp",     # 바로핑
    ASSETS_DIR / "graceping_blur.webp",    # 사뿐핑
]

PROMPT = """Generate an app icon image. 1:1 square, 1024x1024 pixels.

BACKGROUND: Smooth diagonal gradient filling the ENTIRE canvas edge-to-edge. Pink at top-left transitioning to light blue at bottom-right. The gradient must cover every single pixel — no black areas, no transparent corners, no margins whatsoever.

CHARACTERS: Place THREE small cute fairy characters (similar style to the attached reference images) in the center area, arranged in a triangular formation. The characters should be gaussian-blurred so their details are obscured — they look mysterious and unrecognizable, as if the player needs to guess who they are. Each character is about 25-30% of the icon width.

QUESTION MARKS: Three white "?" marks (each about 12% of icon size), scattered around the characters — one floating above, one to the lower-left, one to the lower-right. Each "?" has a subtle purple shadow.

STYLE: Kawaii, child-friendly, pastel colors. No text, no letters, no words, no color codes. No stars, no sparkles. Clean and simple — only the blurred characters and question marks on the gradient background."""

NEGATIVE = """No text, no letters, no words, no hex codes. No stars, no sparkles, no decorative elements. No black areas, no black corners, no borders, no margins — gradient must fill entire canvas. No realistic style. No dark colors."""


def load_reference_images():
    """참고용 캐릭터 이미지 로딩"""
    images = []
    for path in CHAR_FILES:
        if path.exists():
            images.append(
                types.Part.from_bytes(data=path.read_bytes(), mime_type="image/webp")
            )
            print(f"  📎 첨부: {path.name}")
        else:
            print(f"  ⚠️ 없음: {path.name}")
    return images


def generate_icon(model_name, prefix, count=1):
    """이미지 생성"""
    ref_images = load_reference_images()

    for i in range(count):
        try:
            if "imagen" in model_name:
                # Imagen 4는 이미지 첨부 불가 — 프롬프트만
                response = client.models.generate_images(
                    model=model_name,
                    prompt=PROMPT + "\n\n" + NEGATIVE,
                    config=types.GenerateImagesConfig(
                        number_of_images=1,
                        aspect_ratio="1:1",
                    ),
                )
                if response.generated_images:
                    img = response.generated_images[0]
                    filename = f"icon_{prefix}_v{i+1}.png"
                    filepath = OUTPUT_DIR / filename
                    img.image.save(str(filepath))
                    print(f"  ✅ {filename} 저장 완료")
                else:
                    print(f"  ❌ v{i+1} 생성 실패")
            else:
                # Nano Banana — 참고 이미지 첨부 가능
                text_part = types.Part(text=(
                    "Here are reference images of the fairy characters (Tiniping). "
                    "Use similar cute fairy style but blur them in the icon. "
                    "Now generate the app icon:\n\n" + PROMPT + "\n\n" + NEGATIVE
                ))
                contents = [types.Content(parts=ref_images + [text_part])]
                response = client.models.generate_content(
                    model=model_name,
                    contents=contents,
                    config=types.GenerateContentConfig(
                        response_modalities=["IMAGE", "TEXT"],
                    ),
                )
                saved = False
                if response.candidates:
                    for part in response.candidates[0].content.parts:
                        if part.inline_data and part.inline_data.mime_type.startswith("image/"):
                            filename = f"icon_{prefix}_v{i+1}.png"
                            filepath = OUTPUT_DIR / filename
                            filepath.write_bytes(part.inline_data.data)
                            print(f"  ✅ {filename} 저장 완료")
                            saved = True
                            break
                if not saved:
                    print(f"  ❌ v{i+1} 이미지 없음")
        except Exception as e:
            print(f"  ❌ v{i+1} 에러: {e}")


def fix_corners(filepath):
    """검은 라운드 코너를 그라데이션 배경으로 채우기"""
    img = Image.open(filepath).convert("RGBA")
    w, h = img.size

    # 모서리 픽셀 분석 — 검은색/투명이면 수정 필요
    corners = [img.getpixel((2, 2)), img.getpixel((w-3, 2)),
               img.getpixel((2, h-3)), img.getpixel((w-3, h-3))]

    needs_fix = any(
        (p[3] < 128) or (p[0] < 30 and p[1] < 30 and p[2] < 30)
        for p in corners
    )

    if not needs_fix:
        print(f"  ⏭️ {filepath.name} 코너 OK")
        return

    # 그라데이션 배경 생성 (핫핑크 → 스카이블루)
    bg = Image.new("RGBA", (w, h))
    for y in range(h):
        for x in range(w):
            ratio = (x + y) / (w + h)
            r = int(255 * (1 - ratio) + 126 * ratio)
            g = int(75 * (1 - ratio) + 200 * ratio)
            b = int(139 * (1 - ratio) + 227 * ratio)
            bg.putpixel((x, y), (r, g, b, 255))

    # 원본을 배경 위에 합성
    bg.paste(img, (0, 0), img)
    bg.convert("RGB").save(filepath)
    print(f"  🔧 {filepath.name} 코너 수정 완료")


def main():
    print("🎨 티니핑 이름맞추기 — 로고 후보 생성 (v2)")
    print(f"📁 저장 위치: {OUTPUT_DIR}\n")

    # 기존 파일 삭제
    for f in OUTPUT_DIR.glob("icon_*.png"):
        f.unlink()

    # Nano Banana — 참고 이미지 첨부 가능 (2장)
    print("=== Nano Banana + 참고 이미지 (2장) ===")
    generate_icon("gemini-2.5-flash-image", "nano", count=2)

    # 코너 후처리
    print("\n=== 코너 후처리 ===")
    for f in sorted(OUTPUT_DIR.glob("icon_*.png")):
        fix_corners(f)

    # 결과
    files = list(OUTPUT_DIR.glob("icon_*.png"))
    print(f"\n📊 결과: {len(files)}장 생성")
    for f in sorted(files):
        size_kb = f.stat().st_size / 1024
        print(f"  📄 {f.name} ({size_kb:.0f}KB)")

    print(f"\n👀 후보를 확인하고 컨펌해주세요!")


if __name__ == "__main__":
    main()
