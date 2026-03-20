import 'package:flutter_test/flutter_test.dart';
import 'package:tiniping_name_quiz/models/character.dart';
import 'package:tiniping_name_quiz/services/quiz_service.dart';
import 'package:tiniping_name_quiz/utils/constants.dart';

void main() {
  final testCharacters = [
    const Character(
      id: 'heartsping', name: 'Heartsping', nameKo: '하츄핑',
      season: 1, category: 'emotion', grade: 'royal',
      imageFile: 'heartsping.webp', imageUrl: '',
    ),
    const Character(
      id: 'baroping', name: 'Correctping', nameKo: '바로핑',
      season: 1, category: 'emotion', grade: 'royal',
      imageFile: 'baroping.webp', imageUrl: '',
    ),
    const Character(
      id: 'aloneping', name: 'Aloneping', nameKo: '홀로',
      season: 1, category: 'emotion', grade: 'normal',
      imageFile: 'aloneping.webp', imageUrl: '',
    ),
    const Character(
      id: 'artping', name: 'Artping', nameKo: '그림',
      season: 1, category: 'emotion', grade: 'normal',
      imageFile: 'artping.webp', imageUrl: '',
    ),
    const Character(
      id: 'curieping', name: 'Curieping', nameKo: '모야핑',
      season: 1, category: 'emotion', grade: 'normal',
      imageFile: 'curieping.webp', imageUrl: '',
    ),
  ];

  group('generateQuestions', () {
    test('지정된 문제 수만큼 생성', () {
      final questions = QuizService.generateQuestions(
        characters: testCharacters,
        count: 3,
        difficulty: Difficulty.easy,
      );
      expect(questions.length, 3);
    });

    test('count가 0이면 전체 캐릭터 출제', () {
      final questions = QuizService.generateQuestions(
        characters: testCharacters,
        count: 0,
        difficulty: Difficulty.easy,
      );
      expect(questions.length, testCharacters.length);
    });

    test('난이도별 방해 음절 수', () {
      final easyQ = QuizService.generateQuestions(
        characters: testCharacters,
        count: 1,
        difficulty: Difficulty.easy,
      ).first;
      final answerLen = easyQ.answerSyllables.length;
      final decoyCount = easyQ.syllables.length - answerLen;
      expect(decoyCount, difficultyConfigs[Difficulty.easy]!.decoyCount);
    });

    test('각 문제에 정답 음절이 포함됨', () {
      final questions = QuizService.generateQuestions(
        characters: testCharacters,
        count: 3,
        difficulty: Difficulty.normal,
      );
      for (final q in questions) {
        for (final s in q.answerSyllables) {
          expect(q.syllables.contains(s), true);
        }
      }
    });
  });

  group('checkAnswer', () {
    test('올바른 순서 → 정답', () {
      expect(QuizService.checkAnswer(['하', '츄', '핑'], ['하', '츄', '핑']), true);
    });

    test('잘못된 순서 → 오답', () {
      expect(QuizService.checkAnswer(['츄', '하', '핑'], ['하', '츄', '핑']), false);
    });

    test('길이 다름 → 오답', () {
      expect(QuizService.checkAnswer(['하', '츄'], ['하', '츄', '핑']), false);
    });
  });
}
