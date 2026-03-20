#!/usr/bin/env python3
"""
Tiniping Character Collector
Fandom MediaWiki API에서 캐치! 티니핑 캐릭터 데이터를 수집하고
3종 가공 이미지(blur, mosaic, silhouette)를 생성합니다.
"""

import requests
import json
import time
import os
import re
import io
from pathlib import Path
from PIL import Image, ImageFilter

# ── 설정 ──────────────────────────────────────────────
BASE_URL = "https://catchteenieping.fandom.com/api.php"
HEADERS = {"User-Agent": "TinipingQuiz/1.0 (educational fan project)"}
RATE_LIMIT_SEC = 2  # Fandom 실제 제한은 넉넉함, 2초면 안전
IMAGE_SIZE = 400

PROJECT_ROOT = Path(__file__).parent.parent
ASSETS_DIR = PROJECT_ROOT / "assets"
IMAGES_DIR = ASSETS_DIR / "images" / "tiniping"
DATA_DIR = ASSETS_DIR / "data"

# 시즌별 카테고리 매핑
SEASON_CATEGORIES = {
    "Category:Emotion Teeniepings": {"season": 1, "category": "emotion"},
    "Category:Jewel Teeniepings": {"season": 2, "category": "jewel"},
    "Category:Key Teeniepings": {"season": 3, "category": "key"},
    "Category:Dessert Teeniepings": {"season": 4, "category": "dessert"},
    "Category:Star Teeniepings": {"season": 5, "category": "star"},
    "Category:Princess Teeniepings": {"season": 6, "category": "princess"},
}

# Royal / Legend 캐릭터 (수동 매핑)
ROYAL_NAMES = {
    "Heartsping", "Correctping", "Tryping", "Chachaping", "Lalaping", "Happying",
    "Loveping", "Joyping", "Trustping",
    "Floraping", "Curioping", "Nanaping", "Honestping",
    "Berryping", "Fluffyping", "Softping", "Shashaping",
    "Starping", "Shineping", "Glowping", "Sparkleping", "Princeping",
    "Graceping", "Beautiping", "Ponyping",
}

LEGEND_NAMES = {
    "Luckyping", "Sweetping", "Sourping", "Auroraping",
    "Dianaping", "Eclipseping",
}


def api_query(params):
    """MediaWiki API 쿼리 실행"""
    params["format"] = "json"
    r = requests.get(BASE_URL, params=params, headers=HEADERS, timeout=30)
    r.raise_for_status()
    return r.json()


def get_category_members(category):
    """카테고리의 모든 멤버 페이지 가져오기"""
    members = []
    params = {
        "action": "query",
        "list": "categorymembers",
        "cmtitle": category,
        "cmlimit": "500",
        "cmtype": "page",
    }
    while True:
        data = api_query(params)
        members.extend(data.get("query", {}).get("categorymembers", []))
        cont = data.get("continue")
        if cont:
            params["cmcontinue"] = cont["cmcontinue"]
        else:
            break
        time.sleep(RATE_LIMIT_SEC)
    return members


def get_page_images(title):
    """페이지의 이미지 목록 가져오기"""
    data = api_query({
        "action": "query",
        "titles": title,
        "prop": "images",
        "imlimit": "50",
    })
    pages = data.get("query", {}).get("pages", {})
    for pid, page in pages.items():
        return page.get("images", [])
    return []


def get_image_url(file_title):
    """이미지 파일의 실제 URL 가져오기"""
    data = api_query({
        "action": "query",
        "titles": file_title,
        "prop": "imageinfo",
        "iiprop": "url",
    })
    pages = data.get("query", {}).get("pages", {})
    for pid, page in pages.items():
        ii = page.get("imageinfo", [])
        if ii:
            return ii[0].get("url")
    return None


def find_best_image(title, images):
    """캐릭터 페이지에서 가장 적합한 이미지 선택"""
    # Render 이미지를 우선 찾기
    render_imgs = []
    for img in images:
        img_title = img.get("title", "")
        lower = img_title.lower()
        # 배제: 플래그, 갤러리, 아이콘, 배너 등
        if any(skip in lower for skip in ["flag", "gallery", "icon", "banner", "logo", "cover", "season", "episode"]):
            continue
        # Render 이미지 우선
        if "render" in lower:
            render_imgs.append(img_title)
        # 캐릭터명이 포함된 이미지
        elif title.lower().replace(" ", "") in lower.replace(" ", "").replace("_", ""):
            render_imgs.append(img_title)

    if render_imgs:
        # "Render 1" 우선
        for r in render_imgs:
            if "render 1" in r.lower() or "render_1" in r.lower():
                return r
        return render_imgs[0]

    # 못 찾으면 첫 번째 png/webp
    for img in images:
        t = img.get("title", "").lower()
        if t.endswith(".png") or t.endswith(".webp"):
            if not any(skip in t for skip in ["flag", "gallery", "icon", "banner", "logo", "cover"]):
                return img.get("title")
    return None


def download_image(url):
    """이미지 다운로드 → PIL Image 반환"""
    r = requests.get(url, headers=HEADERS, timeout=30)
    r.raise_for_status()
    return Image.open(io.BytesIO(r.content)).convert("RGBA")


def process_image(img, char_id):
    """원본 이미지 → 400x400 리사이즈 → 3종 가공 이미지 생성"""
    # 리사이즈 (비율 유지)
    img.thumbnail((IMAGE_SIZE, IMAGE_SIZE), Image.LANCZOS)

    # 흰색 배경에 중앙 배치
    bg = Image.new("RGBA", (IMAGE_SIZE, IMAGE_SIZE), (255, 255, 255, 255))
    offset = ((IMAGE_SIZE - img.width) // 2, (IMAGE_SIZE - img.height) // 2)
    bg.paste(img, offset, img)
    rgb = bg.convert("RGB")

    # 1. 블러
    blur = rgb.filter(ImageFilter.GaussianBlur(radius=8))
    blur.save(IMAGES_DIR / f"{char_id}_blur.webp", "WEBP", quality=80)

    # 2. 모자이크
    small = rgb.resize((20, 20), Image.NEAREST)
    mosaic = small.resize((IMAGE_SIZE, IMAGE_SIZE), Image.NEAREST)
    mosaic.save(IMAGES_DIR / f"{char_id}_mosaic.webp", "WEBP", quality=80)

    # 3. 실루엣
    sil_bg = Image.new("RGBA", (IMAGE_SIZE, IMAGE_SIZE), (255, 255, 255, 255))
    sil = Image.new("RGBA", img.size, (255, 255, 255, 0))
    pixels = img.load()
    sil_pixels = sil.load()
    for x in range(img.width):
        for y in range(img.height):
            if pixels[x, y][3] > 30:
                sil_pixels[x, y] = (255, 107, 157, 255)
    sil_bg.paste(sil, offset, sil)
    sil_bg.convert("RGB").save(IMAGES_DIR / f"{char_id}_silhouette.webp", "WEBP", quality=80)

    return True


def title_to_id(title):
    """페이지 제목 → ID 변환"""
    return re.sub(r'[^a-z0-9]', '', title.lower())


def extract_korean_name(title):
    """영문명에서 한글명 유추 (실제로는 페이지에서 추출 필요)"""
    # 이 함수는 페이지 본문에서 한글명을 추출하는 것이 정확하지만
    # API 비용을 줄이기 위해 별도 매핑 파일 사용
    return None


def get_page_content(title):
    """페이지 본문에서 한글명 추출"""
    data = api_query({
        "action": "parse",
        "page": title,
        "prop": "wikitext",
        "section": "0",
    })
    wikitext = data.get("parse", {}).get("wikitext", {}).get("*", "")

    # 한글명 패턴 매칭 (|korean_name = 하츄핑 등)
    patterns = [
        r'korean[_ ]?name\s*=\s*(.+?)[\n|]',
        r'hangul\s*=\s*(.+?)[\n|]',
        r'한국어\s*=\s*(.+?)[\n|]',
        r'Korean:\s*(.+?)[\n<]',
    ]
    for pat in patterns:
        m = re.search(pat, wikitext, re.IGNORECASE)
        if m:
            name = m.group(1).strip()
            # 위키 마크업 제거
            name = re.sub(r'\[\[|\]\]|\{\{.*?\}\}', '', name).strip()
            if name and any('\uac00' <= c <= '\ud7a3' for c in name):
                return name

    # 본문에서 한글 이름 찾기 (첫 번째 한글 단어)
    korean_pattern = r'[\uac00-\ud7a3]{2,}'
    matches = re.findall(korean_pattern, wikitext[:500])
    # "핑"으로 끝나는 것 우선
    for m in matches:
        if m.endswith("핑"):
            return m
    return matches[0] if matches else None


def collect_all():
    """전체 수집 파이프라인"""
    IMAGES_DIR.mkdir(parents=True, exist_ok=True)
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    characters = []
    seen_ids = set()
    total_images = 0
    failed = []

    print("=" * 60)
    print("🎀 Tiniping Character Collector")
    print("=" * 60)

    for cat_name, cat_info in SEASON_CATEGORIES.items():
        season = cat_info["season"]
        category = cat_info["category"]

        print(f"\n📂 [{season}기] {category} 카테고리 수집 중...")
        time.sleep(RATE_LIMIT_SEC)

        members = get_category_members(cat_name)
        print(f"   → {len(members)}개 페이지 발견")

        for member in members:
            title = member.get("title", "")
            char_id = title_to_id(title)

            if char_id in seen_ids:
                continue
            seen_ids.add(char_id)

            print(f"   [{len(characters)+1}] {title}...", end=" ", flush=True)
            time.sleep(RATE_LIMIT_SEC)

            try:
                # 1. 한글명 추출
                korean_name = get_page_content(title)
                time.sleep(RATE_LIMIT_SEC)

                if not korean_name:
                    print("⚠️ 한글명 없음, 스킵")
                    failed.append({"title": title, "reason": "no korean name"})
                    continue

                # 2. 이미지 찾기
                images = get_page_images(title)
                time.sleep(RATE_LIMIT_SEC)

                best_img = find_best_image(title, images)
                if not best_img:
                    print(f"⚠️ 이미지 없음 ({korean_name})")
                    failed.append({"title": title, "reason": "no image"})
                    continue

                # 3. 이미지 URL
                img_url = get_image_url(best_img)
                time.sleep(RATE_LIMIT_SEC)

                if not img_url:
                    print(f"⚠️ URL 없음 ({korean_name})")
                    failed.append({"title": title, "reason": "no image url"})
                    continue

                # 4. 이미지 다운로드 + 가공
                img = download_image(img_url)
                process_image(img, char_id)
                total_images += 1

                # 5. 등급 결정
                grade = "normal"
                if title in ROYAL_NAMES:
                    grade = "royal"
                elif title in LEGEND_NAMES:
                    grade = "legend"

                char_data = {
                    "id": char_id,
                    "name": title,
                    "nameKo": korean_name,
                    "season": season,
                    "category": category,
                    "grade": grade,
                    "imageFile": f"{char_id}.webp",
                    "imageUrl": img_url,
                }
                characters.append(char_data)
                print(f"✅ {korean_name}")

            except Exception as e:
                print(f"❌ 에러: {e}")
                failed.append({"title": title, "reason": str(e)})

            # 중간 저장 (10개마다)
            if len(characters) % 10 == 0 and characters:
                tmp_path = DATA_DIR / "characters_partial.json"
                with open(tmp_path, "w", encoding="utf-8") as f:
                    json.dump(characters, f, ensure_ascii=False, indent=2)

    # JSON 저장
    output_path = DATA_DIR / "characters.json"
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(characters, f, ensure_ascii=False, indent=2)

    # 실패 목록 저장
    if failed:
        fail_path = DATA_DIR / "collect_failed.json"
        with open(fail_path, "w", encoding="utf-8") as f:
            json.dump(failed, f, ensure_ascii=False, indent=2)

    # 결과 리포트
    print("\n" + "=" * 60)
    print("📊 수집 결과")
    print("=" * 60)
    print(f"  총 캐릭터: {len(characters)}")
    print(f"  이미지 생성: {total_images} x 3종 = {total_images * 3}장")
    print(f"  실패: {len(failed)}")
    print(f"  JSON: {output_path}")

    # 시즌별 통계
    print("\n  시즌별:")
    for s in range(1, 7):
        count = len([c for c in characters if c["season"] == s])
        print(f"    {s}기: {count}마리")

    print("=" * 60)
    return characters


if __name__ == "__main__":
    collect_all()
