# 스토어 피처드 이미지

## 메타 정보
- 프리셋: 4번
- 비율: 약 2:1
- 사이즈: 1024×500
- 용도: Google Play Store 상단 피처드 이미지 (Feature Graphic)
- 모델: Nano Banana (API 자동화)

## 브랜드 컨텍스트
- 주조색: `#FF4B8B` (핫핑크)
- 보조색: `#7EC8E3` (스카이블루)
- 액센트: `#B47AEA` (퍼플)
- 골드: `#FFD700`
- 무드: Cute & Playful
- 모티프: 음절 타일, 블러 캐릭터, 반짝이

## Nano Banana 프롬프트

A wide horizontal banner for Google Play Store feature graphic. 2:1 aspect ratio, 1024x500 pixels. Gradient background from hot pink (#FF4B8B) at left to sky blue (#7EC8E3) at right — smooth, vibrant, diagonal. Left side (40%): three colorful square tile blocks (80x80 each) scattered playfully at casual angles (-5 to +5 degrees), each tile is white with bold colored border — one hot pink, one sky blue, one purple (#B47AEA). Tiles have purple drop shadows for depth. A small Gaussian-blurred cute character image peek in the bottom-left corner (soft, pastel, partially cropped). Center-right (60%): generous clean negative space for text overlay — room for app name and subtitle stacked vertically. Gold sparkle stars (#FFD700) and small pink hearts scattered throughout (max 6-8 total). A small "?" mark in white near the tiles. Eye-catching, playful, child-friendly. No copyrighted characters clearly visible. No text anywhere.

## 네거티브 프롬프트

No readable text, letters, or wordmarks. No realistic photography. No dark or corporate feel. No 3D rendering. No identifiable character faces. No busy or cluttered composition. No sharp edges — keep everything soft. Avoid gradient banding.

## 한글 프롬프트 (내용 확인용)

Google Play Store 피처드 이미지용 넓은 가로 배너. 2:1 비율, 1024x500px. 그라데이션 배경 — 좌측 핫핑크(#FF4B8B)에서 우측 스카이블루(#7EC8E3)로. 왼쪽(40%): 세 개의 컬러풀한 정사각형 타일 블록(각 80x80)이 장난스럽게 각도를 틀어 배치(핫핑크/스카이/퍼플 테두리). 타일에 퍼플 그림자. 왼쪽 하단 코너에 작은 블러 캐릭터 이미지 일부 노출. 우측(60%): 텍스트 오버레이용 넉넉한 여백. 골드 반짝이 별과 핑크 하트 소량(6~8개). 타일 근처에 흰색 "?" 마크. 텍스트 일절 없음.

## 2차 가공 참고사항

### 텍스트 오버레이 (Pillow / 피그마)
- **앱 이름**: "티니핑 이름맞추기"
  - 폰트: Pretendard Bold, 36px
  - 색상: `#FFFFFF` (화이트)
  - 위치: 우측 영역 중앙, x=600px, y=180px
  - 텍스트 그림자: `#B47AEA` 2px offset
- **부제**: "이 티니핑 이름, 맞출 수 있어?"
  - 폰트: Pretendard Regular, 18px
  - 색상: `#FFFFFF` 90% opacity
  - 위치: 앱 이름 아래 12px 간격

### 레이아웃 주의
- Play Store에서 이 이미지 위에 앱 이름/아이콘이 겹쳐 표시될 수 있음 → 하단 20%에 중요 요소 배치 금지
- 핵심 요소는 중앙 80%에 배치 (다양한 디바이스 크롭 대응)
- 좌측 타일 그룹과 우측 텍스트 사이 적절한 여백 확보
