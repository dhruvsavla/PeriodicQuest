import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Glass-style back control used on secondary screens.
class PillBackButton extends StatelessWidget {
  final double contentWidth;
  final Color foreground;
  final String? label;
  final VoidCallback? onTap;

  const PillBackButton({
    super.key,
    required this.contentWidth,
    required this.foreground,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.maybePop(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: math.max(12.0, contentWidth * 0.033),
          vertical: math.max(7.0, contentWidth * 0.015),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios,
              size: math.min(15.0, contentWidth * 0.034),
              color: foreground,
            ),
            const SizedBox(width: 3),
            Text(
              label ?? AppStrings.back,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w700,
                fontSize: math.min(16.0, contentWidth * 0.037),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
