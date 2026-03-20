import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import 'quiz_screen.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  String _getMessage(int score, int total) {
    final ratio = score / total;
    if (ratio >= 0.9) return '티니핑 박사!';
    if (ratio >= 0.7) return '거의 다 알고 있어요!';
    if (ratio >= 0.5) return '열심히 했어요!';
    return '다시 도전해봐요!';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);

    if (quizState == null) {
      return const Scaffold(
        body: Center(child: Text('결과 데이터가 없습니다')),
      );
    }

    final score = quizState.score;
    final total = quizState.totalQuestions;
    final message = _getMessage(score, total);

    // 틀린 문제 목록
    final wrongQuestions = <int>[];
    for (int i = 0; i < quizState.results.length; i++) {
      if (!quizState.results[i]) wrongQuestions.add(i);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Text(
                '퀴즈 완료!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // 점수
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      '$score / $total',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 틀린 문제 리뷰
              if (wrongQuestions.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '틀린 문제',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: wrongQuestions.length,
                    itemBuilder: (context, index) {
                      final qi = wrongQuestions[index];
                      final q = quizState.questions[qi];
                      final config =
                          difficultyConfigs[quizState.difficulty]!;
                      final imgPath =
                          'assets/images/tiniping/${q.character.id}_${config.imageEffect}.webp';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                imgPath,
                                width: 48,
                                height: 48,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox(width: 48, height: 48),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('→',
                                style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 12),
                            Text(
                              '정답: ${q.character.nameKo}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else
                const Spacer(),

              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(quizProvider.notifier).reset();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        '홈으로',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(quizProvider.notifier).startQuiz(
                              difficulty: quizState.difficulty,
                              seasons: quizState.selectedSeasons,
                              count: quizState.totalQuestions,
                            );
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const QuizScreen(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        '다시 하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
