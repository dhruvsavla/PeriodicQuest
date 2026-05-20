import 'package:flutter/material.dart';

class QuizElementCardStyle {
  const QuizElementCardStyle({
    required this.gradient,
    required this.borderColor,
    required this.glowColor,
    required this.foregroundColor,
    required this.badgeColor,
  });

  final Gradient gradient;
  final Color borderColor;
  final Color glowColor;
  final Color foregroundColor;
  final Color badgeColor;
}

QuizElementCardStyle quizElementCardStyleForCategory(String? categoryKey) {
  switch (categoryKey) {
    case 'noble':
      return const QuizElementCardStyle(
        gradient: LinearGradient(
          colors: [Color(0xFFE4DBFF), Color(0xFFC4D5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Color(0xFF8575D8),
        glowColor: Color(0x558575D8),
        foregroundColor: Color(0xFF2A255C),
        badgeColor: Color(0xFFF4EEFF),
      );
    case 'transition':
    case 'alkali':
    case 'alkaline':
    case 'post':
    case 'lanthanide':
    case 'actinide':
      return const QuizElementCardStyle(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE7AF), Color(0xFFFFC780)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Color(0xFFE0A33D),
        glowColor: Color(0x55E0A33D),
        foregroundColor: Color(0xFF5E3B00),
        badgeColor: Color(0xFFFFF5DD),
      );
    case 'nonmetal':
      return const QuizElementCardStyle(
        gradient: LinearGradient(
          colors: [Color(0xFFCFF5E7), Color(0xFF9DE8D0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Color(0xFF3CA887),
        glowColor: Color(0x553CA887),
        foregroundColor: Color(0xFF124F3E),
        badgeColor: Color(0xFFE8FFF8),
      );
    case 'halogen':
      return const QuizElementCardStyle(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD8E7), Color(0xFFFFB7CF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Color(0xFFD76395),
        glowColor: Color(0x55D76395),
        foregroundColor: Color(0xFF6B153D),
        badgeColor: Color(0xFFFFEFF6),
      );
    case 'metalloid':
      return const QuizElementCardStyle(
        gradient: LinearGradient(
          colors: [Color(0xFFD9F0FF), Color(0xFFB6D9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Color(0xFF5E8DD8),
        glowColor: Color(0x555E8DD8),
        foregroundColor: Color(0xFF183A67),
        badgeColor: Color(0xFFEDF7FF),
      );
    default:
      return const QuizElementCardStyle(
        gradient: LinearGradient(
          colors: [Color(0xFFF4F1FF), Color(0xFFE6E1F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Color(0xFF8C83B8),
        glowColor: Color(0x558C83B8),
        foregroundColor: Color(0xFF2C2750),
        badgeColor: Color(0xFFF9F7FF),
      );
  }
}
