import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const ProviderScope(child: TinipingQuizApp()));
}

class TinipingQuizApp extends StatelessWidget {
  const TinipingQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '티니핑 이름 맞추기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: AppColors.primary,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const HomeScreen(),
    );
  }
}
