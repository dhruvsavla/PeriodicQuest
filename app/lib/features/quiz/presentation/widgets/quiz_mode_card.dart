import 'package:flutter/material.dart';

class QuizModeCard extends StatelessWidget {
  const QuizModeCard({
    super.key,
    required this.title,
    required this.lines,
    required this.badges,
    required this.emoji,
    required this.gradient,
    required this.borderColor,
    required this.glowColor,
    required this.onTap,
    this.heroLabel,
  });

  final String title;
  final List<String> lines;
  final List<String> badges;
  final String emoji;
  final String? heroLabel;
  final Gradient gradient;
  final Color borderColor;
  final Color glowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        final cardRadius = compact ? 22.0 : 28.0;
        final cardPadding = compact ? 16.0 : 24.0;
        final iconSize = compact ? 56.0 : 68.0;
        final emojiSize = compact ? 28.0 : 32.0;
        final arrowSize = compact ? 24.0 : 28.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(cardRadius),
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(cardRadius),
                border: Border.all(
                  color: borderColor,
                  width: compact ? 2 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.3),
                    blurRadius: compact ? 18 : 24,
                    offset: Offset(0, compact ? 9 : 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(
                            compact ? 18 : 22,
                          ),
                        ),
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: emojiSize),
                        ),
                      ),
                      SizedBox(width: compact ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF17334A),
                                fontWeight: FontWeight.w900,
                                fontSize: compact ? 24 : null,
                              ),
                            ),
                            if (heroLabel != null) ...[
                              SizedBox(height: compact ? 6 : 8),
                              Text(
                                heroLabel!,
                                style: textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF28415A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: compact ? 15 : null,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: compact ? 8 : 12),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: const Color(0xFF26425C),
                        size: arrowSize,
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 14 : 16),
                  Wrap(
                    spacing: compact ? 8 : 10,
                    runSpacing: compact ? 8 : 10,
                    children: [
                      for (final badge in badges)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 10 : 12,
                            vertical: compact ? 6 : 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge,
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF28415A),
                              fontSize: compact ? 12 : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: compact ? 14 : 16),
                  for (final line in lines) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: compact ? 2 : 3),
                          child: Icon(
                            Icons.check_circle_outline,
                            size: compact ? 16 : 18,
                            color: const Color(0xFF28415A),
                          ),
                        ),
                        SizedBox(width: compact ? 8 : 10),
                        Expanded(
                          child: Text(
                            line,
                            style: textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF28415A),
                              fontWeight: FontWeight.w700,
                              fontSize: compact ? 15 : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 8 : 10),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
