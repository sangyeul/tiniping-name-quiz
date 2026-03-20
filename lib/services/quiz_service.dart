import 'dart:math';
import '../models/character.dart';
import '../models/quiz_state.dart';
import '../utils/constants.dart';
import 'syllable_service.dart';

class QuizService {
  /// 퀴즈 문제 생성
  static List<Question> generateQuestions({
    required List<Character> characters,
    required int count,
    required Difficulty difficulty,
  }) {
    final random = Random(DateTime.now().microsecondsSinceEpoch);
    final config = difficultyConfigs[difficulty]!;
    final shuffled = [...characters]..shuffle(random);
    final selected = count > 0 && count < shuffled.length
        ? shuffled.take(count).toList()
        : shuffled;

    return selected.map((character) {
      final answerSyllables = splitSyllables(character.nameKo);
      final decoys = generateDecoys(
        answerSyllables,
        characters,
        config.decoyCount,
      );
      final tiles = buildShuffledTiles(answerSyllables, decoys);

      return Question(
        character: character,
        syllables: tiles,
        answerSyllables: answerSyllables,
      );
    }).toList();
  }

  /// 정답 검증
  static bool checkAnswer(List<String> selected, List<String> answer) {
    if (selected.length != answer.length) return false;
    return selected.join('') == answer.join('');
  }
}
