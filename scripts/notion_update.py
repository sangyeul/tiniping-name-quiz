#!/usr/bin/env python3
"""Notion 페이지 재작성 — toggle heading_2 구조"""
import os
import requests
import json
import time

NOTION_TOKEN = os.environ["NOTION_TOKEN"]
PAGE_ID = "3291624703fe809a9934c873b1b3b3ef"
API = "https://api.notion.com/v1"
HEADERS = {
    "Authorization": f"Bearer {NOTION_TOKEN}",
    "Notion-Version": "2022-06-28",
    "Content-Type": "application/json; charset=utf-8",
}


def rich_text(text, bold=False, code=False, color="default", link=None):
    """Rich text element"""
    annotations = {
        "bold": bold, "italic": False, "strikethrough": False,
        "underline": False, "code": code, "color": color,
    }
    rt = {"type": "text", "text": {"content": text}, "annotations": annotations}
    if link:
        rt["text"]["link"] = {"url": link}
    return rt


def paragraph(texts):
    """Paragraph block from list of rich_text"""
    return {"object": "block", "type": "paragraph", "paragraph": {"rich_text": texts}}


def bullet(texts):
    """Bulleted list item"""
    return {"object": "block", "type": "bulleted_list_item",
            "bulleted_list_item": {"rich_text": texts}}


def divider():
    return {"object": "block", "type": "divider", "divider": {}}


def toggle_h2(title, children):
    """Toggle heading_2 with children"""
    return {
        "object": "block",
        "type": "heading_2",
        "heading_2": {
            "rich_text": [rich_text(title, bold=False)],
            "is_toggleable": True,
            "children": children,
        },
    }


def delete_all_blocks():
    """Delete all existing blocks on the page"""
    resp = requests.get(f"{API}/blocks/{PAGE_ID}/children?page_size=100", headers=HEADERS)
    blocks = resp.json().get("results", [])
    print(f"Deleting {len(blocks)} existing blocks...")
    for b in blocks:
        requests.delete(f"{API}/blocks/{b['id']}", headers=HEADERS)
    if blocks:
        time.sleep(0.5)


def append_blocks(blocks):
    """Append blocks to the page"""
    payload = json.dumps({"children": blocks}, ensure_ascii=False).encode("utf-8")
    resp = requests.patch(
        f"{API}/blocks/{PAGE_ID}/children",
        headers=HEADERS,
        data=payload,
    )
    if resp.status_code != 200:
        print(f"ERROR {resp.status_code}: {resp.text[:500]}")
        return False
    print(f"Appended {len(blocks)} blocks OK")
    return True


def build_prd_section():
    """PRD — 티니핑 이름맞추기 v1.1.0"""
    children = [
        paragraph([
            rich_text("Version: ", bold=True), rich_text("1.1.0  |  "),
            rich_text("Status: ", bold=True), rich_text("Development Complete (배포 준비 중)  |  "),
            rich_text("Platform: ", bold=True), rich_text("Android / iOS (Flutter)"),
        ]),
        divider(),
        paragraph([rich_text("제품 개요", bold=True)]),
        paragraph([
            rich_text("앱 이름: ", bold=True), rich_text("티니핑 이름맞추기\n"),
            rich_text("부제: ", bold=True), rich_text("하츄핑부터 사뿐핑까지! 캐릭터 퀴즈\n"),
            rich_text("태그라인: ", bold=True), rich_text('"이 티니핑 이름, 맞출 수 있어?"\n'),
            rich_text("패키지명: ", bold=True), rich_text("com.seomihye.tiniping_name_quiz", code=True),
        ]),
        paragraph([
            rich_text("캐치! 티니핑 6시즌 140마리 캐릭터를 블러/모자이크/실루엣 이미지로 보고, "
                       "글자를 조합하여 이름을 완성하는 퀴즈 앱. 4지선다보다 능동적인 음절 조합 방식으로 학습 효과와 재미를 극대화."),
        ]),
        divider(),
        paragraph([rich_text("핵심 가치 제안", bold=True)]),
        bullet([rich_text("능동적 참여: ", bold=True), rich_text("4지선다가 아닌 음절 조합으로 직접 이름 완성")]),
        bullet([rich_text("3단계 도전: ", bold=True), rich_text("블러 → 모자이크 → 실루엣, 같은 캐릭터도 3번 즐길 수 있음")]),
        bullet([rich_text("2가지 모드: ", bold=True), rich_text("이름 맞추기 + 이미지 맞추기 역퀴즈")]),
        bullet([rich_text("전시즌 수록: ", bold=True), rich_text("1기 감정~6기 프린세스까지 140마리 완전판")]),
        divider(),
        paragraph([rich_text("타깃 유저", bold=True)]),
        bullet([rich_text("Primary (60%): ", bold=True), rich_text("4~8세 아이 + 부모 — 캐릭터 이름 학습, 부모-아이 함께 놀기")]),
        bullet([rich_text("Secondary (25%): ", bold=True), rich_text("초등 저학년 (8~10세) — 혼자 퀴즈 도전, 점수 경쟁")]),
        bullet([rich_text("Tertiary (15%): ", bold=True), rich_text("티니핑 팬 (전연령) — 전 시즌 마스터 도전")]),
        divider(),
        paragraph([rich_text("기능 명세", bold=True)]),
        bullet([rich_text("홈 화면: ", bold=True), rich_text("시즌 선택(전체/1~6기 복수), 난이도(쉬움/보통/어려움), 문제 수(10/20/전체), 2가지 모드")]),
        bullet([rich_text("이름 맞추기: ", bold=True), rich_text("가공 이미지 보고 글자 타일 조합 → 자동 검증. 정답 글자 + 방해 글자(난이도별 2~5개)")]),
        bullet([rich_text("이미지 맞추기: ", bold=True), rich_text("이름 보고 4장 중 정답 이미지 고르기 (2x2 그리드, 다른 시즌 우선)")]),
        bullet([rich_text("타이머: ", bold=True), rich_text("10초 원형 카운트다운, 3초 이하 빨간색 경고")]),
        bullet([rich_text("힌트: ", bold=True), rich_text("보상형 광고 시청 → 3개 지급, 문제당 1회 (원본 이미지 상단 1/3 노출)")]),
        bullet([rich_text("결과 화면: ", bold=True), rich_text('점수 + 등급("티니핑 박사!" 등) + 오답 리뷰 + 다시하기')]),
        divider(),
        paragraph([rich_text("브랜드 전략", bold=True)]),
        paragraph([
            rich_text("페르소나: ", bold=True), rich_text('"티니핑을 전부 아는 동네 언니/오빠"\n'),
            rich_text("톤앤매너: ", bold=True), rich_text('반말(초등학생 친구 톤), "아깝다! 정답은 ○○핑이야"\n'),
            rich_text("금기: ", bold=True), rich_text('캐릭터 비하 금지, "틀렸어!" 대신 "아깝다!" 사용'),
        ]),
        divider(),
        paragraph([rich_text("컬러 팔레트", bold=True)]),
        bullet([rich_text("Primary: ", bold=True), rich_text("#FF4B8B", code=True), rich_text(" (핫핑크) — 공식 톤, 하츄핑 리본")]),
        bullet([rich_text("Secondary: ", bold=True), rich_text("#7EC8E3", code=True), rich_text(" (스카이블루)")]),
        bullet([rich_text("Accent: ", bold=True), rich_text("#B47AEA", code=True), rich_text(" (퍼플) — 별/마법")]),
        bullet([rich_text("Background: ", bold=True), rich_text("#FFF0F5", code=True), rich_text(" (소프트 핑크)")]),
        bullet([rich_text("Success/Error: ", bold=True), rich_text("#2ECC71", code=True), rich_text(" / "), rich_text("#E74C3C", code=True)]),
        bullet([rich_text("Star/Hint: ", bold=True), rich_text("#FFD700", code=True), rich_text(" (골드)")]),
        bullet([rich_text("Tile: ", bold=True), rich_text("#FFFFFF", code=True), rich_text(" (기본) / "), rich_text("#D8B4FE", code=True), rich_text(" (선택)")]),
        divider(),
        paragraph([rich_text("수익 모델", bold=True)]),
        bullet([rich_text("보상형 광고 (50%): ", bold=True), rich_text("힌트 획득 시 시청 → 3개 지급")]),
        bullet([rich_text("전면 광고 (30%): ", bold=True), rich_text("퀴즈 완료 → 결과 화면 전")]),
        bullet([rich_text("배너 광고 (20%): ", bold=True), rich_text("홈 화면 하단")]),
        bullet([rich_text("향후: ", bold=True), rich_text("인앱 구매 (광고 제거 팩, 프리미엄 힌트 팩)")]),
        divider(),
        paragraph([rich_text("이미지 전략 (저작권)", bold=True)]),
        paragraph([
            rich_text("퀴즈용 가공 이미지만 앱 번들 포함. 원본은 외부 URL(Fandom) 런타임 로딩.\n"),
            rich_text("앱 바이너리에 원본 미포함 → 스토어 심사/DMCA 리스크 최소화.\n"),
            rich_text('앱 내 "비공식 팬 프로젝트" + 이미지 출처 표기. COPPA 준수 (개인정보 수집 없음).'),
        ]),
        divider(),
        paragraph([rich_text("KPI (출시 후 30일)", bold=True)]),
        bullet([rich_text("다운로드 5,000+ / DAU 500+ / 세션당 퀴즈 2회+ / 평균 세션 3분+ / 평점 4.0+ / 보상형 광고 시청률 30%+")]),
        divider(),
        paragraph([rich_text("로드맵", bold=True)]),
        bullet([rich_text("Phase 2 (출시 후 2주): ", bold=True), rich_text("컬렉션 도감, 최고 점수 기록")]),
        bullet([rich_text("Phase 3 (출시 후 1개월): ", bold=True), rich_text("시즌 7+ 자동 업데이트, 인앱 구매")]),
    ]
    return toggle_h2("PRD — 티니핑 이름맞추기 v1.1.0", children)


def build_code_section():
    """코드 (github)"""
    children = [
        paragraph([
            rich_text("GitHub: ", bold=True),
            rich_text("https://github.com/sangyeul/tiniping-name-quiz",
                       link="https://github.com/sangyeul/tiniping-name-quiz"),
        ]),
        divider(),
        paragraph([rich_text("기술 스택", bold=True)]),
        bullet([rich_text("Framework: ", bold=True), rich_text("Flutter 3.41 + Dart 3.11")]),
        bullet([rich_text("State: ", bold=True), rich_text("Riverpod (Notifier)")]),
        bullet([rich_text("Data: ", bold=True), rich_text("로컬 JSON (assets) — 서버 불필요")]),
        bullet([rich_text("Image: ", bold=True), rich_text("WebP 400x400 (가공) + CachedNetworkImage (원본)")]),
        bullet([rich_text("Network: ", bold=True), rich_text("connectivity_plus (오프라인 알림)")]),
        bullet([rich_text("Ads: ", bold=True), rich_text("google_mobile_ads (AdMob 3종)")]),
        divider(),
        paragraph([rich_text("콘텐츠 데이터", bold=True)]),
        bullet([rich_text("캐릭터: ", bold=True), rich_text("140개 (6시즌)")]),
        bullet([rich_text("가공 이미지: ", bold=True), rich_text("432장 (140 × blur/mosaic/silhouette)")]),
        bullet([rich_text("시즌별: ", bold=True), rich_text("1기 45 / 2기 19 / 3기 20 / 4기 21 / 5기 23 / 6기 16")]),
    ]
    return toggle_h2("코드 (GitHub)", children)


def build_aso_section():
    """ASO"""
    children = [
        paragraph([
            rich_text("카테고리: ", bold=True), rich_text("퍼즐 (1차) / 교육 (2차)\n"),
            rich_text("앱 타이틀: ", bold=True), rich_text("티니핑 이름맞추기\n"),
            rich_text("부제: ", bold=True), rich_text("하츄핑부터 사뿐핑까지! 캐릭터 퀴즈"),
        ]),
        divider(),
        paragraph([rich_text("짧은 설명 (80자)", bold=True)]),
        paragraph([rich_text("140마리 티니핑! 이미지 보고 이름 맞춰봐. 전시즌 캐릭터 퀴즈")]),
        divider(),
        paragraph([rich_text("긴 설명", bold=True)]),
        paragraph([rich_text(
            "🎀 이 티니핑 이름, 맞출 수 있어?\n\n"
            "블러 처리된 이미지를 보고 이름을 맞춰봐!\n"
            "하츄핑, 바로핑, 사뿐핑... 6시즌 140마리 전부 수록!\n\n"
            "🎮 2가지 모드\n"
            "• 이름 맞추기 — 이미지 보고 글자를 조합해서 이름 완성\n"
            "• 이미지 맞추기 — 이름 보고 4개 중 정답 이미지 고르기\n\n"
            "⭐ 3단계 난이도\n"
            "• 쉬움 — 블러 이미지 + 글자 수 힌트\n"
            "• 보통 — 모자이크 이미지 + 글자 수 힌트\n"
            "• 어려움 — 실루엣만! 진짜 티니핑 박사만 도전\n\n"
            "⏰ 10초 타이머\n"
            "시간 안에 맞춰야 해! 두근두근!\n\n"
            "💡 모르겠으면? 힌트!\n"
            "힌트를 쓰면 원본 이미지를 살짝 보여줘!\n\n"
            "📚 전시즌 캐릭터 수록\n"
            "• 1기 감정 티니핑 — 하츄핑, 바로핑, 차차핑...\n"
            "• 2기 보석 티니핑 — 캔디핑, 여우핑...\n"
            "• 3기 열쇠 티니핑 — 빨리핑, 얌얌핑...\n"
            "• 4기 디저트 티니핑 — 쪼꼬핑, 머핑...\n"
            "• 5기 스타 티니핑 — 훌라핑, 초롱핑...\n"
            "• 6기 프린세스 티니핑 — 사뿐핑, 실크핑...\n\n"
            "시즌별로 골라서 풀 수도 있어!\n\n"
            "🏆 전부 맞추면 너는 티니핑 박사!"
        )]),
        divider(),
        paragraph([rich_text("키워드", bold=True)]),
        paragraph([rich_text(
            "티니핑, 캐치티니핑, 하츄핑, 사뿐핑, 바로핑, 캐릭터퀴즈, "
            "이름맞추기, 프린세스티니핑, 시즌6, 아이게임, 퀴즈, 티니핑퀴즈, "
            "티니핑게임, 캐릭터이름, 어린이퀴즈"
        )]),
        divider(),
        paragraph([rich_text("스크린샷 전략 (5장)", bold=True)]),
        bullet([rich_text("① 홈 화면 — 시즌 선택 + 2가지 모드 버튼")]),
        bullet([rich_text("② 블러 퀴즈 — 핵심 게임플레이 (블러 이미지 + 글자 타일)")]),
        bullet([rich_text("③ 실루엣 퀴즈 + 힌트 — 어려움 난이도 + 힌트 기능")]),
        bullet([rich_text("④ 이미지 맞추기 — 역퀴즈 모드 (이름 → 4지선다)")]),
        bullet([rich_text("⑤ 결과 화면 — \"티니핑 박사!\" + 점수")]),
        divider(),
        paragraph([rich_text("아이콘", bold=True)]),
        paragraph([rich_text('핫핑크(#FF4B8B) → 스카이(#7EC8E3) 그라데이션 배경 + 블러 하츄핑 + "?" 마크')]),
    ]
    return toggle_h2("ASO", children)


def build_design_section():
    """디자인 에셋"""
    children = [
        paragraph([rich_text("에셋 목록", bold=True)]),
        bullet([rich_text("앱 아이콘 (1024×1024)")]),
        bullet([rich_text("스플래시 (1080×1920)")]),
        bullet([rich_text("스토어 스크린샷 ×5 (1080×1920)")]),
        bullet([rich_text("피처 그래픽 (1024×500)")]),
        bullet([rich_text("AdMob 배너/보상형 배경")]),
        divider(),
        paragraph([rich_text("아이콘 콘셉트", bold=True)]),
        paragraph([
            rich_text("배경: ", bold=True), rich_text("핫핑크(#FF4B8B) → 스카이(#7EC8E3) 그라데이션\n"),
            rich_text("메인: ", bold=True), rich_text('블러 처리된 하츄핑 이미지\n'),
            rich_text("장식: ", bold=True), rich_text('"?" 마크 + 작은 반짝이\n'),
            rich_text("스타일: ", bold=True), rich_text("라운드 코너, 깨끗하고 귀여운"),
        ]),
        divider(),
        paragraph([rich_text("디자인 핸드오버", bold=True)]),
        bullet([rich_text("Primary: ", bold=True), rich_text("#FF4B8B", code=True), rich_text("  Secondary: "), rich_text("#7EC8E3", code=True), rich_text("  Accent: "), rich_text("#B47AEA", code=True)]),
        bullet([rich_text("제목: Pretendard Bold 28-32px  |  타일: Pretendard ExtraBold 24-28px")]),
        bullet([rich_text("무드: Cute & Playful, 밝고 경쾌, 귀여운, 공식 티니핑 톤")]),
        bullet([rich_text("모티프: 음절 타일(네모 블록), 별(점수), 하트(티니핑 상징), 리본(꾸밈)")]),
        divider(),
        paragraph([rich_text("상태: ", bold=True), rich_text("프롬프트 작성 완료, 에셋 생성 대기")]),
    ]
    return toggle_h2("디자인 에셋", children)


def build_history_section():
    """업데이트 이력"""
    children = [
        bullet([rich_text("2026-03-20", bold=True), rich_text(" — v1.1.0 PRD 재작성 (브랜딩 13단계 통합, 컬러 공식톤 확정, ASO 최적화)")]),
        bullet([rich_text("2026-03-20", bold=True), rich_text(" — v1.0.0 기능 구현 완료. 역퀴즈, 타이머, 힌트, 이미지 재수집(140개 고유)")]),
        bullet([rich_text("2026-03-19", bold=True), rich_text(" — 프로젝트 시작. Plan/Design 문서 작성. 콘텐츠 수집 파이프라인 개발")]),
    ]
    return toggle_h2("업데이트 이력", children)


def main():
    print("=== Notion 페이지 재작성 시작 ===")

    # 1. Delete all existing blocks
    delete_all_blocks()

    # 2. Build new blocks
    blocks = [
        build_prd_section(),
        build_code_section(),
        build_aso_section(),
        build_design_section(),
        build_history_section(),
    ]

    # 3. Append all blocks
    success = append_blocks(blocks)

    if success:
        print("\n✅ 완료! 5개 toggle heading_2 블록 생성")
    else:
        print("\n❌ 실패")

    # 4. Verify
    time.sleep(1)
    resp = requests.get(f"{API}/blocks/{PAGE_ID}/children?page_size=100", headers=HEADERS)
    results = resp.json().get("results", [])
    print(f"\n검증: {len(results)}개 블록")
    for b in results:
        btype = b.get("type", "?")
        toggleable = b.get(btype, {}).get("is_toggleable", False)
        text = ""
        if btype in b and "rich_text" in b[btype]:
            text = "".join([t["plain_text"] for t in b[btype]["rich_text"]])
        toggle_mark = "▶" if toggleable else " "
        print(f"  {toggle_mark} {btype}: {text[:60]}")


if __name__ == "__main__":
    main()
