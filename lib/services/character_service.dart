import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/character.dart';

class CharacterService {
  List<Character>? _cache;

  /// assets/data/characters.json 로드
  Future<List<Character>> loadCharacters() async {
    if (_cache != null) return _cache!;

    final jsonStr = await rootBundle.loadString('assets/data/characters.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    _cache = jsonList.map((j) => Character.fromJson(j)).toList();
    return _cache!;
  }

  /// 시즌 필터링
  Future<List<Character>> getBySeasons(List<int> seasons) async {
    final all = await loadCharacters();
    if (seasons.isEmpty) return all;
    return all.where((c) => seasons.contains(c.season)).toList();
  }

  /// 시즌별 캐릭터 수
  Future<Map<int, int>> getSeasonCounts() async {
    final all = await loadCharacters();
    final counts = <int, int>{};
    for (final c in all) {
      counts[c.season] = (counts[c.season] ?? 0) + 1;
    }
    return counts;
  }
}
