import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../utils/constants.dart';

class FeedbackOverlay extends StatefulWidget {
  final bool isCorrect;
  final Character character;
  final VoidCallback onTap;
  final bool isTimeout;

  const FeedbackOverlay({
    super.key,
    required this.isCorrect,
    required this.character,
    required this.onTap,
    this.isTimeout = false,
  });

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late Animation<double> _circleScale;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Fade in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    // Red circle bounce (correct only)
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _circleScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeOut),
    );

    // Shake (wrong only)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeController);

    if (widget.isCorrect) {
      _circleController.forward();
    } else {
      _shakeController.forward();
    }
  }

  @override
  void dispose() {
    _circleController.dispose();
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          color: Colors.black54,
          child: Center(
            child: AnimatedBuilder(
              animation: _shakeAnim,
              builder: (context, child) {
                final offset = widget.isCorrect
                    ? 0.0
                    : sin(_shakeAnim.value * pi * 4) * 8;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isCorrect
                          ? Icons.check_circle
                          : widget.isTimeout
                              ? Icons.timer_off
                              : Icons.cancel,
                      color: widget.isCorrect
                          ? AppColors.success
                          : AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isCorrect
                          ? '정답!'
                          : widget.isTimeout
                              ? '시간 초과!'
                              : '아쉬워요!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: widget.isCorrect
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 원본 이미지 + 빨간 동그라미
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: widget.character.imageUrl,
                              width: 180,
                              height: 180,
                              fit: BoxFit.contain,
                              placeholder: (_, _) => const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                              errorWidget: (_, _, _) => Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.wifi_off,
                                          size: 32, color: Colors.grey),
                                      SizedBox(height: 4),
                                      Text(
                                        '이미지를 불러올 수 없어요',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (widget.isCorrect)
                            AnimatedBuilder(
                              animation: _circleScale,
                              builder: (context, _) {
                                return Transform.scale(
                                  scale: _circleScale.value,
                                  child: IgnorePointer(
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.error
                                              .withValues(alpha: 0.7),
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      widget.character.nameKo,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.isCorrect) ...[
                      const SizedBox(height: 4),
                      const Text(
                        '+1점',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      '탭하면 다음 문제 →',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
