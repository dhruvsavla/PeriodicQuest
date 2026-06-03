import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app/core/responsive/app_radius.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;

        return Opacity(
          opacity: locked ? 0.72 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(
                compact ? AppRadius.lg : 28.r,
              ),
              onTap: locked ? null : onTap,
              child: Container(
                padding: EdgeInsets.all(compact ? 16.w : 22.w),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(
                    compact ? AppRadius.lg : 28.r,
                  ),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.25),
                      blurRadius: compact ? 16.r : 22.r,
                      offset: Offset(0, compact ? 8.h : 10.h),
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
                          width: compact ? 52.w : 60.w,
                          height: compact ? 52.w : 60.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(
                              compact ? 16.r : 20.r,
                            ),
                          ),
                          child: Text(
                            emoji,
                            style: TextStyle(fontSize: compact ? 26.sp : 30.sp),
                          ),
                        ),
                        SizedBox(width: compact ? 10.w : 14.w),
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
                                      fontSize: compact ? 20.sp : null,
                                    ),
                              ),
                              SizedBox(height: compact ? 4.h : 6.h),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: const Color(0xFF35566F),
                                      fontWeight: FontWeight.w700,
                                      fontSize: compact ? 14.sp : null,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: compact ? 8.w : 12.w),
                        Icon(
                          locked
                              ? Icons.lock_rounded
                              : Icons.arrow_forward_rounded,
                          color: const Color(0xFF26425C),
                          size: compact ? 20.sp : 24.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 10.h : 14.h),
                    Wrap(
                      spacing: compact ? 8.w : 10.w,
                      runSpacing: compact ? 8.h : 10.h,
                      children: [
                        _Badge(text: statusLabel),
                        for (final badge in badges) _Badge(text: badge),
                        if (stars != null) _Badge(text: '⭐ $stars'),
                      ],
                    ),
                    if (trailingLabel != null) ...[
                      SizedBox(height: compact ? 10.h : 14.h),
                      Text(
                        trailingLabel!,
                        style: TextStyle(
                          color: const Color(0xFF28415A),
                          fontWeight: FontWeight.w800,
                          fontSize: compact ? 13.sp : null,
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(AppRadius.pill),
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
