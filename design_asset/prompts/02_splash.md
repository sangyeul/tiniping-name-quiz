# 스플래시 화면

## 메타 정보
- 프리셋: 2번
- 비율: 9:16
- 사이즈: 1080×1920
- 용도: 앱 시작 스플래시 화면 배경
- 모델: Imagen 4 (AI Studio UI 수동)

## 브랜드 컨텍스트
- 주조색: `#FF4B8B` (핫핑크)
- 보조색: `#7EC8E3` (스카이블루)
- 액센트: `#B47AEA` (퍼플)
- 배경: `#FFF0F5` (소프트핑크)
- 골드: `#FFD700`
- 무드: Cute & Playful
- 모티프: 블러 캐릭터 + 음절 타일 + 반짝이

## Nano Banana 프롬프트

A clean vertical splash screen for a children's character quiz app. 9:16 aspect ratio, 1080x1920 pixels. Soft pink background (#FFF0F5) with subtle hot pink (#FF4B8B) radial glow at center, fading to edges. Upper-center: a Gaussian-blurred cute anime fairy character image inside a white rounded card (280x280, 20px radius) with soft pink border and gentle shadow — the blurred character has pastel colors, suggesting mystery. Below the card: three colorful square tile blocks in a horizontal row (each ~80x80), with slight 3D pop effect and purple (#B47AEA) shadow — tiles are empty (text added in Figma post-production). Scattered gold (#FFD700) sparkle stars and small pink heart particles around the card and tiles — playful but not cluttered (max 8-10 particles total). Below tiles: generous empty space for app name text overlay. Bottom area: clean space for tagline. Overall mood: bright, playful, kawaii, welcoming. The color scheme is hot pink + sky blue + purple with soft pink base. No text anywhere.

## 네거티브 프롬프트

No text, no typography (all text added in post-production). No dark or heavy atmosphere. No realistic imagery. No complex detailed character (must be blurred). No busy patterns or heavy textures. No 3D rendering. No gradients that feel corporate. Avoid cluttered particle effects — keep it clean and airy. No copyrighted characters visible.

## 한글 프롬프트 (내용 확인용)

어린이 캐릭터 퀴즈 앱용 깔끔한 세로형 스플래시 화면. 9:16 비율, 1080x1920px. 소프트 핑크 배경(#FFF0F5)에 중앙에 은은한 핫핑크(#FF4B8B) 방사형 글로우. 상단 중앙: 블러 처리된 귀여운 요정 캐릭터 이미지가 흰색 라운드 카드(280x280, 20px 반경) 안에 — 파스텔 톤, 미스터리 암시. 카드 아래: 세 개의 컬러풀한 정사각형 타일 블록이 가로 한 줄(각 ~80x80), 퍼플(#B47AEA) 그림자의 약간의 3D 팝 효과 — 타일은 비어있음(피그마에서 텍스트 추가). 카드와 타일 주변에 골드(#FFD700) 반짝이 별과 작은 핑크 하트 파티클 — 장난스럽지만 어수선하지 않게(총 8-10개 정도). 타일 아래: 앱 이름 텍스트 오버레이용 넉넉한 빈 공간. 하단: 태그라인 공간. 텍스트 일절 없음.

## 2차 가공 참고사항

### 텍스트 오버레이 (피그마)
- **앱 이름**: "티니핑 이름맞추기"
  - 폰트: Pretendard Bold, 32px
  - 색상: `#FF4B8B` (핫핑크)
  - 위치: 타일 블록 아래 중앙, 화면 세로 60% 지점
- **태그라인**: "이 티니핑 이름, 맞출 수 있어?"
  - 폰트: Pretendard Regular, 16px
  - 색상: `#B47AEA` (퍼플)
  - 위치: 앱 이름 아래 8px 간격
- **음절 타일 글자**: "티", "니", "핑"
  - 폰트: Pretendard ExtraBold, 28px
  - 색상: `#333333`
  - 위치: 각 타일 블록 중앙

### 기술 참고
- Android SplashScreen API 연동 — 중앙 심볼 영역이 API 아이콘 영역과 맞아야 함
- 스플래시 지속시간 1.5초이므로 첫인상이 중요
- 앱 아이콘(01번 에셋) 확정 스타일과 동일 톤 유지
