# 티니핑 이름맞추기 앱 Planning Document

> **Summary**: 캐치! 티니핑 캐릭터 이미지를 보고 음절을 조합하여 이름을 맞추는 퀴즈 앱 (Flutter + 스토어 배포)
>
> **Project**: tiniping-name-quiz
> **Version**: 0.3.0
> **Author**: seomihye
> **Date**: 2026-03-19
> **Status**: Draft

---

## Executive Summary

| Perspective | Content |
|-------------|---------|
| **Problem** | 6기 기준 145마리 이상의 티니핑 캐릭터가 존재하며 계속 늘어나, 이름을 외우기 어렵고 재미있게 학습할 수단이 없다 |
| **Solution** | Flutter로 크로스플랫폼 앱을 개발, 음절 타일 조합 퀴즈 (난이도별 방해 음절 + 글자수 힌트). iOS/Android 스토어 배포 |
| **Function/UX Effect** | 음절 타일 터치 → 이름 조합 → 즉각 피드백의 인터랙티브 퀴즈 경험. 되돌리기로 부담 없는 플레이 |
| **Core Value** | 아이와 부모가 함께 즐기며 티니핑 캐릭터를 자연스럽게 익히는 교육적 놀이 |

---

## 1. Overview

### 1.1 Purpose

티니핑 캐릭터 이미지를 보고 음절 타일을 조합하여 이름을 완성하는 퀴즈 형식의 웹 앱. 4지선다보다 능동적인 참여로 학습 효과와 재미를 극대화한다.

### 1.2 Background

- "캐치! 티니핑"은 아이들에게 인기 있는 애니메이션 (SAMG Entertainment 제작)
- 6기(프린세스 캐치! 티니핑)까지 방영, **총 145마리 이상** 등장
- 시즌별 분류: 감정(1기) → 보석(2기) → 열쇠(3기) → 디저트(4기) → 스타(5기) → 프린세스(6기)
- 유사 서비스(machugi.io)는 4지선다 방식 → **음절 조합 방식으로 차별화**

### 1.3 Related Documents

- Requirements: 이 문서가 초기 기획서 역할
- References:
  - [Catch! Teenieping Wiki (Fandom)](https://catchteenieping.fandom.com/wiki/List_of_Teeniepings) - 전체 캐릭터 목록 + 이미지
  - [티니핑 - 나무위키](https://namu.wiki/w/%ED%8B%B0%EB%8B%88%ED%95%91) - 시즌별 상세 정보

---

## 2. Scope

### 2.1 In Scope

- [x] 티니핑 캐릭터 이미지 + 이름 데이터셋 자동 수집 (Fandom Wiki API)
- [x] 음절 타일 조합 퀴즈 화면 (이미지 → 음절 선택 → 이름 완성)
- [x] 난이도별 이미지 효과 (쉬움=블러, 보통=모자이크, 어려움=실루엣)
- [x] 난이도 시스템 (방해 음절 수 조절 + 글자수 힌트 on/off)
- [x] 되돌리기 기능 (잘못 선택한 음절 취소)
- [x] 정답 시 원본 이미지 공개 + 빨간 동그라미 효과 (런타임 URL 로딩)
- [x] 오프라인 감지 + alert ("인터넷 연결이 필요합니다")
- [x] 정답/오답 즉시 피드백 (시각적 효과)
- [x] 점수 표시 및 결과 화면
- [x] 시즌별/카테고리별 퀴즈 필터
- [x] 모바일 친화적 반응형 UI

### 2.2 Out of Scope

- 사용자 로그인/회원가입 (불필요)
- 서버 사이드 로직 / DB (정적 데이터로 충분)
- 랭킹 시스템 (MVP 이후 고려)
- 이름 → 이미지 맞추기 (역방향 퀴즈, 추후 확장)

---

## 3. Requirements

### 3.1 Functional Requirements

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-01 | 난이도별 가공 이미지 표시 (블러/모자이크/실루엣) + 음절 타일로 이름 완성 | High | Pending |
| FR-02 | 정답 음절 외 방해 음절(오답) 혼합 표시 — 난이도별 개수 조절 | High | Pending |
| FR-03 | 글자수 힌트: 빈칸 `[_][_][_]`으로 정답 글자수 표시 (고난이도에서 숨김) | High | Pending |
| FR-04 | 되돌리기: 선택한 음절을 탭하여 취소 가능 | High | Pending |
| FR-05 | 정답 시 원본 이미지 런타임 로딩 + 빨간 동그라미 효과 + 점수 +1 | High | Pending |
| FR-06 | 오답(모든 칸 채웠으나 틀림) 시 정답 표시 + 흔들림 효과 | High | Pending |
| FR-07 | 퀴즈 진행률 표시 (예: 3/10) | Medium | Pending |
| FR-08 | 퀴즈 종료 후 결과 화면 (총점, 메시지) | High | Pending |
| FR-09 | 문제 순서 및 음절 타일 순서 랜덤 셔플 | Medium | Pending |
| FR-10 | "다시 하기" 버튼으로 퀴즈 재시작 | Medium | Pending |
| FR-11 | 시즌별/카테고리별 퀴즈 필터 선택 | Medium | Pending |
| FR-12 | 난이도 선택 (쉬움/보통/어려움) | Medium | Pending |
| FR-13 | 오프라인 감지: 네트워크 미연결 시 alert ("인터넷 연결이 필요합니다") | High | Pending |

#### 난이도 설계

| 난이도 | 퀴즈 이미지 | 방해 음절 수 | 글자수 힌트 | 되돌리기 |
|--------|:----------:|:----------:|:---------:|:-------:|
| 쉬움 | 블러 (색감+윤곽 유추) | 1~2개 | O (빈칸 표시) | 무제한 |
| 보통 | 모자이크 (색 배치 유추) | 3~4개 | O (빈칸 표시) | 무제한 |
| 어려움 | 실루엣 (윤곽만) | 4~5개 | X (숨김) | 무제한 |

> 정답 후: 모든 난이도에서 원본 이미지를 외부 URL에서 런타임 로딩하여 표시 + 빨간 동그라미 효과

#### 이미지 전략 (저작권 대응)

| 구분 | 저장 위치 | 포함 방식 | 저작권 리스크 |
|------|----------|----------|:----------:|
| 퀴즈용 (가공) | 앱 번들 assets/ | 블러/모자이크/실루엣 (자동 생성) | **낮음** |
| 정답 공개용 (원본) | 외부 URL (Fandom) | `Image.network()` 런타임 로딩 | **낮음** (앱에 미포함) |

> 앱 바이너리에 원본 이미지가 물리적으로 없으므로 스토어 심사 및 DMCA 리스크 최소화.
> DMCA 요청 시 URL만 제거하면 앱 자체는 유지 가능.

### 3.2 Non-Functional Requirements

| Category | Criteria | Measurement Method |
|----------|----------|-------------------|
| Performance | 페이지 로딩 3초 이내 | Lighthouse |
| Responsiveness | 모바일(360px) ~ 데스크톱(1440px) 대응 | 브라우저 테스트 |
| Accessibility | 터치 영역 48px 이상, 충분한 폰트 크기 (아이 사용 고려) | 수동 검증 |

---

## 4. Success Criteria

### 4.1 Definition of Done

- [ ] 145마리 이상 캐릭터 데이터 자동 수집 완료
- [ ] 음절 조합 퀴즈 플로우 (시작 → 난이도/시즌 선택 → 문제풀기 → 결과) 정상 동작
- [ ] 모바일에서 터치로 원활히 플레이 가능
- [ ] 정답/오답 피드백 + 되돌리기가 직관적으로 동작

### 4.2 Quality Criteria

- [ ] Zero lint errors
- [ ] Build succeeds (정적 배포 가능)
- [ ] 이미지 최적화 (WebP, 400x400 통일)

---

## 5. Risks and Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **캐릭터 이미지 저작권 (스토어 배포)** | **Critical** | **High** | **스토어 배포 = 상업 배포. SAMG Entertainment 사전 허가 필수. 허가 불가 시 AI 생성 이미지 또는 실루엣 대안** |
| 스토어 심사 리젝 | High | Medium | Apple/Google 가이드라인 사전 검토. 아동 대상 앱 → COPPA/개인정보 정책 필수 |
| Fandom Wiki API 변경/차단 | Medium | Low | 1회 수집 후 로컬 assets 보관, 주기적 갱신 스크립트 |
| 캐릭터 145종 데이터 관리 | Medium | Low | 자동 수집 파이프라인 + JSON 구조화 |
| 아이 사용자의 UX 미스매치 | Medium | Medium | 큰 타일(48dp+), 큰 폰트, 밝은 색상, 단순 인터랙션 |
| 한글 음절 분리 오류 | Low | Low | Dart 한글 처리 로직 테스트 철저 |
| 앱 번들 사이즈 (145종 이미지) | Medium | Medium | WebP 압축 + 400x400 통일, 필요시 시즌별 분리 다운로드 |

---

## 6. Architecture Considerations

### 6.1 Project Level Selection

| Level | Characteristics | Recommended For | Selected |
|-------|-----------------|-----------------|:--------:|
| **Starter** | Simple structure (`components/`, `lib/`, `types/`) | Static sites, portfolios, landing pages | |
| **Dynamic** | Feature-based modules, BaaS integration | Web apps with backend, SaaS MVPs | **O** |
| **Enterprise** | Strict layer separation, DI, microservices | High-traffic systems | |

> Dynamic 선택 이유: Flutter 앱 + 스토어 배포로 모바일 네이티브 기능(로컬 스토리지, 앱 라이프사이클 등) 필요

### 6.2 Key Architectural Decisions

| Decision | Options | Selected | Rationale |
|----------|---------|----------|-----------|
| Framework | Flutter / React Native / Next.js | **Flutter** | 단일 코드베이스로 iOS/Android 동시 지원, 높은 UI 커스텀 자유도 |
| Language | Dart / TypeScript / Kotlin | **Dart** | Flutter 네이티브 언어 |
| State Management | setState / Provider / Riverpod / Bloc | **Riverpod** | 간결한 상태관리, 퀴즈 상태에 적합 |
| Data | 로컬 JSON (assets) / API | **로컬 JSON (assets)** | 서버 불필요, 앱 번들에 포함 |
| Image Format | PNG / WebP | **WebP** | 용량 최적화, Flutter 기본 지원 |
| Deploy | App Store + Play Store | **양대 스토어** | iOS/Android 네이티브 배포 |
| Data Collection | 수동 / 자동 | **Python 자동 수집** | 145종 수동 불가 |

### 6.3 배포 전략

| 플랫폼 | 빌드 | 배포처 | 비고 |
|--------|------|--------|------|
| Android | `flutter build appbundle` | Google Play Store | AAB 형식 |
| iOS | `flutter build ipa` | Apple App Store | Xcode 서명 필요 |

### 6.4 Clean Architecture Approach

```
Selected Level: Dynamic (Flutter)

Folder Structure Preview:
┌─────────────────────────────────────────────────────┐
│ lib/                                                │
│   main.dart                # 앱 진입점               │
│   app.dart                 # MaterialApp 설정        │
│                                                      │
│   screens/                                          │
│     home_screen.dart       # 시작 화면 (시즌/난이도)   │
│     quiz_screen.dart       # 퀴즈 화면               │
│     result_screen.dart     # 결과 화면               │
│                                                      │
│   widgets/                                          │
│     quiz_card.dart         # 캐릭터 이미지 카드        │
│     syllable_tile.dart     # 음절 타일 버튼           │
│     answer_slots.dart      # 정답 입력 슬롯           │
│     progress_bar.dart      # 진행률 바               │
│     difficulty_selector.dart # 난이도 선택            │
│     season_filter.dart     # 시즌별 필터              │
│     feedback_overlay.dart  # 정답/오답 피드백          │
│                                                      │
│   models/                                           │
│     character.dart         # Character 데이터 모델    │
│     quiz_state.dart        # 퀴즈 상태 모델           │
│                                                      │
│   providers/                                        │
│     quiz_provider.dart     # Riverpod 퀴즈 상태관리   │
│                                                      │
│   services/                                         │
│     quiz_service.dart      # 퀴즈 로직 (출제, 검증)    │
│     syllable_service.dart  # 한글 음절 분리/조합       │
│     character_service.dart # JSON 로드 + 필터링       │
│                                                      │
│   utils/                                            │
│     constants.dart         # 상수 (색상, 난이도 설정)   │
│                                                      │
│ assets/                                             │
│   data/                                             │
│     characters.json        # 티니핑 캐릭터 데이터      │
│   images/                                           │
│     tiniping/              # 캐릭터 이미지 (WebP)     │
│                                                      │
│ scripts/                                            │
│   collect_characters.py    # Fandom Wiki 자동 수집    │
│                                                      │
│ android/                   # Android 네이티브 설정     │
│ ios/                       # iOS 네이티브 설정         │
└─────────────────────────────────────────────────────┘
```

---

## 7. Content Pipeline (콘텐츠 자동 수집)

### 7.1 데이터 소스

| 소스 | URL | 제공 정보 | 수집 방법 |
|------|-----|----------|----------|
| Fandom Wiki | catchteenieping.fandom.com | 캐릭터명(영/한), 이미지, 분류, 시즌 | MediaWiki API |
| 나무위키 | namu.wiki/w/티니핑 | 한글명, 상세 분류, 시즌 매핑 | WebFetch (보조) |

### 7.2 자동 수집 파이프라인

```
┌─────────────────────────────────────────────────────┐
│ scripts/collect-characters.py                       │
│                                                      │
│ Step 1: MediaWiki API로 Category:Teeniepings 목록 조회│
│   GET /api.php?action=query&list=categorymembers    │
│   &cmtitle=Category:Teeniepings&cmlimit=500         │
│                                                      │
│ Step 2: 각 캐릭터 페이지에서 데이터 추출               │
│   - 영문명, 한글명                                    │
│   - 시즌/카테고리 (Emotion, Jewel, Key, Dessert...)   │
│   - 이미지 URL (API:Imageinfo)                       │
│                                                      │
│ Step 3: 이미지 다운로드 + 후처리                       │
│   - 400x400 리사이즈                                  │
│   - WebP 변환 (용량 최적화)                            │
│   - public/images/tiniping/{ticker}.webp 저장         │
│                                                      │
│ Step 4: characters.json 생성                          │
│   [{name, nameKo, season, category, imageFile}, ...]│
│                                                      │
│ Rate Limit: 10 req/min (Fandom 정책 준수)            │
└─────────────────────────────────────────────────────┘
```

### 7.3 기술 스택

| 도구 | 용도 |
|------|------|
| Python `requests` | MediaWiki API 호출 |
| `pymediawiki` | 페이지 파싱 헬퍼 |
| `Pillow` | 이미지 리사이즈 + WebP 변환 |
| JSON 출력 | `data/characters.json` |

### 7.4 저작권 대응

- 앱 내 "비상업 팬 프로젝트" 명시
- 이미지 출처(Fandom Wiki) 표기
- 상업 배포 시 SAMG Entertainment 사전 허가 필요
- robots.txt 및 Fandom 이용약관 준수

---

## 8. Convention Prerequisites

### 8.1 Existing Project Conventions

- [ ] `CLAUDE.md` has coding conventions section
- [ ] ESLint configuration
- [ ] Prettier configuration
- [ ] TypeScript configuration (`tsconfig.json`)

> 신규 프로젝트이므로 Next.js 기본 설정 + Tailwind로 초기화 예정

### 8.2 Conventions to Define/Verify

| Category | Current State | To Define | Priority |
|----------|---------------|-----------|:--------:|
| **Naming** | missing | 클래스: PascalCase, 파일: snake_case.dart (Dart 컨벤션) | High |
| **Folder structure** | missing | Dynamic 레벨 Flutter 구조 (위 참조) | High |
| **Styling** | missing | Material Design 3 + 커스텀 테마 | Medium |
| **State Management** | missing | Riverpod 패턴 | High |

### 8.3 Environment Variables Needed

| Variable | Purpose | Scope | To Be Created |
|----------|---------|-------|:-------------:|
| 없음 | 오프라인 앱으로 환경변수 불필요 | - | - |

---

## 9. Next Steps

1. [ ] Design 문서 작성 (`/pdca design tiniping-name-quiz`)
2. [ ] Python 수집 스크립트 개발 (`scripts/collect-characters.py`)
3. [ ] 수집 결과 검증 (145종 이상 확보 확인)
4. [ ] Next.js + Tailwind 프로젝트 초기화
5. [ ] 음절 분리/조합 핵심 로직 구현
6. [ ] UI 컴포넌트 구현 및 반응형 테스트

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-03-19 | Initial draft (4지선다 방식) | seomihye |
| 0.2 | 2026-03-19 | 음절 조합 방식 전환, 난이도 시스템, 콘텐츠 자동 수집 파이프라인 추가 | seomihye |
| 0.3 | 2026-03-19 | Next.js → Flutter 전환, iOS/Android 스토어 배포 전략, 저작권 리스크 강화 | seomihye |
| 0.4 | 2026-03-19 | 난이도별 이미지 효과(블러/모자이크/실루엣), 정답 후 원본 런타임 로딩+빨간 동그라미 효과, 오프라인 감지 | seomihye |
