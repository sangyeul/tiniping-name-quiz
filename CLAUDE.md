# CLAUDE.md — 티니핑 이름맞추기

> 공통 규칙은 상위 `app/CLAUDE.md` 참조. 이 파일은 프로젝트 고유 설정만 정의.

## 프로젝트 개요

**티니핑 이름맞추기**는 캐치! 티니핑 6시즌 140마리 캐릭터를 블러/모자이크/실루엣 이미지로 보고, 음절 조합으로 이름을 맞추는 퀴즈 앱.

- **패키지**: `com.seomihye.tiniping_name_quiz`
- **GitHub**: https://github.com/sangyeul/tiniping-name-quiz
- **상태**: 기능 구현 완료, 배포 준비 중

## 기술 스택

- **Framework**: Flutter 3.41 + Dart 3.11
- **State**: Riverpod (Notifier)
- **Data**: 로컬 JSON (assets) — 서버 불필요
- **Image**: WebP 400x400 (가공) + CachedNetworkImage (원본 URL)
- **Ads**: google_mobile_ads (AdMob 보상형/전면/배너)
- **Network**: connectivity_plus (오프라인 알림)

## 브랜드 컬러 (확정)

- Primary: `#FF4B8B` (핫핑크)
- Secondary: `#7EC8E3` (스카이블루)
- Accent: `#B47AEA` (퍼플)
- Background: `#FFF0F5`
- Success/Error: `#2ECC71` / `#E74C3C`
- Star/Hint: `#FFD700`
- Tile: `#FFFFFF` (기본) / `#D8B4FE` (선택)

## 콘텐츠 데이터

- 캐릭터 140개 (6시즌), 가공 이미지 432장
- 데이터 소스: Fandom Wiki (catchteenieping.fandom.com)
- 수집 방식: Python + MediaWiki API 자동 수집 (PRD 7절 참조)

## Notion

- 페이지 ID: `3291624703fe809a9934c873b1b3b3ef`
- Notion API 한글 전송 시 Python `requests` 사용 (curl 인코딩 문제)
