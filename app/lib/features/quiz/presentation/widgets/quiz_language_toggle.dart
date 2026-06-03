import 'package:flutter/material.dart';

import 'package:app/features/quiz/models/quiz_language.dart';

class QuizLanguageToggle extends StatelessWidget {
  const QuizLanguageToggle({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
  });

  final QuizLanguage selectedLanguage;
  final ValueChanged<QuizLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = QuizStrings.of(selectedLanguage);
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 340.0;
        final compact = maxWidth < 220;
        final borderRadius = compact ? 16.0 : 20.0;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 3 : 4),
            child: Wrap(
              spacing: compact ? 4 : 6,
              runSpacing: compact ? 4 : 6,
              children: [
                _LanguageChip(
                  label: strings.englishLabel,
                  isSelected: selectedLanguage == QuizLanguage.english,
                  activeColor: colorScheme.primary,
                  compact: compact,
                  onTap: () => onChanged(QuizLanguage.english),
                ),
                _LanguageChip(
                  label: strings.spanishLabel,
                  isSelected: selectedLanguage == QuizLanguage.spanish,
                  activeColor: colorScheme.primary,
                  compact: compact,
                  onTap: () => onChanged(QuizLanguage.spanish),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color activeColor;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(compact ? 12 : 16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF28415A),
            fontWeight: FontWeight.w700,
            fontSize: compact ? 12 : null,
          ),
        ),
      ),
    );
  }
}
