import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import '../models/quiz_state.dart';
import '../services/character_service.dart';
import '../services/quiz_service.dart';
import '../utils/constants.dart';

final characterServiceProvider = Provider((ref) => CharacterService());

final charactersProvider = FutureProvider<List<Character>>((ref) {
  return ref.read(characterServiceProvider).loadCharacters();
});

final quizProvider = NotifierProvider<QuizNotifier, QuizState?>(
  QuizNotifier.new,
);

class QuizNotifier extends Notifier<QuizState?> {
  @override
  QuizState? build() => null;

  /// 이름 맞추기 퀴즈 시작
  Future<void> startQuiz({
    required Difficulty difficulty,
    required List<int> seasons,
    required int count,
  }) async {
    final service = ref.read(characterServiceProvider);
    final characters = await service.getBySeasons(seasons);

    if (characters.isEmpty) return;

    final questions = QuizService.generateQuestions(
      characters: characters,
      count: count,
      difficulty: difficulty,
    );

    state = QuizState(
      questions: questions,
      difficulty: difficulty,
      selectedSeasons: seasons,
      mode: QuizMode.nameQuiz,
    );
  }

  /// 역퀴즈 (이름 → 이미지 맞추기) 시작
  Future<void> startImageQuiz({
    required Difficulty difficulty,
    required List<int> seasons,
    required int count,
  }) async {
    final service = ref.read(characterServiceProvider);
    final characters = await service.getBySeasons(seasons);

    if (characters.length < 4) return;

    final random = Random(DateTime.now().microsecondsSinceEpoch);
    final shuffled = [...characters]..shuffle(random);
    final selected = count > 0 && count < shuffled.length
        ? shuffled.take(count).toList()
        : shuffled;

    // 각 문제: 정답 1 + 오답 3 = 4지선다 이미지
    final questions = selected.map((character) {
      // 다른 시즌 캐릭터를 우선, 같은 시즌은 뒤로
      final others = characters.where((c) => c.id != character.id).toList()
        ..shuffle(random)
        ..sort((a, b) {
          final aDiff = a.season != character.season ? 0 : 1;
          final bDiff = b.season != character.season ? 0 : 1;
          return aDiff.compareTo(bDiff);
        });
      final choices = [character, ...others.take(3)]..shuffle(random);

      return Question(
        character: character,
        syllables: choices.map((c) => c.id).toList(), // 이미지 ID를 syllables에 저장
        answerSyllables: [character.id], // 정답 ID
      );
    }).toList();

    state = QuizState(
      questions: questions,
      difficulty: difficulty,
      selectedSeasons: seasons,
      mode: QuizMode.imageQuiz,
    );
  }

  /// 음절 타일 선택 (이름 퀴즈)
  void selectSyllable(String syllable) {
    if (state == null || state!.phase != QuizPhase.playing) return;

    final current = state!;
    final maxLen = current.currentQuestion.answerSyllables.length;

    if (current.selectedSyllables.length >= maxLen) return;

    final newSelected = [...current.selectedSyllables, syllable];
    state = current.copyWith(selectedSyllables: newSelected);

    if (newSelected.length == maxLen) {
      _checkAnswer();
    }
  }

  /// 이미지 선택 (역퀴즈)
  void selectImage(String characterId) {
    if (state == null || state!.phase != QuizPhase.playing) return;

    state = state!.copyWith(selectedSyllables: [characterId]);
    _checkAnswer();
  }

  /// 되돌리기
  void undoLastSyllable() {
    if (state == null || state!.phase != QuizPhase.playing) return;
    if (state!.selectedSyllables.isEmpty) return;

    final newSelected = [...state!.selectedSyllables]..removeLast();
    state = state!.copyWith(selectedSyllables: newSelected);
  }

  /// 특정 슬롯 위치의 음절 제거
  void removeSyllableAt(int index) {
    if (state == null || state!.phase != QuizPhase.playing) return;
    if (index >= state!.selectedSyllables.length) return;

    final newSelected = [...state!.selectedSyllables]..removeAt(index);
    state = state!.copyWith(selectedSyllables: newSelected);
  }

  /// 광고 보고 힌트 획득 (현재는 바로 지급)
  void watchAdForHints() {
    if (state == null) return;
    state = state!.copyWith(hintCount: state!.hintCount + 3);
  }

  /// 힌트 사용 (원본 이미지 1/3 노출)
  void useHint() {
    if (state == null || state!.hintCount <= 0 || state!.hintUsed) return;
    state = state!.copyWith(
      hintCount: state!.hintCount - 1,
      hintUsed: true,
    );
  }

  /// 정답 검증
  void _checkAnswer() {
    if (state == null) return;

    final isCorrect = QuizService.checkAnswer(
      state!.selectedSyllables,
      state!.currentQuestion.answerSyllables,
    );

    state = state!.copyWith(
      phase: isCorrect ? QuizPhase.correct : QuizPhase.wrong,
      score: isCorrect ? state!.score + 1 : state!.score,
      results: [...state!.results, isCorrect],
    );
  }

  /// 타임아웃 (시간 초과)
  void onTimeout() {
    if (state == null || state!.phase != QuizPhase.playing) return;
    state = state!.copyWith(
      phase: QuizPhase.timeout,
      results: [...state!.results, false],
    );
  }

  /// 다음 문제로 이동
  void nextQuestion() {
    if (state == null) return;

    if (state!.isLastQuestion) {
      state = state!.copyWith(phase: QuizPhase.finished);
      return;
    }

    state = state!.copyWith(
      currentIndex: state!.currentIndex + 1,
      selectedSyllables: [],
      phase: QuizPhase.playing,
      hintUsed: false,
    );
  }

  /// 퀴즈 리셋
  void reset() {
    state = null;
  }
}
