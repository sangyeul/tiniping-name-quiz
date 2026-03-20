import 'package:flutter_test/flutter_test.dart';
import 'package:tiniping_name_quiz/models/character.dart';
import 'package:tiniping_name_quiz/services/syllable_service.dart';

void main() {
  group('splitSyllables', () {
    test('한글 이름을 음절 단위로 분리', () {
      expect(splitSyllables('하츄핑'), ['하', '츄', '핑']);
    });

    test('2글자 이름', () {
      expect(splitSyllables('홀로'), ['홀', '로']);
    });

    test('4글자 이름', () {
      expect(splitSyllables('깜빡핑'), ['깜', '빡', '핑']);
    });
  });

  group('generateDecoys', () {
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
    ];

    test('지정된 개수만큼 방해 음절 생성', () {
      final answer = ['하', '츄', '핑'];
      final decoys = generateDecoys(answer, testCharacters, 2);
      expect(decoys.length, 2);
    });

    test('정답 음절과 중복 없음', () {
      final answer = ['하', '츄', '핑'];
      final decoys = generateDecoys(answer, testCharacters, 3);
      for (final d in decoys) {
        expect(answer.contains(d), false);
      }
    });
  });

  group('buildShuffledTiles', () {
    test('정답 + 방해 음절 모두 포함', () {
      final answer = ['하', '츄', '핑'];
      final decoys = ['바', '로'];
      final tiles = buildShuffledTiles(answer, decoys);
      expect(tiles.length, 5);
      expect(tiles.toSet(), {'하', '츄', '핑', '바', '로'});
    });
  });
}
