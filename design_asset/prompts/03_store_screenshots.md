# 앱스토어 스크린샷 5장 세트

## 메타 정보
- 프리셋: 3번
- 비율: 9:16 (세로)
- 사이즈: 1080×1920 ×5장
- 용도: Google Play Store / App Store 스크린샷
- 모델: Nano Banana (API 자동화)

## 브랜드 컨텍스트
- 주조색: `#FF4B8B` (핫핑크)
- 보조색: `#7EC8E3` (스카이블루)
- 액센트: `#B47AEA` (퍼플)
- 배경: `#FFF0F5` (소프트핑크)
- 정답/오답: `#2ECC71` / `#E74C3C`
- 골드: `#FFD700`
- 타일: `#FFFFFF` (기본) / `#D8B4FE` (선택)
- 무드: Cute & Playful
- 스크린샷 전략 (PRD 9.5절): 홈 → 블러퀴즈 → 실루엣+힌트 → 이미지퀴즈 → 결과

## 파노라마 설계

5장이 나란히 놓였을 때 배경이 자연스럽게 이어지도록:
- 공통 배경: 소프트핑크(`#FFF0F5`) 베이스 + 핫핑크 그라데이션 포인트
- 상단 캡션 영역(상위 18%)과 하단 서브텍스트 영역(하위 12%) 통일
- 폰 프레임은 동일 모델 사용, 약간 기울임(5도)
- 골드 반짝이 파티클이 5장에 걸쳐 균일 분포

---

## Screenshot 1 — 홈 화면

### Nano Banana 프롬프트

A vertical app store screenshot, 9:16 aspect ratio, 1080x1920 pixels. Soft pink background (#FFF0F5) with gentle hot pink (#FF4B8B) gradient glow at top. Center: modern smartphone frame (thin bezels, dark frame) tilted 5 degrees, displaying a quiz app home screen — rounded pill-shaped season filter chips in hot pink outlined style at top, three difficulty buttons with star ratings below, two large rounded CTA buttons stacked (top one hot pink #FF4B8B, bottom one sky blue #7EC8E3). Clean white screen interior. Around the phone: scattered gold sparkle stars (✦) and small pink hearts. Top 18% reserved clean for headline text overlay. Bottom 12% reserved for sub-text. No readable text anywhere in the image — all text added in post-production. Child-friendly, bright, kawaii aesthetic.

### 네거티브 프롬프트

No readable text or letters. No realistic phone photo. No dark backgrounds. No old phone design. No cluttered decorations. Style must be consistent across all 5 screenshots.

### 2차 가공 참고사항

- **상단 캡션**: "🎀 이름 맞추기 & 이미지 맞추기"
  - 폰트: Pretendard Bold, 24px
  - 색상: `#FF4B8B`
  - 위치: 상단 중앙, y=120px
- **하단 서브텍스트**: "6시즌 140마리! 시즌별로 골라서 도전"
  - 폰트: Pretendard Regular, 14px
  - 색상: `#B47AEA`
  - 위치: 하단 중앙, y=1800px

---

## Screenshot 2 — 블러 퀴즈 (핵심 게임플레이)

### Nano Banana 프롬프트

A vertical app store screenshot, 9:16 aspect ratio, 1080x1920 pixels. Same soft pink background for continuity. Center: smartphone frame (same model, tilted 5 degrees) showing quiz gameplay — top bar with hot pink progress indicator, circular sky blue timer showing "7", gold star score. Center of screen: a Gaussian-blurred colorful cute character image (200x200) inside a white rounded card with subtle hot pink border glow. Below: three empty answer slots (white squares with hot pink dotted borders). Bottom: five square tile buttons (80x80 each) with light purple (#D8B4FE) border, one tile appears pressed with purple fill. Gold sparkle stars around phone. Playful, engaging quiz feel.

### 네거티브 프롬프트

No readable text or Korean characters on tiles. No realistic character image visible. No dark colors. Style consistent with Screenshot 1.

### 2차 가공 참고사항

- **상단 캡션**: "⭐ 블러 이미지 보고 이름 맞추기!"
  - 폰트: Pretendard Bold, 24px
  - 색상: `#FF4B8B`
  - 위치: 상단 중앙, y=120px
- **하단 서브텍스트**: "음절 타일을 조합해서 이름을 완성해봐"
  - 폰트: Pretendard Regular, 14px
  - 색상: `#B47AEA`
  - 위치: 하단 중앙, y=1800px

---

## Screenshot 3 — 실루엣 퀴즈 + 힌트

### Nano Banana 프롬프트

A vertical app store screenshot, 9:16 aspect ratio, 1080x1920 pixels. Same soft pink background continuity. Center: smartphone frame showing hard difficulty quiz — a solid hot pink (#FF4B8B) silhouette of a cute fairy character inside a white rounded card (the shape is clearly a character but no details). Below the silhouette: a hint preview card showing top 1/3 of a colorful original character image, bottom 2/3 covered by white overlay with purple "?" mark. Next to hint: a pill button with lightbulb icon in gold (#FFD700). Timer area showing "3" in red (#E74C3C). Answer slots and tiles below. Mood: challenging but fun. Gold sparkles around.

### 네거티브 프롬프트

No readable text. No identifiable copyrighted character. No dark mood. Style consistent with previous screenshots.

### 2차 가공 참고사항

- **상단 캡션**: "💡 모르겠으면? 힌트 사용!"
  - 폰트: Pretendard Bold, 24px
  - 색상: `#FF4B8B`
  - 위치: 상단 중앙, y=120px
- **하단 서브텍스트**: "실루엣만 보고 맞추면 진짜 티니핑 박사!"
  - 폰트: Pretendard Regular, 14px
  - 색상: `#B47AEA`
  - 위치: 하단 중앙, y=1800px

---

## Screenshot 4 — 이미지 맞추기 모드

### Nano Banana 프롬프트

A vertical app store screenshot, 9:16 aspect ratio, 1080x1920 pixels. Same soft pink background continuity. Center: smartphone frame showing image quiz mode — sky blue (#7EC8E3) progress bar at top. Large bold text area in center (placeholder for character name). Below: 2x2 grid of four blurred character images in white rounded cards with subtle shadows. One card highlighted with green (#2ECC71) border (correct), another with red (#E74C3C) shake effect (wrong). Cards have even spacing. Clean grid layout. Gold sparkles around phone.

### 네거티브 프롬프트

No readable text. No identifiable characters. No asymmetric grid. No dark colors. Style consistent with previous.

### 2차 가공 참고사항

- **상단 캡션**: "🔍 이름 보고 이미지 맞추기!"
  - 폰트: Pretendard Bold, 24px
  - 색상: `#7EC8E3` (스카이블루 — 이미지 모드 컬러)
  - 위치: 상단 중앙, y=120px
- **하단 서브텍스트**: "4개 중 정답 이미지를 골라봐"
  - 폰트: Pretendard Regular, 14px
  - 색상: `#B47AEA`
  - 위치: 하단 중앙, y=1800px

---

## Screenshot 5 — 결과 화면

### Nano Banana 프롬프트

A vertical app store screenshot, 9:16 aspect ratio, 1080x1920 pixels. Same soft pink background, completing the set. Center: smartphone frame showing result screen — top area with large gold (#FFD700) star icon and scattered gold sparkle particles (celebratory). White rounded card showing score area (large number placeholder). Below: encouraging message area in hot pink. A small list section with thumbnail images + text placeholders (wrong answer review). Bottom: two buttons side by side (outlined button + filled hot pink button). Purple (#B47AEA) confetti dots scattered. Warm, encouraging, celebratory mood.

### 네거티브 프롬프트

No readable text. No sad or negative imagery. No dark mood. No complex detailed illustrations. Style consistent with all previous screenshots.

### 2차 가공 참고사항

- **상단 캡션**: "🏆 전부 맞추면 티니핑 박사!"
  - 폰트: Pretendard Bold, 24px
  - 색상: `#FFD700` (골드)
  - 위치: 상단 중앙, y=120px
- **하단 서브텍스트**: "오답 리뷰하고 다시 도전해봐!"
  - 폰트: Pretendard Regular, 14px
  - 색상: `#B47AEA`
  - 위치: 하단 중앙, y=1800px

---

## 파노라마 일관성 체크

- [ ] 5장 모두 동일 배경 (#FFF0F5 베이스)
- [ ] 폰 프레임 디자인/기울기 동일 (5도)
- [ ] 상단 캡션 위치(y=120px) / 하단 서브텍스트 위치(y=1800px) 통일
- [ ] 골드 반짝이 파티클 밀도 균일
- [ ] 1장씩 순서대로 생성, 이전 장을 레퍼런스로 첨부하여 일관성 확보

## 첨부 이미지 가이드
> 스크린샷 생성 시 AI Studio / API 호출할 때:
> - **확정된 앱 아이콘** (01번 에셋) 첨부 → 톤 일관성
> - **Screenshot 1 확정본**을 이후 장 생성 시 함께 첨부 → 파노라마 일관성
> - "첨부한 이미지와 동일한 스타일/배경으로 만들어줘" 지시
