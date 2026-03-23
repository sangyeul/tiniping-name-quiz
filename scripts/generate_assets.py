#!/usr/bin/env python3
"""전체 디자인 에셋 자동 생성 v3
- 1024x1024 생성 → 비율 크롭 → 정확한 사이즈 리사이즈
- 실제 티니핑 원본 참고 이미지 첨부
- 너비 비율 기준 폰트 사이즈
- 이모지/특수문자 없는 문구
"""
import io
import os
import sys
import time
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
OUT.mkdir(parents=True, exist_ok=True)

API_KEY = None
for line in (PROJECT / ".env").read_text().splitlines():
    if line.startswith("GOOGLE_AI_API_KEY="):
        API_KEY = line.split("=", 1)[1].strip()
client = genai.Client(api_key=API_KEY)

F_BOLD = str(FONTS / "Pretendard-Bold.otf")
F_REGULAR = str(FONTS / "Pretendard-Regular.otf")
REF_FILES = [REFS / "heartsping.png", REFS / "dadaping.png", REFS / "graceping.png"]

REF_INTRO = (
    "These attached images are the EXACT Tiniping characters: "
    "Heartsping (하츄핑, pink hair with heart), Dadaping (바로핑, blue), Graceping (사뿐핑, purple/elegant). "
    "You MUST use these exact character designs — do not create different characters.\n\n"
)

QUALITY = (
    "Quality: 4K resolution feel, smooth gradient with fine noise texture, "
    "soft volumetric backlight, gentle bokeh, premium quality.\n\n"
)

STRICT = (
    "STRICT: No text, no letters, no words, no numbers, no symbols, no watermarks anywhere. "
    "No dark areas, no black, no borders, no margins. No stars, no sparkles. "
    "Background must fill entire canvas edge-to-edge. "
    "Characters must match the Tiniping reference images exactly."
)


def load_refs():
    parts = []
    for f in REF_FILES:
        if f.exists():
            parts.append(types.Part.from_bytes(data=f.read_bytes(), mime_type="image/png"))
    return parts


def generate(prompt, with_refs=True):
    full = REF_INTRO + prompt + "\n\n" + QUALITY + STRICT
    try:
        if with_refs:
            refs = load_refs()
            contents = [types.Content(parts=refs + [types.Part(text=full)])]
        else:
            contents = full
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
        print(f"    API error: {e}")
    return None


def crop_to_ratio(img, target_w, target_h):
    """중앙 크롭 → 정확한 사이즈 리사이즈"""
    target_ratio = target_w / target_h
    src_w, src_h = img.size
    src_ratio = src_w / src_h
    if src_ratio < target_ratio:
        new_h = int(src_w / target_ratio)
        top = (src_h - new_h) // 2
        img = img.crop((0, top, src_w, top + new_h))
    else:
        new_w = int(src_h * target_ratio)
        left = (src_w - new_w) // 2
        img = img.crop((left, 0, left + new_w, src_h))
    return img.resize((target_w, target_h), Image.LANCZOS)


def text(img, msg, x, y, font, size, color, anchor="mt", shadow=None):
    d = ImageDraw.Draw(img)
    f = ImageFont.truetype(font, size)
    if shadow:
        d.text((x + 3, y + 3), msg, font=f, fill=shadow, anchor=anchor)
    d.text((x, y), msg, font=f, fill=color, anchor=anchor)


def add_logo(img):
    if not LOGO_PATH.exists(): return
    lo = Image.open(LOGO_PATH).convert("RGBA")
    s = int(img.width * 0.09)
    lo = lo.resize((s, s), Image.LANCZOS)
    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, s-1, s-1], radius=s//5, fill=255)
    lo.putalpha(mask)
    m = int(img.width * 0.04)
    img.paste(lo, (m, m), lo)


def add_cta(img):
    if not BADGE_PATH.exists(): return
    b = Image.open(BADGE_PATH).convert("RGBA")
    bw = int(img.width * 0.25)
    bh = int(bw * b.height / b.width)
    b = b.resize((bw, bh), Image.LANCZOS)
    m = int(img.width * 0.04)
    img.paste(b, (img.width - bw - m, img.height - bh - m), b)


# ============================================================
def do_splash():
    """2. 스플래시 (1080×1920, 9:16)"""
    print("\n[2] 스플래시 (1080x1920)")
    prompt = (
        "Create a SQUARE image (will be cropped to portrait later).\n"
        "Composition — designed for CENTER-VERTICAL cropping:\n"
        "- Soft pink (#FFF0F5) background filling entire canvas.\n"
        "- CENTER: Three Tiniping characters (Heartsping, Dadaping, Graceping from references) "
        "clustered together, gaussian-blurred softly. Behind them a radial glow of pink (#FF4B8B).\n"
        "- BELOW characters: three colorful square tile blocks (pink, blue, purple) in a row, "
        "rounded corners, subtle drop shadow.\n"
        "- Two small white '?' marks floating near the characters.\n"
        "- BOTTOM HALF: generous clean empty space for text overlay.\n"
        "- Characters must be positioned in the UPPER-CENTER, not filling the whole canvas."
    )
    img = generate(prompt)
    if not img: print("  FAILED"); return
    img = crop_to_ratio(img, 1080, 1920)
    ms = int(1080 * 0.050)  # 54px
    ss = int(1080 * 0.025)  # 27px
    text(img, "티니핑 이름맞추기", 540, 1200, F_BOLD, ms, "#FF4B8B")
    text(img, "이 티니핑 이름, 맞출 수 있어?", 540, 1280, F_REGULAR, ss, "#B47AEA")
    img.save(str(OUT / "02_splash.png"), quality=95)
    print(f"  OK 02_splash.png")


def do_store_main():
    """3. 앱스토어 메인 (1024×500, ~2:1)"""
    print("\n[3] 앱스토어 메인 (1024x500)")
    prompt = (
        "Create a SQUARE image (will be cropped to wide landscape later).\n"
        "Composition — designed for CENTER-HORIZONTAL cropping:\n"
        "- Gradient from vivid pink at left to sky blue at right, filling entire canvas.\n"
        "- LEFT 35%: Three Tiniping characters (from references) clustered, "
        "gaussian-blurred, pastel tones. Characters vertically centered.\n"
        "- Two white '?' marks near characters.\n"
        "- RIGHT 65%: completely empty clean space for text overlay."
    )
    img = generate(prompt)
    if not img: print("  FAILED"); return
    img = crop_to_ratio(img, 1024, 500)
    ms = int(1024 * 0.055)
    ss = int(1024 * 0.025)
    text(img, "하츄핑? 바로핑? 사뿐핑?", 700, 160, F_BOLD, ms, "#FFFFFF", shadow="#B47AEA")
    text(img, "블러 보고 맞추는 140마리 캐릭터 퀴즈", 700, 240, F_REGULAR, ss, "#FFFFFFCC")
    add_logo(img); add_cta(img)
    img.save(str(OUT / "03_store_main.png"), quality=95)
    print(f"  OK 03_store_main.png")


def do_square():
    """5. 정사각형 (1200×1200, 1:1)"""
    print("\n[5] 정사각형 (1200x1200)")
    prompt = (
        "Create a SQUARE image, 1:1 aspect ratio.\n"
        "- Soft pink (#FFF0F5) background filling entire canvas.\n"
        "- CENTER: Three Tiniping characters (from references) in triangular arrangement, "
        "gaussian-blurred to create mystery. Behind them a circular glow of pink.\n"
        "- Three white '?' marks scattered around characters.\n"
        "- TOP 20% and BOTTOM 25%: clean empty space for text overlay.\n"
        "- Characters occupy about 40% of canvas height, vertically centered."
    )
    img = generate(prompt)
    if not img: print("  FAILED"); return
    img = crop_to_ratio(img, 1200, 1200)
    ms = int(1200 * 0.050)
    ss = int(1200 * 0.025)
    text(img, "하츄핑? 바로핑? 너 진짜 다 알아?", 600, 130, F_BOLD, ms, "#FF4B8B")
    text(img, "블러 보고 이름 맞추기 — 140마리 도전!", 600, 1070, F_REGULAR, ss, "#B47AEA")
    add_logo(img); add_cta(img)
    img.save(str(OUT / "05_square.png"), quality=95)
    print(f"  OK 05_square.png")


def do_poster():
    """6. 세로 포스터형 (1200×1500, 4:5)"""
    print("\n[6] 세로 포스터형 (1200x1500)")
    prompt = (
        "Create a SQUARE image (will be cropped to 4:5 portrait later).\n"
        "Composition — designed for slight vertical cropping:\n"
        "- Gradient from soft pink at top to light sky blue at bottom, edge to edge.\n"
        "- UPPER 45%: Three Tiniping characters (from references) clustered, "
        "gaussian-blurred, pastel tones, dreamy mysterious group.\n"
        "- Three white '?' marks floating around.\n"
        "- CENTER to BOTTOM: generous clean empty space for text and CTA."
    )
    img = generate(prompt)
    if not img: print("  FAILED"); return
    img = crop_to_ratio(img, 1200, 1500)
    ms = int(1200 * 0.050)
    ss = int(1200 * 0.025)
    text(img, "하츄핑? 바로핑?", 600, 880, F_BOLD, ms, "#FF4B8B")
    text(img, "너 진짜 다 알아?", 600, 950, F_BOLD, ms, "#FF4B8B")
    text(img, "블러 보고 이름 맞추기 — 140마리 도전!", 600, 1040, F_REGULAR, ss, "#B47AEA")
    add_logo(img); add_cta(img)
    img.save(str(OUT / "06_poster_vertical.png"), quality=95)
    print(f"  OK 06_poster_vertical.png")


def do_story():
    """7. 스토리형 광고 3장 (1920×1080, 16:9)"""
    print("\n[7] 스토리형 광고 (1920x1080 x3)")
    stories = [
        {
            "name": "07_story_1_hook",
            "prompt": (
                "Create a SQUARE image (will be cropped to landscape later).\n"
                "Composition — designed for CENTER-HORIZONTAL cropping:\n"
                "- Soft pink background with pink radial glow at center.\n"
                "- CENTER: One Tiniping character (Heartsping) HEAVILY gaussian-blurred, "
                "completely unrecognizable — just a colorful mysterious blob.\n"
                "- A huge white '?' mark overlaid on the blurred character.\n"
                "- Mood: curious, intriguing — 'who is this?'\n"
                "- LEFT and RIGHT: clean space for text."
            ),
            "main": "이 캐릭터 누구게?",
            "sub": "블러 뒤에 숨은 티니핑을 맞춰봐!",
            "has_logo": False,
        },
        {
            "name": "07_story_2_action",
            "prompt": (
                "Create a SQUARE image (will be cropped to landscape later).\n"
                "Same pink background tone as previous.\n"
                "- LEFT-CENTER: Heartsping character, slightly less blurred — starting to reveal features.\n"
                "- RIGHT-CENTER: Three colorful letter tile blocks (white squares with pink/blue/purple borders) "
                "in a row, suggesting word puzzle.\n"
                "- Small '?' marks becoming smaller.\n"
                "- Mood: engaging, playful game action."
            ),
            "main": "글자를 조합해서 이름 완성!",
            "sub": "쉬움 - 보통 - 어려움, 3단계 도전",
            "has_logo": False,
        },
        {
            "name": "07_story_3_result",
            "prompt": (
                "Create a SQUARE image (will be cropped to landscape later).\n"
                "Same pink background tone.\n"
                "- CENTER: Heartsping character FULLY REVEALED — clear, vibrant, cute, NO blur. "
                "Happy expression, wings spread.\n"
                "- Gold confetti particles and celebration elements around.\n"
                "- Mood: triumphant, celebratory, satisfying.\n"
                "- LEFT and RIGHT: clean space for text, logo, CTA."
            ),
            "main": "축하해! 티니핑 박사!",
            "sub": "지금 다운로드하고 도전하기",
            "has_logo": True,
        },
    ]

    for i, s in enumerate(stories):
        print(f"  [{i+1}/3] {s['name']}...")
        img = generate(s["prompt"])
        if not img: print("    FAILED"); continue
        img = crop_to_ratio(img, 1920, 1080)
        ms = int(1920 * 0.035)  # 67px
        ss = int(1920 * 0.020)  # 38px
        text(img, s["main"], 960, 80, F_BOLD, ms, "#FFFFFF", shadow="#FF4B8B")
        text(img, s["sub"], 960, 1000, F_REGULAR, ss, "#FFFFFFCC")
        if s["has_logo"]:
            add_logo(img); add_cta(img)
        img.save(str(OUT / f"{s['name']}.png"), quality=95)
        print(f"    OK {s['name']}.png")
        time.sleep(4)


def main():
    print("=== 전체 에셋 생성 v3 ===")
    if not LOGO_PATH.exists():
        sys.exit("로고 없음")

    do_splash();      time.sleep(4)
    do_store_main();   time.sleep(4)
    # 4번(가로 배너)는 이미 생성 완료
    do_square();       time.sleep(4)
    do_poster();       time.sleep(4)
    do_story()

    files = sorted(OUT.glob("*.png"))
    print(f"\n{'='*50}")
    print(f"결과: {len(files)}장")
    for f in files:
        im = Image.open(f)
        print(f"  {f.name} ({im.width}x{im.height})")
    print(f"{'='*50}")


if __name__ == "__main__":
    main()
