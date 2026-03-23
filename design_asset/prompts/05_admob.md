# AdMob 에셋

## 메타 정보
- 프리셋: 5번
- 용도: 앱 내 광고 배경
- 모델: Nano Banana (API 자동화)

### 배너 광고 배경
- 비율: 다양 (가로형)
- 사이즈: 320×50 / 320×100 / 728×90
- 위치: 홈 화면 하단

### 보상형 광고 팝업 배경
- 비율: 약 6:5
- 사이즈: 300×250
- 위치: 힌트 획득 팝업

## 브랜드 컨텍스트
- 주조색: `#FF4B8B` (핫핑크)
- 보조색: `#FFF0F5` (소프트핑크)
- 액센트: `#B47AEA` (퍼플)
- 골드: `#FFD700`

---

## 5-1. 배너 배경 (320×50, 320×100, 728×90)

### Nano Banana 프롬프트

A simple horizontal banner background for a children's quiz app. 16:5 aspect ratio (will be cropped to multiple banner sizes). Gradient from hot pink (#FF4B8B) at left to soft pink (#FFF0F5) at right — smooth, gentle. Left edge: two small gold (#FFD700) sparkle stars. Right edge: subtle purple (#B47AEA) square tile block shapes as a minimal pattern (2-3 small outlined squares, faded). Center area clean and empty for text overlay. Ultra-minimal, no characters, no complex elements. Soft, child-friendly feel. No text.

### 네거티브 프롬프트

No text, no letters. No characters or faces. No complex illustrations. No dark colors. No busy patterns. Keep extremely minimal — this is a narrow banner.

### 2차 가공 참고사항

생성된 1024×1024 이미지에서 각 사이즈로 크롭:

#### 320×50 (스마트 배너)
- 크롭: 중앙 가로 영역, 극도로 좁음
- 텍스트 없음 (AdMob 광고 콘텐츠가 위에 표시)
- 배경 패턴만 보이면 충분

#### 320×100 (큰 배너)
- 크롭: 중앙 가로 영역
- 텍스트 없음

#### 728×90 (리더보드)
- 크롭: 가로 전체 활용
- 텍스트 없음

---

## 5-2. 보상형 광고 팝업 배경 (300×250)

### Nano Banana 프롬프트

A cute popup card background for a children's app hint reward system. 6:5 aspect ratio, 300x250 pixels equivalent. White rounded card (24px radius) on semi-transparent dark overlay (implied). Top area: gold (#FFD700) lightbulb icon with sparkle burst effect (3-4 small rays). Center: generous empty space for text. Bottom: a circular play button in hot pink (#FF4B8B) with white triangle (play icon). Decorative: small purple (#B47AEA) stars (3-4), gold confetti dots (5-6), pink sparkle particles (3-4). The mood is rewarding, exciting — "you're about to get something special!" Clean, kawaii, child-friendly. No text anywhere.

### 네거티브 프롬프트

No readable text. No realistic imagery. No dark or scary elements. No complex illustrations. No cluttered composition. Keep it simple and inviting.

### 2차 가공 참고사항

#### 텍스트 오버레이 (Pillow / 피그마)
- **제목**: "💡 힌트 얻기"
  - 폰트: Pretendard Bold, 20px
  - 색상: `#FF4B8B`
  - 위치: 상단 중앙, y=60px (전구 아이콘 아래)
- **설명**: "광고를 보고 힌트 3개를 받아봐!"
  - 폰트: Pretendard Regular, 14px
  - 색상: `#666666`
  - 위치: 제목 아래 8px 간격
- **CTA 버튼 텍스트**: "▶ 광고 보기"
  - 폰트: Pretendard SemiBold, 16px
  - 색상: `#FFFFFF`
  - 위치: 플레이 버튼 중앙
