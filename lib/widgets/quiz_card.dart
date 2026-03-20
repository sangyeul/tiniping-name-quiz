import 'package:flutter/material.dart';
import '../models/character.dart';
import '../utils/constants.dart';

class QuizCard extends StatelessWidget {
  final Character character;
  final Difficulty difficulty;

  const QuizCard({
    super.key,
    required this.character,
    required this.difficulty,
  });

  String _imagePath() {
    final config = difficultyConfigs[difficulty]!;
    final effect = config.imageEffect;
    return 'assets/images/tiniping/${character.id}_$effect.webp';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          _imagePath(),
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
