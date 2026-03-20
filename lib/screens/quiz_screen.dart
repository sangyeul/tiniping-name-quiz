import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_state.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import '../widgets/answer_slots.dart';
import '../widgets/feedback_overlay.dart';
import '../widgets/hint_button.dart';
import '../widgets/quiz_card.dart';
import '../widgets/syllable_tile.dart';
import 'result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  Timer? _timer;
  int _secondsLeft = 10;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final quizState = ref.read(quizProvider);
      if (quizState == null || quizState.phase != QuizPhase.playing) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsLeft--;
      });
      if (_secondsLeft <= 0) {
        timer.cancel();
        ref.read(quizProvider.notifier).onTimeout();
      }
    });
  }

  void _onNextQuestion() {
    ref.read(quizProvider.notifier).nextQuestion();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);

    if (quizState == null) {
      return const Scaffold(
        body: Center(child: Text('퀴즈 데이터가 없습니다')),
      );
    }

    if (quizState.phase == QuizPhase.finished) {
      _timer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      });
      return const SizedBox.shrink();
    }

    final question = quizState.currentQuestion;
    final config = difficultyConfigs[quizState.difficulty]!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 상단 바: 진행률 + 타이머 + 점수
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        quizState.progressText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (quizState.currentIndex + 1) /
                                quizState.totalQuestions,
                            backgroundColor: Colors.grey.shade200,
                            color: AppColors.primary,
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 타이머
                      _buildTimer(),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 22),
                          const SizedBox(width: 4),
                          Text(
                            '${quizState.score}점',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 캐릭터 이미지
                QuizCard(
                  character: question.character,
                  difficulty: quizState.difficulty,
                ),
                const SizedBox(height: 12),

                // 힌트
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: HintButton(
                      hintCount: quizState.hintCount,
                      hintUsed: quizState.hintUsed,
                      character: question.character,
                      onUseHint: () =>
                          ref.read(quizProvider.notifier).useHint(),
                      onWatchAd: () =>
                          ref.read(quizProvider.notifier).watchAdForHints(),
                    ),
                  ),

                const SizedBox(height: 16),

                // 정답 슬롯 + 삭제 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnswerSlots(
                      totalSlots: question.answerSyllables.length,
                      filledSyllables: quizState.selectedSyllables,
                      showLetterCount: config.showLetterCount,
                      onSlotTap: (index) {
                        ref
                            .read(quizProvider.notifier)
                            .removeSyllableAt(index);
                      },
                    ),
                    if (quizState.selectedSyllables.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: () => ref
                              .read(quizProvider.notifier)
                              .undoLastSyllable(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Icon(
                              Icons.backspace_outlined,
                              color: AppColors.error,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // 음절 타일
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: _buildTiles(
                      question.syllables,
                      quizState.selectedSyllables,
                      ref,
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),

            // 피드백 오버레이 (정답/오답/타임아웃)
            if (quizState.phase == QuizPhase.correct ||
                quizState.phase == QuizPhase.wrong ||
                quizState.phase == QuizPhase.timeout)
              FeedbackOverlay(
                isCorrect: quizState.phase == QuizPhase.correct,
                character: question.character,
                onTap: _onNextQuestion,
                isTimeout: quizState.phase == QuizPhase.timeout,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final color = _secondsLeft <= 3 ? AppColors.error : AppColors.secondary;
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: _secondsLeft / 10,
            strokeWidth: 3,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
          Text(
            '$_secondsLeft',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTiles(
    List<String> allTiles,
    List<String> selected,
    WidgetRef ref,
  ) {
    final usedIndices = <int>{};
    for (final sel in selected) {
      for (int i = 0; i < allTiles.length; i++) {
        if (allTiles[i] == sel && !usedIndices.contains(i)) {
          usedIndices.add(i);
          break;
        }
      }
    }

    return List.generate(allTiles.length, (index) {
      final isUsed = usedIndices.contains(index);
      return SyllableTile(
        syllable: allTiles[index],
        isUsed: isUsed,
        onTap: () {
          ref.read(quizProvider.notifier).selectSyllable(allTiles[index]);
        },
      );
    });
  }
}
