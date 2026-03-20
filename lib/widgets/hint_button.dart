import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../utils/constants.dart';

/// 힌트 버튼 + 원본 이미지 1/3 노출
class HintButton extends StatelessWidget {
  final int hintCount;
  final bool hintUsed;
  final Character character;
  final VoidCallback onUseHint;
  final VoidCallback onWatchAd;

  const HintButton({
    super.key,
    required this.hintCount,
    required this.hintUsed,
    required this.character,
    required this.onUseHint,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    // 힌트 사용 후 → 1/3 이미지 표시
    if (hintUsed) {
      return _buildHintImage();
    }

    // 힌트 있음 → 사용 버튼
    if (hintCount > 0) {
      return _buildUseHintButton();
    }

    // 힌트 없음 → 광고 버튼
    return _buildWatchAdButton();
  }

  Widget _buildHintImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: character.imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              placeholder: (_, _) => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
              errorWidget: (_, _, _) => const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
              ),
            ),
            // 2/3를 가리는 오버레이
            Positioned(
              top: 40, // 상단 1/3만 보이게
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.secondary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                ),
                child: const Center(
                  child: Text(
                    '?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUseHintButton() {
    return TextButton.icon(
      onPressed: onUseHint,
      icon: const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
      label: Text(
        '힌트 ($hintCount)',
        style: const TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.secondary),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildWatchAdButton() {
    return TextButton.icon(
      onPressed: onWatchAd,
      icon: const Icon(Icons.play_circle, color: AppColors.primary, size: 20),
      label: const Text(
        '광고 보고 힌트 얻기',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.primary),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
