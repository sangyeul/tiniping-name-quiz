import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import '../widgets/network_alert.dart';
import 'image_quiz_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Difficulty _difficulty = Difficulty.easy;
  final Set<int> _selectedSeasons = {};
  int _quizCount = defaultQuizCount;

  @override
  Widget build(BuildContext context) {
    final charactersAsync = ref.watch(charactersProvider);

    return NetworkAlert(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // 타이틀
              const Text(
                '티니핑 이름 맞추기',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '캐릭터를 보고 이름을 완성하세요!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // 시즌 선택
              _buildSection(
                '시즌 선택',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _seasonChip(0, '전체'),
                    ...seasonLabels.entries.map(
                      (e) => _seasonChip(e.key, e.value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 난이도 선택
              _buildSection(
                '난이도',
                Row(
                  children: Difficulty.values.map((d) {
                    final config = difficultyConfigs[d]!;
                    final isSelected = _difficulty == d;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => setState(() => _difficulty = d),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '⭐' * (d.index + 1),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  config.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // 문제 수
              _buildSection(
                '문제 수',
                Row(
                  children: quizCountOptions.map((count) {
                    final label = count == 0 ? '전체' : '$count문제';
                    final isSelected = _quizCount == count;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => setState(() => _quizCount = count),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.secondary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.secondary,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.secondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // 시작 버튼
              charactersAsync.when(
                data: (characters) {
                  final filtered = _selectedSeasons.isEmpty
                      ? characters
                      : characters
                          .where(
                              (c) => _selectedSeasons.contains(c.season))
                          .toList();
                  return Column(
                    children: [
                      Text(
                        '${filtered.length}마리 캐릭터 준비됨',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 이름 맞추기 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: filtered.isEmpty
                              ? null
                              : () => _startNameQuiz(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            '🎀 이름 맞추기',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 이미지 맞추기 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: filtered.length < 4
                              ? null
                              : () => _startImageQuiz(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            '🔍 이미지 맞추기',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                error: (e, _) => Text('데이터 로딩 실패: $e'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _seasonChip(int season, String label) {
    final isAll = season == 0;
    final isSelected = isAll
        ? _selectedSeasons.isEmpty
        : _selectedSeasons.contains(season);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isAll) {
            _selectedSeasons.clear();
          } else {
            if (_selectedSeasons.contains(season)) {
              _selectedSeasons.remove(season);
            } else {
              _selectedSeasons.add(season);
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  void _startNameQuiz() {
    ref.read(quizProvider.notifier).startQuiz(
          difficulty: _difficulty,
          seasons: _selectedSeasons.toList(),
          count: _quizCount,
        );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );
  }

  void _startImageQuiz() {
    ref.read(quizProvider.notifier).startImageQuiz(
          difficulty: _difficulty,
          seasons: _selectedSeasons.toList(),
          count: _quizCount,
        );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ImageQuizScreen()),
    );
  }
}
