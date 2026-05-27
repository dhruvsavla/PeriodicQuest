import 'package:flutter/material.dart';

class QuizResponsiveLayout {
  const QuizResponsiveLayout._({
    required this.availableWidth,
    required this.contentWidth,
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.stackTopBar,
    required this.compactCard,
  });

  final double availableWidth;
  final double contentWidth;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final bool stackTopBar;
  final bool compactCard;

  factory QuizResponsiveLayout.resolve(
    BuildContext context,
    BoxConstraints constraints, {
    required double maxContentWidth,
    double minContentWidth = 320,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final availableWidth = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : mediaQuery.size.width;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final shortestSide = mediaQuery.size.shortestSide;
    final isCompact = shortestSide < 600;

    final contentWidth = availableWidth
        .clamp(minContentWidth, maxContentWidth)
        .toDouble();

    final horizontalPadding = isCompact
        ? (availableWidth < 380 ? 12.0 : 14.0)
        : (availableWidth > 1000 ? 24.0 : 20.0);

    final topPadding = isLandscape ? 10.0 : (isCompact ? 14.0 : 18.0);
    final bottomPadding = isLandscape ? 18.0 : 24.0;
    final stackTopBar = availableWidth < (isLandscape ? 860 : 700);
    final compactCard = availableWidth < 500;

    return QuizResponsiveLayout._(
      availableWidth: availableWidth,
      contentWidth: contentWidth,
      horizontalPadding: horizontalPadding,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
      stackTopBar: stackTopBar,
      compactCard: compactCard,
    );
  }
}
