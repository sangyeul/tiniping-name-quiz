#!/usr/bin/env python3
"""Step 2 테스트: 비율 정확도 + 실제 티니핑 캐릭터 + 폰트 사이즈 개선"""
import io
import os
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
from google import genai
from google.genai import types

PROJECT = Path(__file__).parent.parent
OUT = PROJECT / "design_asset" / "raw" / "auto"
FONTS = PROJECT / "design_asset" / "fonts"
REFS = PROJECT / "design_asset" / "refs"
LOGO_PATH = PROJECT / "design_asset" / "raw" / "manual" / "icon_final.png"
BADGE_PATH = FONTS / "google_play_badge.png"

API_KEY = None
for line in (PROJECT / ".env").read_text().splitlines():
    if line.startswith("GOOGLE_AI_API_KEY="):
        API_KEY = line.split("=", 1)[1].strip()
client = genai.Client(api_key=API_KEY)

F_BOLD = str(FONTS / "Pretendard-Bold.otf")
F_REGULAR = str(FONTS / "Pretendard-Regular.otf")

# 실제 티니핑 원본 이미지 (블러가 아닌 선명한 원본)
REF_FILES = [REFS / "heartsping.png", REFS / "dadaping.png", REFS / "graceping.png"]


def load_refs():
    parts = []
    for f in REF_FILES:
        if f.exists():
            parts.append(types.Part.from_bytes(data=f.read_bytes(), mime_type="image/png"))
            print(f"  ref: {f.name}")
    return parts


def generate(prompt, refs=None):
    try:
        if refs:
            text_part = types.Part(text=prompt)
            contents = [types.Content(parts=refs + [text_part])]
        else:
            contents = prompt
        resp = client.models.generate_content(
            model="gemini-2.5-flash-image",
            contents=contents,
            config=types.GenerateContentConfig(response_modalities=["IMAGE", "TEXT"]),
        )
        if resp.candidates:
            for part in resp.candidates[0].content.parts:
                if part.inline_data and part.inline_data.mime_type.startswith("image/"):
                    return Image.open(io.BytesIO(part.inline_data.data)).convert("RGB")
    except Exception as e:
        print(f"  API error: {e}")
    return None


def text(img, msg, x, y, font, size, color, anchor="mt", shadow=None):
    d = ImageDraw.Draw(img)
    f = ImageFont.truetype(font, size)
    if shadow:
        d.text((x + 3, y + 3), msg, font=f, fill=shadow, anchor=anchor)
    d.text((x, y), msg, font=f, fill=color, anchor=anchor)


def logo(img):
    if not LOGO_PATH.exists(): return
    lo = Image.open(LOGO_PATH).convert("RGBA")
    s = int(img.width * 0.09)
    lo = lo.resize((s, s), Image.LANCZOS)
    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, s-1, s-1], radius=s//5, fill=255)
    lo.putalpha(mask)
    m = int(img.width * 0.04)
    img.paste(lo, (m, m), lo)


def cta(img):
    if not BADGE_PATH.exists(): return
    b = Image.open(BADGE_PATH).convert("RGBA")
    bw = int(img.width * 0.25)
    bh = int(bw * b.height / b.width)
    b = b.resize((bw, bh), Image.LANCZOS)
    m = int(img.width * 0.04)
    img.paste(b, (img.width - bw - m, img.height - bh - m), b)


def test_banner():
    """4번 가로 배너 테스트 (1200×628, 16:9)"""
    print("\n=== TEST: 가로 배너 (1200x628) ===")
    refs = load_refs()

    prompt = (
        "These attached images are the EXACT Tiniping characters to use: "
        "Heartsping (하츄핑, pink hair), Dadaping (바로핑, blue), Graceping (사뿐핑, purple). "
        "You MUST use these exact character designs.\n\n"
        "Create a SQUARE image (the image will be cropped to landscape later).\n\n"
        "Composition — designed for CENTER-HORIZONTAL cropping:\n"
        "- Place ONE Tiniping character (Heartsping from reference) in the LEFT-CENTER of the canvas, "
        "taking up about 40% width. Apply soft gaussian blur on the character. "
        "The character must be vertically centered — NOT at the top or bottom.\n"
        "- RIGHT 55%: completely empty clean space (for text overlay later).\n"
        "- Background: Smooth gradient from vivid pink at left to sky blue at right, "
        "filling entire canvas edge-to-edge.\n"
        "- Two small white '?' marks near the character.\n\n"
        "Quality: 4K resolution feel, smooth gradient with fine noise texture, "
        "soft volumetric backlight behind the character, gentle bokeh, premium quality.\n\n"
        "STRICT: No text, no letters, no words, no symbols anywhere. "
        "No dark areas, no black, no borders. No stars, no sparkles. "
        "Character must match the Tiniping reference exactly."
    )

    img = generate(prompt, refs)
    if not img:
        print("  FAILED"); return

    # 비율 보정: 원본에서 목표 비율로 중앙 크롭 후 리사이즈
    print(f"  생성 사이즈: {img.size}")
    target_ratio = 1200 / 628  # 1.91
    src_w, src_h = img.size
    src_ratio = src_w / src_h

    if src_ratio < target_ratio:
        # 세로가 길다 → 상하 크롭
        new_h = int(src_w / target_ratio)
        top = (src_h - new_h) // 2
        img = img.crop((0, top, src_w, top + new_h))
    else:
        # 가로가 길다 → 좌우 크롭
        new_w = int(src_h * target_ratio)
        left = (src_w - new_w) // 2
        img = img.crop((left, 0, left + new_w, src_h))

    img = img.resize((1200, 628), Image.LANCZOS)
    print(f"  크롭+리사이즈: {img.size}")

    # 폰트 사이즈: 너비의 5~6% = 60~72px (메인), 2.5~3% = 30~36px (서브)
    main_size = int(1200 * 0.055)  # 66px
    sub_size = int(1200 * 0.028)   # 34px

    text(img, "하츄핑? 바로핑?", 850, 200, F_BOLD, main_size, "#FFFFFF", shadow="#B47AEA")
    text(img, "너 진짜 다 알아?", 850, 280, F_BOLD, main_size, "#FFFFFF", shadow="#B47AEA")
    text(img, "블러 보고 이름 맞추기 — 140마리 도전!", 850, 370, F_REGULAR, sub_size, "#FFFFFFCC")

    logo(img)
    cta(img)

    path = OUT / "test_04_banner.png"
    img.save(str(path), quality=95)
    print(f"  저장: {path.name} ({img.width}x{img.height})")


if __name__ == "__main__":
    test_banner()
