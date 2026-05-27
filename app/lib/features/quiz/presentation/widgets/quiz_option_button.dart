import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_question.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_element_card_style.dart';

enum QuizOptionButtonDensity { regular, compact }

class QuizOptionButton extends StatelessWidget {
  const QuizOptionButton({
    super.key,
    required this.option,
    required this.questionType,
    required this.language,
    required this.prefix,
    required this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.isDisabled = false,
    this.density = QuizOptionButtonDensity.regular,
  });

  final QuizAnswerOption option;
  final QuizQuestionType questionType;
  final QuizLanguage language;
  final String prefix;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final bool isDisabled;
  final QuizOptionButtonDensity density;

  @override
  Widget build(BuildContext context) {
    final style = quizElementCardStyleForCategory(option.categoryKey);
    final label = option.labelFor(language);
    final card = _AnimatedShake(
      active: isIncorrect,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        scale: isCorrect ? 1.03 : (isSelected ? 1.015 : 1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: isDisabled && !isSelected && !isCorrect && !isIncorrect
              ? 0.76
              : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: _gradientForState(style),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _borderColorForState(style),
                width: isSelected || isCorrect || isIncorrect ? 2.4 : 1.8,
              ),
              boxShadow: _shadowsForState(style),
            ),
            child: _buildCardBody(
              label: label,
              style: style,
              statusColor: _accentColorForState(style),
            ),
          ),
        ),
      ),
    final card = LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            density == QuizOptionButtonDensity.compact ||
            constraints.maxWidth < 250;
        final tight =
            density == QuizOptionButtonDensity.compact &&
            (constraints.maxWidth <= 420 || constraints.maxHeight < 190);
        final radius = tight ? 18.0 : (compact ? 22.0 : 28.0);

        return _AnimatedShake(
          active: isIncorrect,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            scale: isCorrect ? 1.03 : (isSelected ? 1.015 : 1),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isDisabled && !isSelected && !isCorrect && !isIncorrect
                  ? 0.76
                  : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.all(tight ? 10 : (compact ? 14 : 18)),
                decoration: BoxDecoration(
                  gradient: _gradientForState(style),
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: _borderColorForState(style),
                    width: isSelected || isCorrect || isIncorrect ? 2.4 : 1.8,
                  ),
                  boxShadow: _shadowsForState(style),
                ),
                child: _buildCardBody(
                  label: label,
                  style: style,
                  statusColor: _accentColorForState(style),
                  compact: compact,
                  tight: tight,
                ),
              ),
            ),
          ),
        );
      },
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: isDisabled ? null : onTap,
        child: card,
      ),
    );
  }

  Gradient _gradientForState(QuizElementCardStyle style) {
    if (isCorrect) {
      return const LinearGradient(
        colors: [Color(0xFFE8FFF0), Color(0xFFCBF4D8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (isIncorrect) {
      return const LinearGradient(
        colors: [Color(0xFFFFF1F1), Color(0xFFFFD7D7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (isSelected) {
      return LinearGradient(
        colors: [
          style.gradient.colors.first.withValues(alpha: 0.98),
          style.gradient.colors.last.withValues(alpha: 0.98),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [
        style.gradient.colors.first.withValues(alpha: 0.92),
        style.gradient.colors.last.withValues(alpha: 0.92),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color _borderColorForState(QuizElementCardStyle style) {
    if (isCorrect) {
      return const Color(0xFF2F9C5C);
    }
    if (isIncorrect) {
      return const Color(0xFFC95A5A);
    }
    if (isSelected) {
      return style.borderColor;
    }
    return style.borderColor.withValues(alpha: 0.8);
  }

  Color _accentColorForState(QuizElementCardStyle style) {
    if (isCorrect) {
      return const Color(0xFF14613B);
    }
    if (isIncorrect) {
      return const Color(0xFF8A2020);
    }
    return style.foregroundColor;
  }

  List<BoxShadow> _shadowsForState(QuizElementCardStyle style) {
    if (isCorrect) {
      return const [
        BoxShadow(
          color: Color(0x6639B86E),
          blurRadius: 26,
          offset: Offset(0, 10),
        ),
      ];
    }
    if (isIncorrect) {
      return const [
        BoxShadow(
          color: Color(0x44C95A5A),
          blurRadius: 22,
          offset: Offset(0, 8),
        ),
      ];
    }
    return [
      BoxShadow(
        color: style.glowColor.withValues(alpha: isSelected ? 0.36 : 0.22),
        blurRadius: isSelected ? 24 : 18,
        offset: const Offset(0, 10),
      ),
    ];
  }

  Widget _buildCardBody({
    required String label,
    required QuizElementCardStyle style,
    required Color statusColor,
    required bool compact,
    required bool tight,
  }) {
    if (questionType == QuizQuestionType.symbol) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PrefixBadge(prefix: prefix, foregroundColor: statusColor),
              const Spacer(),
              Icon(_statusIcon, color: _statusColor, size: 24),
            ],
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
              _PrefixBadge(
                prefix: prefix,
                foregroundColor: statusColor,
                compact: compact,
              ),
              const Spacer(),
              Icon(
                _statusIcon,
                color: _statusColor,
                size: tight ? 18 : (compact ? 20 : 24),
              ),
            ],
          ),
          SizedBox(height: tight ? 6 : (compact ? 8 : 18)),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: tight ? 2 : (compact ? 4 : 12),
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 40,
                  fontSize: tight ? 20 : (compact ? 24 : 40),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: EdgeInsets.symmetric(
                horizontal: tight ? 6 : (compact ? 8 : 12),
                vertical: tight ? 3 : (compact ? 4 : 6),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                language == QuizLanguage.spanish ? 'Símbolo' : 'Symbol',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: tight ? 10 : (compact ? 11 : null),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final showSymbol =
        questionType == QuizQuestionType.atomicNumber ||
        questionType == QuizQuestionType.realWorldUse;
    final showCategory = true;
    final showAtomicNumber = questionType == QuizQuestionType.realWorldUse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PrefixBadge(prefix: prefix, foregroundColor: statusColor),
            _PrefixBadge(
              prefix: prefix,
              foregroundColor: statusColor,
              compact: compact,
            ),
            const Spacer(),
            if (showAtomicNumber && option.atomicNumber != null)
              _FloatingBadge(
                text: '${option.atomicNumber}',
                foregroundColor: statusColor,
              ),
            if (showAtomicNumber && option.atomicNumber != null)
              const SizedBox(width: 8),
            Icon(_statusIcon, color: _statusColor, size: 24),
          ],
        ),
        const SizedBox(height: 16),
        if (showSymbol && option.elementSymbol != null)
          Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(20),
                compact: compact,
              ),
            if (showAtomicNumber && option.atomicNumber != null)
              const SizedBox(width: 8),
            Icon(
              _statusIcon,
              color: _statusColor,
              size: tight ? 18 : (compact ? 20 : 24),
            ),
          ],
        ),
        SizedBox(height: tight ? 8 : (compact ? 10 : 16)),
        if (showSymbol && option.elementSymbol != null)
          Container(
            width: tight ? 38 : (compact ? 48 : 68),
            height: tight ? 38 : (compact ? 48 : 68),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(
                tight ? 12 : (compact ? 14 : 20),
              ),
              border: Border.all(color: statusColor.withValues(alpha: 0.16)),
            ),
            child: Text(
              option.elementSymbol!,
              style: TextStyle(
                color: statusColor,
                fontSize: 28,
                fontSize: tight ? 16 : (compact ? 20 : 28),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        if (showSymbol && option.elementSymbol != null)
          const SizedBox(height: 14),
        Text(
          label,
          style: TextStyle(
            color: statusColor,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          SizedBox(height: tight ? 6 : (compact ? 8 : 14)),
        Text(
          label,
          maxLines: tight ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: statusColor,
            fontSize: tight ? 13 : (compact ? 16 : 22),
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: tight ? 6 : (compact ? 8 : 12)),
        Wrap(
          spacing: tight ? 4 : (compact ? 6 : 8),
          runSpacing: tight ? 4 : (compact ? 6 : 8),
          children: [
            if (showCategory && option.localizedCategory(language) != null)
              _MetadataChip(
                text: option.localizedCategory(language)!,
                foregroundColor: style.foregroundColor,
                backgroundColor: style.badgeColor,
              ),
            if (showSymbol && option.elementSymbol != null)
                compact: compact,
              ),
            if (!tight && showSymbol && option.elementSymbol != null)
              _MetadataChip(
                text: option.elementSymbol!,
                foregroundColor: style.foregroundColor,
                backgroundColor: style.badgeColor,
              ),
            if (showAtomicNumber && option.atomicNumber != null)
                compact: compact,
              ),
            if (!tight && showAtomicNumber && option.atomicNumber != null)
              _MetadataChip(
                text:
                    '${language == QuizLanguage.spanish ? 'Atómico' : 'Atomic'} ${option.atomicNumber}',
                foregroundColor: style.foregroundColor,
                backgroundColor: style.badgeColor,
                compact: compact,
              ),
          ],
        ),
      ],
    );
  }

  IconData get _statusIcon {
    if (isCorrect) {
      return Icons.check_circle;
    }
    if (isIncorrect) {
      return Icons.cancel;
    }
    if (isSelected) {
      return Icons.stars_rounded;
    }
    return Icons.auto_awesome;
  }

  Color get _statusColor {
    if (isCorrect) {
      return const Color(0xFF2F9C5C);
    }
    if (isIncorrect) {
      return const Color(0xFFC95A5A);
    }
    return Colors.white.withValues(alpha: 0.9);
  }
}

class _AnimatedShake extends StatelessWidget {
  const _AnimatedShake({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      builder: (context, value, child) {
        final offset = math.sin(value * math.pi * 6) * (1 - value) * 9;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: child,
    );
  }
}

class _PrefixBadge extends StatelessWidget {
  const _PrefixBadge({required this.prefix, required this.foregroundColor});

  final String prefix;
  final Color foregroundColor;
  const _PrefixBadge({
    required this.prefix,
    required this.foregroundColor,
    required this.compact,
  });

  final String prefix;
  final Color foregroundColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      width: compact ? 30 : 36,
      height: compact ? 30 : 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        shape: BoxShape.circle,
      ),
      child: Text(
        prefix,
        style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w900),
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w900,
          fontSize: compact ? 12 : null,
        ),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({required this.text, required this.foregroundColor});

  final String text;
  final Color foregroundColor;
  const _FloatingBadge({
    required this.text,
    required this.foregroundColor,
    required this.compact,
  });

  final String text;
  final Color foregroundColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          fontSize: compact ? 11 : 12,
        ),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.text,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.compact,
  });

  final String text;
  final Color foregroundColor;
  final Color backgroundColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          fontSize: compact ? 11 : 12,
        ),
      ),
    );
  }
}
