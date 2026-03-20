# 티니핑 이름맞추기 앱 — PDCA Completion Report

> **Project**: tiniping-name-quiz
> **Author**: seomihye
> **Date**: 2026-03-20
> **PDCA Cycle**: Plan → Design → Do → Check → Act → Report

---

## Executive Summary

| Perspective | Content |
|-------------|---------|
| **Feature** | 티니핑 이름맞추기 퀴즈 앱 (Flutter, iOS/Android) |
| **Period** | 2026-03-19 ~ 2026-03-20 (2일) |
| **Duration** | 1 PDCA cycle, 1 iteration |

### Results

| Metric | Value |
|--------|-------|
| Match Rate | 74% → 90%+ (iteration 후) |
| Dart Files | 18개 |
| Total Lines | 2,324줄 |
| Characters | 140개 (6시즌) |
| Processed Images | 432장 (140 x 3종) |
| Unit Tests | 13개 (all passed) |
| Build | Android APK ✅, flutter analyze 0 issues |

### 1.3 Value Delivered

| Perspective | Content |
|-------------|---------|
| **Problem** | 150여 종의 티니핑 캐릭터를 재미있게 학습할 수단이 없음 |
| **Solution** | 음절 조합 퀴즈 + 이미지 4지선다 역퀴즈, 난이도별 이미지 효과, 10초 타이머, 보상형 힌트 시스템으로 구현 |
| **Function/UX Effect** | 140개 캐릭터 x 2모드 x 3난이도 = 풍부한 조합. 매 진입마다 랜덤 셔플로 반복 플레이 유도 |
| **Core Value** | 아이와 부모가 함께 즐기며 티니핑 캐릭터를 자연스럽게 익히는 교육적 놀이 앱 |

---

## 1. Plan Summary

- **음절 조합 퀴즈**: 캐릭터 이미지를 보고 음절 타일을 조합하여 이름 완성
- **난이도 시스템**: 쉬움(블러) / 보통(모자이크) / 어려움(실루엣) + 방해 음절 수 조절
- **콘텐츠 자동 수집**: Fandom Wiki MediaWiki API로 캐릭터 + 이미지 자동 수집
- **저작권 대응**: 가공 이미지만 번들, 원본은 런타임 URL 로딩
- **프레임워크**: Flutter (Dart) + Riverpod 상태관리
- **배포 대상**: iOS App Store + Google Play Store

---

## 2. Design Summary

### Architecture

```
Flutter App (Riverpod)
├── screens/       (home, quiz, image_quiz, result)  — 4 screens
├── widgets/       (quiz_card, syllable_tile, answer_slots, feedback_overlay, hint_button, network_alert)  — 6 widgets
├── providers/     (quiz_provider)  — Notifier pattern
├── services/      (character, quiz, syllable)  — 3 services
├── models/        (character, quiz_state)  — 2 models
└── utils/         (constants)
```

### Data Flow

```
characters.json (140개) → CharacterService → QuizService → QuizNotifier → UI
```

---

## 3. Implementation Summary

### Phase 1: 콘텐츠 수집 ✅
- Python 스크립트로 Fandom Wiki API 연동
- 144개 수집 → 한글명 추출 개선 → 이미지 고유성 재수집 → 최종 140개
- 3종 가공 이미지 자동 생성 (blur/mosaic/silhouette) = 432장

### Phase 2: Flutter 프로젝트 ✅
- `flutter create` + riverpod, connectivity_plus, cached_network_image
- 모델, 서비스, 프로바이더, 상수 정의

### Phase 3: 핵심 로직 ✅
- 한글 음절 분리 + 방해 음절 생성 (다른 캐릭터 이름에서 추출)
- 문제 생성 + 정답 검증 + Riverpod 상태관리

### Phase 4: UI ✅
- 홈 화면: 시즌/난이도/문제수 선택 + 2가지 모드 시작
- 퀴즈 화면: 이미지 + 슬롯 + 타일 + 삭제 버튼 + 10초 원형 타이머
- 이미지 퀴즈 화면: 이름 표시 + 4지선다 이미지 그리드
- 피드백 오버레이: 정답/오답/시간초과 + 원본 이미지 + 빨간 동그라미 bounce
- 결과 화면: 점수 + 메시지 + 오답 리뷰 + 다시하기/홈으로

### 추가 구현 (Plan 외 사용자 피드백 반영)
| 기능 | 설명 |
|------|------|
| **역퀴즈 모드** | 이름 → 이미지 맞추기 (4지선다) |
| **10초 타이머** | 원형 카운트다운, 3초 이하 빨간색, 시간 초과 처리 |
| **힌트 시스템** | 모든 난이도에서 "광고 보고 힌트 얻기" → 원본 이미지 1/3 노출 |
| **삭제 버튼** | 슬롯 터치 삭제 + ⌫ 버튼 |
| **오프라인 감지** | NetworkAlert 위젯 (connectivity_plus) |

---

## 4. Check (Gap Analysis) Summary

### Initial Analysis: 74%

| Category | Score |
|----------|:-----:|
| Data Model | 90% |
| Content Pipeline | 95% |
| Core Logic | 100% |
| Styling & Theme | 100% |
| UI/UX Components | 64% |
| Animation & Feedback | 30% |

### Key Gaps Found
1. "다시하기" 네비게이션 버그 (ResultScreen → ResultScreen)
2. NetworkAlert 미구현
3. 애니메이션 미구현 (타일 바운스, shake, 빨간 동그라미 bounce)
4. 유닛 테스트 없음
5. 이미지 데이터 문제 (125개가 동일 이미지)

---

## 5. Act (Iteration) Summary

### Iteration 1: 74% → 90%+

| 수정 항목 | 상태 |
|----------|:----:|
| 네비게이션 버그 수정 | ✅ |
| NetworkAlert 구현 | ✅ |
| 타일 바운스 애니메이션 | ✅ |
| 오답 shake 애니메이션 | ✅ |
| 빨간 동그라미 bounce | ✅ |
| 피드백 fadeIn | ✅ |
| 유닛 테스트 13개 | ✅ |
| 이미지 데이터 재수집 (140개 고유 이미지) | ✅ |

### 사용자 피드백 반영 (추가 iteration)

| 피드백 | 대응 |
|--------|------|
| 실루엣 난이도 극악 | 힌트 시스템 추가 (원본 1/3 노출) |
| 역방향 퀴즈 요청 | 이미지 맞추기 모드 구현 |
| 문제 순서 동일 | Random 시드 개선 |
| 이미지 퀴즈 동일 이미지 | 다른 시즌 우선 + 고유 이미지 재수집 |
| 이미지 퀴즈 하단 overflow | LayoutBuilder + childAspectRatio 동적 계산 |
| 음절 삭제 기능 없음 | 슬롯 터치 + ⌫ 버튼 추가 |
| 타이머 필요 | 10초 원형 타이머 추가 |
| 모든 난이도 힌트 | if(isHard) 조건 제거 |

---

## 6. File Structure

```
tiniping-name-quiz/
├── lib/                              (18 files, 2,324 lines)
│   ├── main.dart
│   ├── models/
│   │   ├── character.dart
│   │   └── quiz_state.dart
│   ├── providers/
│   │   └── quiz_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── quiz_screen.dart
│   │   ├── image_quiz_screen.dart
│   │   └── result_screen.dart
│   ├── services/
│   │   ├── character_service.dart
│   │   ├── quiz_service.dart
│   │   └── syllable_service.dart
│   ├── utils/
│   │   └── constants.dart
│   └── widgets/
│       ├── answer_slots.dart
│       ├── feedback_overlay.dart
│       ├── hint_button.dart
│       ├── network_alert.dart
│       ├── quiz_card.dart
│       └── syllable_tile.dart
├── assets/
│   ├── data/characters.json          (140 characters)
│   └── images/tiniping/              (432 processed images)
├── scripts/
│   └── collect_characters.py
├── test/
│   ├── syllable_service_test.dart    (6 tests)
│   └── quiz_service_test.dart        (7 tests)
└── docs/
    ├── 01-plan/features/tiniping-name-quiz.plan.md
    ├── 02-design/features/tiniping-name-quiz.design.md
    └── 04-report/features/tiniping-quiz.report.md
```

---

## 7. Remaining Work

| 항목 | 우선순위 | 비고 |
|------|:--------:|------|
| 앱 브랜딩 (아이콘, 스플래시, 스토어 에셋) | High | 별도 세션 예정 |
| 보상형 광고 SDK 연동 (AdMob) | High | 현재 힌트는 즉시 지급 |
| Android 에뮬레이터 / 실기기 테스트 | High | Chrome 테스트만 완료 |
| APK/IPA 빌드 + 스토어 제출 | High | 브랜딩 후 |
| 4개 캐릭터 이미지 보완 (삐뽀, 뿌뿌핑, 이클립스핑, 힘내핑) | Low | 위키에 고유 이미지 없음 |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | 2026-03-19 | Plan + Design 문서 작성 |
| 0.2 | 2026-03-20 | 콘텐츠 수집 (140개) + Flutter 구현 + Gap 분석 74% |
| 0.3 | 2026-03-20 | Iteration: 버그 수정, 애니메이션, 테스트, 이미지 재수집 → 90%+ |
| 0.4 | 2026-03-20 | 사용자 피드백: 역퀴즈, 타이머, 힌트, 삭제 버튼 추가 |
| 1.0 | 2026-03-20 | PDCA Report 완성. 기능 구현 완료, 브랜딩/배포 잔여 |
