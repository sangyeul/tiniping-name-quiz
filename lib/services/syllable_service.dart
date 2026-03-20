import 'dart:math';
import '../models/character.dart';

/// 한글 이름을 음절 단위로 분리
/// "하츄핑" → ["하", "츄", "핑"]
List<String> splitSyllables(String name) {
  return name.split('');
}

/// 방해 음절 생성
/// - 다른 캐릭터 이름에서 랜덤 음절 추출
/// - 정답 음절과 중복 제거
List<String> generateDecoys(
  List<String> answerSyllables,
  List<Character> allCharacters,
  int count,
) {
  final random = Random(DateTime.now().microsecondsSinceEpoch);
  final answerSet = answerSyllables.toSet();

  // 모든 캐릭터 이름에서 음절 풀 생성
  final pool = <String>{};
  for (final char in allCharacters) {
    for (final s in splitSyllables(char.nameKo)) {
      if (!answerSet.contains(s)) {
        pool.add(s);
      }
    }
  }

  final poolList = pool.toList()..shuffle(random);
  return poolList.take(count).toList();
}

/// 정답 음절 + 방해 음절을 섞어서 반환
List<String> buildShuffledTiles(
  List<String> answerSyllables,
  List<String> decoys,
) {
  final tiles = [...answerSyllables, ...decoys];
  tiles.shuffle(Random(DateTime.now().microsecondsSinceEpoch));
  return tiles;
}
