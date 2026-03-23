# 디자인 에셋 작업 계획 — 티니핑 이름맞추기

> Last Updated: 2026-03-23

---

## 에셋 목록 및 생성 전략

| # | 에셋 | 사이즈 | 모델 | 접근 방식 | 후처리 | 상태 |
|---|------|--------|------|----------|--------|:----:|
| 1 | 앱 아이콘 | 1024×1024 | Imagen 4 | AI Studio UI (수동) | 피그마: 라운드 코너 | ⬜ |
| 2 | 스플래시 | 1080×1920 | Imagen 4 | AI Studio UI (수동) | 피그마: 앱 이름 + 태그라인 | ⬜ |
| 3 | 스크린샷 ×5 | 1080×1920 | Nano Banana | API 자동화 | Pillow: 기기 프레임 + 문구 | ⬜ |
| 4 | 피처 그래픽 | 1024×500 | Nano Banana | API 자동화 | Pillow: 한글 문구 합성 | ⬜ |
| 5 | AdMob 배너 | 320×50, 320×100, 728×90 | Nano Banana | API 자동화 | Pillow: 리사이즈 | ⬜ |
| 6 | AdMob 보상형 | 300×250 | Nano Banana | API 자동화 | Pillow: 아이콘 + 문구 | ⬜ |

**총 13장** (아이콘 1 + 스플래시 1 + 스크린샷 5 + 피처 1 + 배너 3 + 보상형 1 + 여유분)

---

## 작업 흐름 (4단계)

### Step 1. 환경 셋업 + 로고 생성

```
[1회성 작업]
├── .env에 GOOGLE_AI_API_KEY 등록
├── Python 의존성 설치 (google-genai, Pillow)
├── Pretendard 폰트 파일 배치 (design_asset/fonts/)
└── 자동화 스크립트 작성 (scripts/generate_assets.py)
```

- API 키: Google AI Studio에서 발급받은 키 사용
- 폰트: Pretendard Bold/ExtraBold (한글 텍스트 렌더링용)
- 스크립트: 프롬프트 읽기 → API 호출 → 리사이즈 → 문구 합성 → 저장

### Step 2. 로고(앱 아이콘) 생성 → ★ 사용자 컨펌

```
[AI Studio UI — Imagen 4 사용]
├── 아이콘: 프롬프트로 3~5장 생성 → design_asset/raw/manual/
├── 사용자가 직접 확인 후 1장 선택 → 컨펌
├── ★ 컨펌 전까지 이후 에셋 작업 진행하지 않음
└── 컨펌 후: 이 아이콘의 톤/스타일이 전체 에셋의 기준이 됨
```

- 로고가 전체 에셋의 톤 기준 → 가장 먼저 확정 필수
- Imagen 4가 퀄리티 최고 → 앱의 첫인상에 사용
- 수동인 이유: 가장 중요한 에셋, 눈으로 직접 퀄리티 확인 필요

### Step 3. 스플래시 수동 생성

```
[AI Studio UI — Imagen 4 사용]
├── 스플래시: 확정된 아이콘 스타일 기반으로 3~5장 생성
├── 다운로드 → design_asset/raw/manual/
└── 피그마에서 최종 가공
    └── 앱 이름 "티니핑 이름맞추기" + 태그라인 + "티니핑" 타일 글자
```

### Step 4. 반복 에셋 API 자동화 (스크린샷 + 피처 + AdMob)

```
[Python 스크립트 — Nano Banana API]
├── prompts/*.md에서 프롬프트 로딩
├── Gemini API (gemini-2.5-flash-image) 호출 → 1024×1024 생성
├── Pillow 후처리 파이프라인:
│   ├── 리사이즈 (에셋별 목표 사이즈)
│   ├── 한글 문구 삽입 (Pretendard 폰트)
│   ├── 브랜드 컬러 오버레이/프레임 적용
│   └── 기기 프레임 합성 (스크린샷용)
└── design_asset/raw/auto/ 에 저장
```

- 무료 한도 500장/일 → 스크린샷 5장 + 피처 1장 + AdMob 4장 = 10장
- 프롬프트 튜닝 포함해도 하루 50~100장이면 충분
- 마음에 안 들면 프롬프트 수정 후 재실행 (비용 $0)

### Step 5. 최종 검수 및 적용

```
[수동 검수]
├── design_asset/raw/ 전체 리뷰
├── 필요 시 피그마에서 미세 조정
├── 최종 에셋 배치:
│   ├── 앱 아이콘 → android/app/src/main/res/ + ios/
│   ├── 스플래시 → assets/splash/
│   ├── 스크린샷/피처 → 스토어 등록용 (별도 보관)
│   └── AdMob 배경 → assets/ad/
└── 에셋 체크리스트 상태 업데이트 (⬜ → ✅)
```

---

## 자동화 파이프라인 상세

```
prompts/asset-prompts.md
        │
        ▼
scripts/generate_assets.py
        │
        ├─→ [Nano Banana API] 이미지 생성 (1024×1024)
        │
        ├─→ [Pillow] 리사이즈
        │   ├── 스크린샷: 1080×1920
        │   ├── 피처: 1024×500
        │   ├── 배너: 320×50, 320×100, 728×90
        │   └── 보상형: 300×250
        │
        ├─→ [Pillow] 문구 삽입 (Pretendard 폰트)
        │   ├── 스크린샷: 상단 캡션 ("🎀 이름 맞추기", "⭐ 3단계 난이도" 등)
        │   ├── 피처: "이 티니핑 이름, 맞출 수 있어?"
        │   └── AdMob: 간단 CTA 텍스트
        │
        └─→ design_asset/raw/auto/ 저장
```

---

## 비용 계획

| 항목 | 수량 | 모델 | 단가 | 비용 |
|------|:----:|------|:----:|:----:|
| 아이콘 후보 | ~5장 | Imagen 4 (AI Studio UI) | 무료 | $0 |
| 스플래시 후보 | ~5장 | Imagen 4 (AI Studio UI) | 무료 | $0 |
| 스크린샷 + 피처 | ~50장 (튜닝 포함) | Nano Banana (API) | 무료 (~500/일) | $0 |
| AdMob | ~20장 (튜닝 포함) | Nano Banana (API) | 무료 | $0 |
| **합계** | **~80장** | | | **$0** |

---

## 산출물 폴더 구조

```
design_asset/
├── PLAN.md              ← 이 파일 (작업 계획)
├── prompts/
│   └── asset-prompts.md ← 프롬프트 원본
├── fonts/
│   ├── Pretendard-Bold.otf
│   └── Pretendard-ExtraBold.otf
└── raw/
    ├── manual/          ← Step 2: AI Studio UI 수동 생성
    │   ├── icon_v1.png
    │   ├── icon_v2.png
    │   └── splash_v1.png
    └── auto/            ← Step 3: API 자동 생성
        ├── screenshot_01_home.png
        ├── screenshot_02_blur_quiz.png
        ├── screenshot_03_silhouette.png
        ├── screenshot_04_image_quiz.png
        ├── screenshot_05_result.png
        ├── feature_graphic.png
        ├── admob_banner_320x50.png
        ├── admob_banner_320x100.png
        ├── admob_banner_728x90.png
        └── admob_reward_300x250.png
```
