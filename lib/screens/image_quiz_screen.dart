import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_state.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import '../widgets/feedback_overlay.dart';
import '../widgets/hint_button.dart';
import 'result_screen.dart';

class ImageQuizScreen extends ConsumerStatefulWidget {
  const ImageQuizScreen({super.key});

  @override
  ConsumerState<ImageQuizScreen> createState() => _ImageQuizScreenState();
}

class _ImageQuizScreenState extends ConsumerState<ImageQuizScreen> {
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
    final effect = config.imageEffect;
    final choiceIds = question.syllables;
    final answerId = question.answerSyllables.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 상단 바
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                              color: AppColors.secondary,
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildTimer(),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 22),
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

                  const SizedBox(height: 8),

                  // 캐릭터 이름 + 힌트 (한 줄)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        question.character.nameKo,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      HintButton(
                        hintCount: quizState.hintCount,
                        hintUsed: quizState.hintUsed,
                        character: question.character,
                        onUseHint: () =>
                            ref.read(quizProvider.notifier).useHint(),
                        onWatchAd: () =>
                            ref.read(quizProvider.notifier).watchAdForHints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 4지선다 이미지 그리드
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 남은 높이에 맞게 2행이 딱 들어가도록 비율 계산
                        final availableHeight = constraints.maxHeight;
                        final availableWidth = constraints.maxWidth;
                        final cellHeight = (availableHeight - 10) / 2;
                        final cellWidth = (availableWidth - 10) / 2;
                        final aspectRatio = cellWidth / cellHeight;

                        return GridView.count(
                          crossAxisCount: 2,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: aspectRatio,
                      children: choiceIds.map((id) {
                        final isSelected =
                            quizState.selectedSyllables.contains(id);
                        final isAnswer = id == answerId;
                        final showResult =
                            quizState.phase != QuizPhase.playing;

                        return GestureDetector(
                          onTap: quizState.phase == QuizPhase.playing
                              ? () => ref
                                  .read(quizProvider.notifier)
                                  .selectImage(id)
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: showResult
                                    ? (isAnswer
                                        ? AppColors.success
                                        : (isSelected
                                            ? AppColors.error
                                            : Colors.grey.shade200))
                                    : Colors.grey.shade200,
                                width: showResult && (isAnswer || isSelected)
                                    ? 3
                                    : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                'assets/images/tiniping/${id}_$effect.webp',
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // 피드백 오버레이
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
}
