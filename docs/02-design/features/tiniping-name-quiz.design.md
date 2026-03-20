# 티니핑 이름맞추기 앱 Design Document

> **Summary**: 캐릭터 이미지 → 음절 타일 조합으로 이름을 완성하는 퀴즈 앱 상세 설계
>
> **Project**: tiniping-name-quiz
> **Version**: 0.1.0
> **Author**: seomihye
> **Date**: 2026-03-19
> **Status**: Draft
> **Planning Doc**: [tiniping-name-quiz.plan.md](../../01-plan/features/tiniping-name-quiz.plan.md)

### Pipeline References

| Phase | Document | Status |
|-------|----------|--------|
| Phase 1 | Schema Definition | N/A (로컬 JSON) |
| Phase 2 | Coding Conventions | N/A (Next.js 기본) |
| Phase 3 | Mockup | 이 문서에 포함 |
| Phase 4 | API Spec | N/A (정적 앱) |

---

## 1. Overview

### 1.1 Design Goals

- 음절 타일 터치 기반의 직관적 퀴즈 UX
- 145종+ 캐릭터를 자동 수집하는 콘텐츠 파이프라인
- 난이도 시스템으로 다양한 연령대 대응
- 모바일 퍼스트, 아이 친화적 UI

### 1.2 Design Principles

- **Simple Interaction**: 터치 한 번으로 음절 선택/해제
- **Immediate Feedback**: 정답/오답 즉시 시각적 반응
- **Forgiving UX**: 되돌리기 자유, 실패 부담 최소화
- **Content-First**: 데이터 수집 자동화로 유지보수 최소화

---

## 2. Architecture

### 2.1 Component Diagram

```
┌─────────────────────────────────────────────┐
│                 Next.js App                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Start   │→│   Quiz   │→│  Result  │  │
│  │  Page    │  │   Page   │  │  Page    │  │
│  └──────────┘  └────┬─────┘  └──────────┘  │
│                     │                        │
│         ┌───────────┼───────────┐            │
│         ▼           ▼           ▼            │
│    QuizCard   SyllableTile  AnswerSlots     │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  lib/quiz.ts + lib/syllable.ts       │   │
│  │  (퀴즈 로직 + 음절 분리)              │   │
│  └──────────────────────────────────────┘   │
│                     ▲                        │
│  ┌──────────────────┴──────────────────┐    │
│  │  data/characters.json (정적 데이터)   │    │
│  │  assets/images/ (가공 이미지만 번들)  │    │
│  └──────────────────────────────────────┘   │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  External (런타임 로딩)                      │
│  Fandom Wiki 공개 URL → 원본 이미지          │
│  (Image.network, 앱 번들에 미포함)           │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  scripts/collect_characters.py (빌드 전)     │
│  Fandom MediaWiki API → JSON + 가공 이미지   │
│  (블러/모자이크/실루엣 자동 생성)              │
└─────────────────────────────────────────────┘
```

### 2.2 Data Flow

```
[시작 화면]
  사용자 → 시즌 선택 + 난이도 선택 → [퀴즈 시작]

[퀴즈 화면]
  characters.json → 랜덤 출제 → 캐릭터 이미지 표시
                              → 정답 음절 분리
                              → 방해 음절 추가
                              → 음절 타일 셔플 표시

  사용자 → 음절 타일 터치 → 정답 슬롯에 채움
       → 되돌리기 터치 → 슬롯에서 제거, 타일로 복원
       → 모든 슬롯 채움 → 정답 비교
         → 정답: 원본 이미지 런타임 로딩(Image.network)
                + 빨간 동그라미 효과 + 점수 → 탭하면 다음 문제
         → 오답: 흔들림 + 정답 표시 + 원본 이미지 로딩 → 탭하면 다음 문제

  [네트워크 체크]
    앱 시작 시 + 정답 표시 전 connectivity 확인
    오프라인 → Alert("원본 이미지를 보려면 인터넷 연결이 필요합니다")
    오프라인이어도 퀴즈 자체는 가공 이미지로 플레이 가능 (원본 공개만 스킵)

[결과 화면]
  총점 + 메시지 → 다시하기 / 홈으로
```

### 2.3 Dependencies

| Component | Depends On | Purpose |
|-----------|-----------|---------|
| QuizCard | characters.json | 캐릭터 이미지 + 이름 데이터 |
| SyllableTile | lib/syllable.ts | 한글 음절 분리 로직 |
| AnswerSlots | lib/quiz.ts | 정답 검증 로직 |
| collect-characters.py | Fandom MediaWiki API | 캐릭터 데이터 수집 |

---

## 3. Data Model

### 3.1 Entity Definition

```typescript
// 캐릭터 데이터 (characters.json)
interface Character {
  id: string;              // 고유 ID (예: "hachyuping")
  name: string;            // 영문명 (예: "Heartsping")
  nameKo: string;          // 한글명 (예: "하츄핑")
  season: number;          // 시즌 (1~6)
  category: Category;      // 분류
  grade: Grade;            // 등급
  imageFile: string;       // 가공 이미지 파일명 (예: "hachyuping_blur.webp")
  imageUrl: string;        // 원본 이미지 URL (Fandom, 런타임 로딩용)
}

type Category =
  | 'emotion'    // 1기: 감정 티니핑
  | 'jewel'      // 2기: 보석 티니핑
  | 'key'        // 3기: 열쇠 티니핑
  | 'dessert'    // 4기: 디저트 티니핑
  | 'star'       // 5기: 스타 티니핑
  | 'princess';  // 6기: 프린세스 티니핑

type Grade = 'royal' | 'legend' | 'normal';

// 퀴즈 상태
interface QuizState {
  questions: Question[];        // 출제된 문제 목록
  currentIndex: number;         // 현재 문제 인덱스
  score: number;                // 현재 점수
  difficulty: Difficulty;       // 난이도
  selectedSeasons: number[];    // 선택된 시즌 필터
}

interface Question {
  character: Character;         // 출제 캐릭터
  syllables: string[];          // 표시할 음절 타일 (정답 + 방해)
  answerSyllables: string[];    // 정답 음절 배열 (예: ["하", "츄", "핑"])
}

type Difficulty = 'easy' | 'normal' | 'hard';

// 난이도별 설정
interface DifficultyConfig {
  decoyCount: number;           // 방해 음절 수
  showLetterCount: boolean;     // 글자수 힌트 표시 여부
  imageEffect: ImageEffect;     // 퀴즈 이미지 효과
}

type ImageEffect = 'blur' | 'mosaic' | 'silhouette';
```

### 3.2 난이도 설정값

```typescript
const DIFFICULTY_CONFIG: Record<Difficulty, DifficultyConfig> = {
  easy:   { decoyCount: 2, showLetterCount: true,  imageEffect: 'blur' },
  normal: { decoyCount: 3, showLetterCount: true,  imageEffect: 'mosaic' },
  hard:   { decoyCount: 5, showLetterCount: false, imageEffect: 'silhouette' },
};
```

### 3.3 characters.json 예시

```json
[
  {
    "id": "heartsping",
    "name": "Heartsping",
    "nameKo": "하츄핑",
    "season": 1,
    "category": "emotion",
    "grade": "royal",
    "imageFile": "heartsping.webp",
    "imageUrl": "https://static.wikia.nocookie.net/catchteeniepin/images/b/b2/Heartsping_M1_Render_1.png/revision/latest"
  },
  {
    "id": "baroping",
    "name": "Correctping",
    "nameKo": "바로핑",
    "season": 1,
    "category": "emotion",
    "grade": "royal",
    "imageFile": "baroping.webp",
    "imageUrl": "https://static.wikia.nocookie.net/catchteeniepin/images/.../Baroping.png/revision/latest"
  }
]
```

---

## 4. Content Pipeline (자동 수집)

### 4.1 수집 스크립트 설계

```python
# scripts/collect-characters.py 구조

class TinipingCollector:
    BASE_URL = "https://catchteenieping.fandom.com/api.php"
    RATE_LIMIT = 10  # requests per minute

    def collect_all(self):
        """전체 수집 파이프라인"""
        # 1. 카테고리별 캐릭터 목록 조회
        pages = self.get_category_members("Category:Teeniepings")

        # 2. 각 페이지에서 상세 정보 추출
        characters = []
        for page in pages:
            char = self.extract_character_info(page)
            characters.append(char)
            self.rate_limit_wait()

        # 3. 이미지 다운로드 + 3종 가공 이미지 생성
        for char in characters:
            self.download_and_process_image(char)
            # → blur, mosaic, silhouette 각각 생성
            # → assets/images/tiniping/{id}_blur.webp
            # → assets/images/tiniping/{id}_mosaic.webp
            # → assets/images/tiniping/{id}_silhouette.webp

        # 4. JSON 출력 (imageUrl 포함)
        self.save_json(characters)  # imageUrl = 원본 Fandom URL

    def get_category_members(self, category):
        """MediaWiki API: 카테고리 멤버 목록"""
        # action=query&list=categorymembers&cmtitle={category}&cmlimit=500

    def extract_character_info(self, page):
        """페이지에서 캐릭터명(한/영), 시즌, 분류, 이미지 추출"""
        # action=query&titles={page}&prop=images|categories|revisions

    def download_and_process_image(self, char):
        """이미지 다운로드 → 400x400 리사이즈 → 3종 가공 이미지 생성"""
        # 1. 원본 다운로드 + 리사이즈
        # 2. 블러: GaussianBlur(radius=8)
        # 3. 모자이크: resize(20x20) → resize(400x400, NEAREST)
        # 4. 실루엣: 불투명 픽셀 → 핑크색 단색 채움
        # 5. 각각 WebP로 저장
        # 6. char['imageUrl']에 원본 Fandom URL 보존
```

### 4.2 수집 실행

```bash
# 의존성 설치
pip install requests pymediawiki Pillow

# 수집 실행
python scripts/collect-characters.py

# 출력
# → data/characters.json (145+ entries)
# → public/images/tiniping/*.webp (145+ images)
```

### 4.3 데이터 검증

| 검증 항목 | 기준 | 방법 |
|----------|------|------|
| 캐릭터 수 | >= 140 | JSON entry count |
| 이미지 매핑 | 모든 캐릭터에 이미지 존재 | 파일 존재 확인 스크립트 |
| 한글명 유효성 | 빈 문자열 없음 | JSON validation |
| 음절 분리 가능 | 모든 한글명 분리 성공 | syllable.ts 유닛 테스트 |

---

## 5. UI/UX Design

### 5.1 Screen Layout — 시작 화면

```
┌────────────────────────────────┐
│                                │
│     🎀 티니핑 이름 맞추기       │
│                                │
│  ┌──────────────────────────┐  │
│  │ 시즌 선택                 │  │
│  │ [전체] [1기] [2기] [3기]  │  │
│  │ [4기] [5기] [6기]         │  │
│  └──────────────────────────┘  │
│                                │
│  ┌──────────────────────────┐  │
│  │ 난이도                    │  │
│  │ [⭐ 쉬움] [⭐⭐ 보통]     │  │
│  │ [⭐⭐⭐ 어려움]            │  │
│  └──────────────────────────┘  │
│                                │
│  ┌──────────────────────────┐  │
│  │ 문제 수: [10] [20] [전체] │  │
│  └──────────────────────────┘  │
│                                │
│      [ 🎮 퀴즈 시작! ]         │
│                                │
└────────────────────────────────┘
```

### 5.2 Screen Layout — 퀴즈 화면

```
┌────────────────────────────────┐
│  3/10          ⭐ 2점           │  ← ProgressBar + Score
│  ████████░░░░░░░░░░░░          │
├────────────────────────────────┤
│                                │
│      ┌──────────────┐          │
│      │              │          │
│      │  🖼️ 캐릭터    │          │  ← QuizCard (이미지)
│      │    이미지     │          │
│      │              │          │
│      └──────────────┘          │
│                                │
│  ┌────────────────────────┐    │
│  │  [하] [  ] [  ]        │    │  ← AnswerSlots (빈칸)
│  │  ← 터치하면 되돌리기     │    │    (쉬움/보통: 글자수 표시)
│  └────────────────────────┘    │
│                                │
│  ┌────────────────────────┐    │
│  │ [츄] [로] [핑] [바] [뽀]│    │  ← SyllableTiles (선택지)
│  │                        │    │    (정답 + 방해 음절 섞임)
│  └────────────────────────┘    │
│                                │
└────────────────────────────────┘
```

### 5.3 Screen Layout — 정답/오답 피드백

```
정답 시:                          오답 시:
┌──────────────────┐             ┌──────────────────┐
│                  │             │                  │
│  ✅ 정답!         │             │  ❌ 아쉬워요!     │
│                  │             │                  │
│  ┌────────────┐  │             │  ┌────────────┐  │
│  │ 🖼️ 원본    │  │ ← 런타임    │  │ 🖼️ 원본    │  │
│  │  이미지    │  │   URL 로딩   │  │  이미지    │  │
│  │   ⭕       │  │ ← 빨간      │  │            │  │
│  └────────────┘  │   동그라미   │  └────────────┘  │
│                  │             │                  │
│  하츄핑 +1점 ⭐   │             │  정답: 하츄핑      │
│                  │             │                  │
│  [탭하면 다음 →]  │             │  [탭하면 다음 →]  │
└──────────────────┘             └──────────────────┘

오프라인 시:
┌──────────────────┐
│                  │
│  ✅ 정답!         │
│                  │
│  ┌────────────┐  │
│  │ 📡 원본을   │  │ ← 원본 대신 안내
│  │ 보려면     │  │
│  │ 인터넷 필요 │  │
│  └────────────┘  │
│                  │
│  하츄핑 +1점 ⭐   │
│                  │
│  [탭하면 다음 →]  │
└──────────────────┘
```

### 5.4 Screen Layout — 결과 화면

```
┌────────────────────────────────┐
│                                │
│     🎉 퀴즈 완료!               │
│                                │
│     ⭐ 7 / 10                  │
│                                │
│     "티니핑 박사가 될 수 있어!"   │
│                                │
│  ┌──────────────────────────┐  │
│  │ 틀린 문제 다시보기         │  │
│  │ 🖼️ ??? → 정답: 하츄핑     │  │
│  │ 🖼️ ??? → 정답: 바로핑     │  │
│  └──────────────────────────┘  │
│                                │
│  [ 🔄 다시 하기 ] [ 🏠 홈으로 ] │
│                                │
└────────────────────────────────┘
```

### 5.5 User Flow

```
홈 → [네트워크 체크: 오프라인이면 alert 후 계속 가능]
  → 시즌 선택 → 난이도 선택 → 문제 수 선택 → 퀴즈 시작
  → 문제 풀기 (가공 이미지 표시 → 음절 터치 → 슬롯 채움 → 되돌리기 가능)
    → 정답: 원본 이미지 페이드인 + 빨간 동그라미 → 탭하면 다음
    → 오답: 흔들림 + 원본 이미지 + 정답 표시 → 탭하면 다음
    → (오프라인: 원본 이미지 대신 안내 메시지)
    → 다음 문제 (반복)
  → 결과 화면
    → 다시 하기 / 홈으로
```

### 5.6 Component List

| Component | Location | Responsibility |
|-----------|----------|----------------|
| QuizCard | widgets/quiz_card.dart | 난이도별 가공 이미지 표시 (blur/mosaic/silhouette) |
| OriginalReveal | widgets/original_reveal.dart | 정답 후 원본 이미지 Image.network + 빨간 동그라미 |
| SyllableTile | widgets/syllable_tile.dart | 개별 음절 버튼 (선택/비활성 상태) |
| AnswerSlots | widgets/answer_slots.dart | 정답 입력 슬롯 (빈칸 + 채워진 음절). 터치 시 되돌리기 |
| ProgressBar | widgets/progress_bar.dart | 진행률 표시 바 |
| ScoreDisplay | widgets/score_display.dart | 현재 점수 표시 |
| DifficultySelector | widgets/difficulty_selector.dart | 난이도 3단계 선택 |
| SeasonFilter | widgets/season_filter.dart | 시즌별 토글 필터 |
| FeedbackOverlay | widgets/feedback_overlay.dart | 정답/오답 피드백 오버레이 |
| NetworkAlert | widgets/network_alert.dart | 오프라인 감지 alert |
| ResultScreen | widgets/result_screen.dart | 최종 결과 + 오답 리뷰 |

---

## 6. Core Logic

### 6.1 한글 음절 분리 (`lib/syllable.ts`)

```typescript
/**
 * 한글 이름을 음절 단위로 분리
 * "하츄핑" → ["하", "츄", "핑"]
 */
export function splitSyllables(name: string): string[] {
  return [...name];
}

/**
 * 방해 음절 생성
 * - 다른 캐릭터 이름에서 랜덤 음절 추출
 * - 정답 음절과 중복 제거
 */
export function generateDecoys(
  answer: string[],
  allCharacters: Character[],
  count: number
): string[] {
  // 전체 캐릭터 이름에서 음절 풀 생성
  // 정답 음절 제외 후 랜덤 선택
}
```

### 6.2 퀴즈 로직 (`lib/quiz.ts`)

```typescript
/**
 * 퀴즈 문제 생성
 */
export function generateQuestions(
  characters: Character[],
  count: number,
  difficulty: Difficulty,
  seasons: number[]
): Question[] {
  // 1. 시즌 필터링
  // 2. 랜덤 셔플 후 count만큼 선택
  // 3. 각 캐릭터 → 음절 분리 + 방해 음절 추가
  // 4. 전체 타일 셔플
}

/**
 * 정답 검증
 */
export function checkAnswer(
  selected: string[],
  answer: string[]
): boolean {
  return selected.join('') === answer.join('');
}
```

---

## 7. Styling & Theme

### 7.1 Color Palette

| 용도 | 색상 | Hex | 비고 |
|------|------|-----|------|
| Primary | 핑크 | #FF6B9D | 티니핑 테마 컬러 |
| Secondary | 하늘색 | #4ECDC4 | 보조 색상 |
| Success | 초록 | #2ECC71 | 정답 피드백 |
| Error | 빨강 | #E74C3C | 오답 피드백 |
| Background | 연핑크 | #FFF0F5 | 전체 배경 |
| Tile Default | 흰색 | #FFFFFF | 음절 타일 기본 |
| Tile Selected | 연보라 | #DDA0DD | 선택된 타일 |

### 7.2 Typography

| 요소 | 크기 | 비고 |
|------|------|------|
| 제목 | 24px~32px | 볼드, 아이 가독성 |
| 음절 타일 | 20px~28px | 볼드, 터치하기 좋은 크기 |
| 점수/진행률 | 16px~18px | 일반 |
| 안내 텍스트 | 14px~16px | 부모용 |

### 7.3 Tile Design

```
음절 타일 사이즈: 최소 56px x 56px (터치 영역 48px+ 확보)
모서리: rounded-xl (12px)
그림자: shadow-md
선택 시: scale(0.95) + 색상 변경 + 짧은 바운스
```

---

## 8. Animation & Feedback

| 상황 | 애니메이션 | Duration |
|------|-----------|----------|
| 타일 선택 | scale(0.95) → scale(1) 바운스 | 200ms |
| 슬롯 채움 | slideUp 등장 | 150ms |
| 되돌리기 | 슬롯에서 fadeOut → 타일로 fadeIn | 200ms |
| 정답 | 가공→원본 이미지 crossFade + 빨간 동그라미(scale 0→1) + confetti | 800ms |
| 오답 | 슬롯 전체 흔들림(shake) + 빨간 테두리 → 원본 이미지 fadeIn | 600ms |
| 빨간 동그라미 | 원본 이미지 위에 빨간 원 scale(0→1.2→1) bounce | 400ms |
| 다음 문제 전환 | fadeOut → fadeIn | 300ms |

---

## 9. Test Plan

### 9.1 Test Scope

| Type | Target | Tool |
|------|--------|------|
| Unit Test | syllable.ts, quiz.ts | Vitest |
| Component Test | SyllableTile, AnswerSlots | Vitest + React Testing Library |
| E2E Test | 전체 퀴즈 플로우 | 수동 (MVP) |

### 9.2 Test Cases

- [ ] 한글 음절 분리: "하츄핑" → ["하", "츄", "핑"]
- [ ] 방해 음절 생성: 정답 음절과 중복 없음
- [ ] 난이도별 방해 음절 수 정확
- [ ] 되돌리기: 슬롯에서 제거 → 타일 복원
- [ ] 정답 판정: 올바른 순서로 채웠을 때만 정답
- [ ] 오답 판정: 모든 슬롯 채웠으나 순서 틀릴 때
- [ ] 결과 화면: 총점 + 오답 목록 정확

---

## 10. Implementation Order

### 10.1 Phase 1: 콘텐츠 수집 (Day 1)

1. [ ] `scripts/collect_characters.py` 개발
2. [ ] Fandom Wiki MediaWiki API 연동 테스트
3. [ ] 전체 캐릭터 수집 + 3종 가공 이미지 생성 (blur/mosaic/silhouette)
4. [ ] `assets/data/characters.json` 생성 및 검증 (imageUrl 포함)

### 10.2 Phase 2: Flutter 프로젝트 초기화 (Day 1)

5. [ ] `flutter create tiniping_name_quiz` + 패키지 추가 (riverpod, connectivity_plus, cached_network_image)
6. [ ] 모델 정의 (`models/character.dart`, `models/quiz_state.dart`)
7. [ ] 테마/상수 정의 (`utils/constants.dart` — 색상, 난이도 설정)

### 10.3 Phase 3: 핵심 로직 (Day 2)

8. [ ] `services/syllable_service.dart` — 음절 분리 + 방해 음절 생성
9. [ ] `services/quiz_service.dart` — 문제 생성 + 정답 검증
10. [ ] `services/character_service.dart` — JSON 로드 + 시즌 필터
11. [ ] `providers/quiz_provider.dart` — Riverpod 상태관리
12. [ ] 유닛 테스트

### 10.4 Phase 4: UI 구현 (Day 2~3)

13. [ ] `widgets/quiz_card.dart` — 난이도별 가공 이미지 표시
14. [ ] `widgets/syllable_tile.dart` + `widgets/answer_slots.dart`
15. [ ] `widgets/original_reveal.dart` — 원본 Image.network + 빨간 동그라미
16. [ ] `widgets/network_alert.dart` — 오프라인 감지 alert
17. [ ] `screens/home_screen.dart` — 시즌/난이도/문제수 선택
18. [ ] `screens/quiz_screen.dart` — 메인 게임 루프
19. [ ] `widgets/feedback_overlay.dart` — 정답/오답 피드백
20. [ ] `screens/result_screen.dart` — 결과 + 오답 리뷰

### 10.5 Phase 5: 폴리시 & 배포 (Day 3)

21. [ ] 애니메이션 적용 (타일 바운스, 빨간 동그라미 scale, crossFade)
22. [ ] 기기별 테스트 (iOS Simulator + Android Emulator)
23. [ ] 앱 아이콘 + 스플래시 화면
24. [ ] `flutter build appbundle` (Android) + `flutter build ipa` (iOS)
25. [ ] Play Store + App Store 제출

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-03-19 | Initial design — 음절 조합 퀴즈 + 콘텐츠 파이프라인 | seomihye |
| 0.2 | 2026-03-19 | 난이도별 이미지 효과(블러/모자이크/실루엣), 정답 후 원본 런타임 로딩+빨간 동그라미, 오프라인 감지, Flutter 위젯 반영 | seomihye |
