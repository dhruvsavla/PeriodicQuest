import 'dart:math' as math;

import 'package:flutter/material.dart';

class StoryQuestScreen extends StatelessWidget {
  const StoryQuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, bc) {
        final w = bc.maxWidth;
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🗺️',
                  style: TextStyle(fontSize: math.min(80.0, w * 0.20)),
                ),
                SizedBox(height: w * 0.06),
                Text(
                  'Story Quest',
                  style: TextStyle(
                    fontSize: math.min(30.0, w * 0.072),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1A4A),
                  ),
                ),
                SizedBox(height: w * 0.03),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9B72D8), Color(0xFFBB90FF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Coming Soon! 🚀',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                SizedBox(height: w * 0.06),
                Text(
                  'Embark on epic chemistry adventures, solve puzzles, and become a chemistry hero — one element at a time!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: math.min(14.5, w * 0.036),
                    color: const Color(0xFF5A4A8A),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: w * 0.08),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _teaser('⚗️', 'Mix\nelements'),
                    SizedBox(width: w * 0.06),
                    _teaser('🏆', 'Earn\nstars'),
                    SizedBox(width: w * 0.06),
                    _teaser('🔓', 'Unlock\nlevels'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _teaser(String emoji, String label) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFF0E8FF),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4B8FF), width: 2),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF7B4FCC),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
