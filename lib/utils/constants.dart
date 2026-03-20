import 'package:flutter/material.dart';

// -- Colors --
class AppColors {
  static const primary = Color(0xFFFF6B9D);
  static const secondary = Color(0xFF4ECDC4);
  static const success = Color(0xFF2ECC71);
  static const error = Color(0xFFE74C3C);
  static const background = Color(0xFFFFF0F5);
  static const tileDefault = Color(0xFFFFFFFF);
  static const tileSelected = Color(0xFFDDA0DD);
  static const silhouetteColor = Color(0xFFFF6B9D);
}

// -- Difficulty --
enum Difficulty { easy, normal, hard }

class DifficultyConfig {
  final int decoyCount;
  final bool showLetterCount;
  final String imageEffect; // 'blur', 'mosaic', 'silhouette'
  final String label;

  const DifficultyConfig({
    required this.decoyCount,
    required this.showLetterCount,
    required this.imageEffect,
    required this.label,
  });
}

const difficultyConfigs = {
  Difficulty.easy: DifficultyConfig(
    decoyCount: 2,
    showLetterCount: true,
    imageEffect: 'blur',
    label: '쉬움',
  ),
  Difficulty.normal: DifficultyConfig(
    decoyCount: 3,
    showLetterCount: true,
    imageEffect: 'mosaic',
    label: '보통',
  ),
  Difficulty.hard: DifficultyConfig(
    decoyCount: 5,
    showLetterCount: false,
    imageEffect: 'silhouette',
    label: '어려움',
  ),
};

// -- Quiz --
const defaultQuizCount = 10;
const quizCountOptions = [10, 20, 0]; // 0 = 전체

// -- Seasons --
const seasonLabels = {
  1: '1기 감정',
  2: '2기 보석',
  3: '3기 열쇠',
  4: '4기 디저트',
  5: '5기 스타',
  6: '6기 프린세스',
};
