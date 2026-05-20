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
