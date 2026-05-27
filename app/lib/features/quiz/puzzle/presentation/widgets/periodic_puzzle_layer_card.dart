import 'package:flutter/material.dart';

class PeriodicPuzzleLayerCard extends StatelessWidget {
  const PeriodicPuzzleLayerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.badges,
    required this.emoji,
    required this.gradient,
    required this.borderColor,
    required this.glowColor,
    this.trailingLabel,
    this.locked = false,
    this.stars,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String statusLabel;
  final List<String> badges;
  final String emoji;
  final Gradient gradient;
  final Color borderColor;
  final Color glowColor;
  final String? trailingLabel;
  final bool locked;
  final int? stars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.72 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: locked ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
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
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 30)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: const Color(0xFF17334A),
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: const Color(0xFF35566F),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      locked ? Icons.lock_rounded : Icons.arrow_forward_rounded,
                      color: const Color(0xFF26425C),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Badge(text: statusLabel),
                    for (final badge in badges) _Badge(text: badge),
                    if (stars != null) _Badge(text: '⭐ $stars'),
                  ],
                ),
                if (trailingLabel != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    trailingLabel!,
                    style: const TextStyle(
                      color: Color(0xFF28415A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;

        return Opacity(
          opacity: locked ? 0.72 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(compact ? 22 : 28),
              onTap: locked ? null : onTap,
              child: Container(
                padding: EdgeInsets.all(compact ? 16 : 22),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(compact ? 22 : 28),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.25),
                      blurRadius: compact ? 16 : 22,
                      offset: Offset(0, compact ? 8 : 10),
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
                          width: compact ? 52 : 60,
                          height: compact ? 52 : 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(
                              compact ? 16 : 20,
                            ),
                          ),
                          child: Text(
                            emoji,
                            style: TextStyle(fontSize: compact ? 26 : 30),
                          ),
                        ),
                        SizedBox(width: compact ? 10 : 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: const Color(0xFF17334A),
                                      fontWeight: FontWeight.w900,
                                      fontSize: compact ? 20 : null,
                                    ),
                              ),
                              SizedBox(height: compact ? 4 : 6),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: const Color(0xFF35566F),
                                      fontWeight: FontWeight.w700,
                                      fontSize: compact ? 14 : null,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: compact ? 8 : 12),
                        Icon(
                          locked
                              ? Icons.lock_rounded
                              : Icons.arrow_forward_rounded,
                          color: const Color(0xFF26425C),
                          size: compact ? 20 : 24,
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 10 : 14),
                    Wrap(
                      spacing: compact ? 8 : 10,
                      runSpacing: compact ? 8 : 10,
                      children: [
                        _Badge(text: statusLabel),
                        for (final badge in badges) _Badge(text: badge),
                        if (stars != null) _Badge(text: '⭐ $stars'),
                      ],
                    ),
                    if (trailingLabel != null) ...[
                      SizedBox(height: compact ? 10 : 14),
                      Text(
                        trailingLabel!,
                        style: TextStyle(
                          color: const Color(0xFF28415A),
                          fontWeight: FontWeight.w800,
                          fontSize: compact ? 13 : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF28415A),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
