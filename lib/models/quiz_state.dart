import 'character.dart';
import '../utils/constants.dart';

class Question {
  final Character character;
  final List<String> syllables; // 정답 + 방해 음절 (셔플됨)
  final List<String> answerSyllables; // 정답 음절 순서대로

  const Question({
    required this.character,
    required this.syllables,
    required this.answerSyllables,
  });
}

class QuizState {
  final List<Question> questions;
  final int currentIndex;
  final int score;
  final Difficulty difficulty;
  final List<int> selectedSeasons;
  final List<String> selectedSyllables; // 현재 문제에서 선택한 음절
  final QuizPhase phase;
  final List<bool> results; // 각 문제별 정답 여부
  final int hintCount; // 남은 힌트 횟수
  final bool hintUsed; // 현재 문제에서 힌트 사용 여부
  final QuizMode mode; // 퀴즈 모드

  const QuizState({
    required this.questions,
    this.currentIndex = 0,
    this.score = 0,
    required this.difficulty,
    required this.selectedSeasons,
    this.selectedSyllables = const [],
    this.phase = QuizPhase.playing,
    this.results = const [],
    this.hintCount = 0,
    this.hintUsed = false,
    this.mode = QuizMode.nameQuiz,
  });

  Question get currentQuestion => questions[currentIndex];
  bool get isLastQuestion => currentIndex >= questions.length - 1;
  int get totalQuestions => questions.length;
  String get progressText => '${currentIndex + 1}/$totalQuestions';

  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    int? score,
    Difficulty? difficulty,
    List<int>? selectedSeasons,
    List<String>? selectedSyllables,
    QuizPhase? phase,
    List<bool>? results,
    int? hintCount,
    bool? hintUsed,
    QuizMode? mode,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      difficulty: difficulty ?? this.difficulty,
      selectedSeasons: selectedSeasons ?? this.selectedSeasons,
      selectedSyllables: selectedSyllables ?? this.selectedSyllables,
      phase: phase ?? this.phase,
      results: results ?? this.results,
      hintCount: hintCount ?? this.hintCount,
      hintUsed: hintUsed ?? this.hintUsed,
      mode: mode ?? this.mode,
    );
  }
}

enum QuizPhase { playing, correct, wrong, timeout, finished }
enum QuizMode { nameQuiz, imageQuiz }
