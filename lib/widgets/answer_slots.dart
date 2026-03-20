import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AnswerSlots extends StatelessWidget {
  final int totalSlots;
  final List<String> filledSyllables;
  final bool showLetterCount;
  final void Function(int index)? onSlotTap;

  const AnswerSlots({
    super.key,
    required this.totalSlots,
    required this.filledSyllables,
    this.showLetterCount = true,
    this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSlots, (index) {
        final isFilled = index < filledSyllables.length;
        final syllable = isFilled ? filledSyllables[index] : null;

        return GestureDetector(
          onTap: isFilled ? () => onSlotTap?.call(index) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isFilled ? AppColors.tileSelected : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFilled
                    ? AppColors.primary
                    : showLetterCount
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: isFilled
                  ? Text(
                      syllable!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                  : showLetterCount
                      ? Text(
                          '_',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        )
                      : null,
            ),
          ),
        );
      }),
    );
  }
}
