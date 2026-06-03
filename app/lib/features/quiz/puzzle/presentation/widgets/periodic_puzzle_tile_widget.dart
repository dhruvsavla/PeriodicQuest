import 'package:flutter/material.dart';

import 'package:app/features/quiz/presentation/widgets/quiz_element_card_style.dart';

class PeriodicPuzzleTileWidget extends StatelessWidget {
  const PeriodicPuzzleTileWidget({
    super.key,
    required this.symbol,
    required this.name,
    required this.atomicNumber,
    required this.categoryKey,
    required this.onTap,
    this.categoryLabel,
    this.clueLabel,
    this.isMissing = false,
    this.isFilled = false,
    this.isSelected = false,
    this.showSuccess = false,
    this.tileWidth = 68,
    this.tileHeight = 74,
  });

  final String symbol;
  final String name;
  final int atomicNumber;
  final String categoryKey;
  final String? categoryLabel;
  final String? clueLabel;
  final VoidCallback? onTap;
  final bool isMissing;
  final bool isFilled;
  final bool isSelected;
  final bool showSuccess;
  final double tileWidth;
  final double tileHeight;

  @override
  Widget build(BuildContext context) {
    final style = quizElementCardStyleForCategory(categoryKey);
    final isLockedSlot = isMissing && !isFilled;
    final borderColor = isLockedSlot
        ? const Color(0xFF7B9DBA)
        : style.borderColor;
    final gradient = isLockedSlot
        ? const LinearGradient(
            colors: [Color(0xFFF3F8FD), Color(0xFFE1ECF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : style.gradient;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final isCompact = availableWidth < 72 || availableHeight < 78;
        final showName = availableWidth >= 74 && availableHeight >= 80;
        final showCategory = availableWidth >= 82 && availableHeight >= 90;
        final showClueLabel = availableWidth >= 76 && availableHeight >= 82;
        final radius = isCompact ? 16.0 : 20.0;
        final padding = isCompact ? 5.0 : 6.0;

        return AnimatedScale(
          duration: const Duration(milliseconds: 220),
          scale: isSelected ? 1.03 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF28567E) : borderColor,
                    width: isSelected ? 2.4 : 1.6,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (showSuccess
                                  ? const Color(0xFF44C776)
                                  : style.glowColor)
                              .withValues(alpha: 0.24),
                      blurRadius: showSuccess ? 24 : 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: isLockedSlot
                    ? _MissingTileFace(
                        clueLabel: clueLabel,
                        isSelected: isSelected,
                        isCompact: isCompact,
                        showClueLabel: showClueLabel,
                      )
                    : _FilledTileFace(
                        symbol: symbol,
                        name: name,
                        atomicNumber: atomicNumber,
                        categoryLabel: categoryLabel,
                        isFreshlyCompleted: showSuccess,
                        isCompact: isCompact,
                        showName: showName,
                        showCategory: showCategory,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilledTileFace extends StatelessWidget {
  const _FilledTileFace({
    required this.symbol,
    required this.name,
    required this.atomicNumber,
    this.categoryLabel,
    required this.isFreshlyCompleted,
    required this.isCompact,
    required this.showName,
    required this.showCategory,
  });

  final String symbol;
  final String name;
  final int atomicNumber;
  final String? categoryLabel;
  final bool isFreshlyCompleted;
  final bool isCompact;
  final bool showName;
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            '$atomicNumber',
            style: TextStyle(
              color: const Color(0xFF20435E),
              fontSize: isCompact ? 8 : 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (isFreshlyCompleted)
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: isCompact ? 12 : 14,
              color: const Color(0xFF2F9C5C),
            ),
          ),
        Center(
          child: Text(
            symbol,
            style: TextStyle(
              color: const Color(0xFF17334A),
              fontSize: isCompact ? 18 : 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (showName || showCategory)
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showName)
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF17334A),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                if (showCategory && categoryLabel != null) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      categoryLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2B4C67),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _MissingTileFace extends StatelessWidget {
  const _MissingTileFace({
    required this.clueLabel,
    required this.isSelected,
    required this.isCompact,
    required this.showClueLabel,
  });

  final String? clueLabel;
  final bool isSelected;
  final bool isCompact;
  final bool showClueLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: isCompact ? 16 : 18,
            height: isCompact ? 16 : 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              size: 9,
              color: Color(0xFF45657D),
            ),
          ),
        ),
        if (isSelected)
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              Icons.stars_rounded,
              size: isCompact ? 12 : 14,
              color: const Color(0xFF28567E),
            ),
          ),
        Center(
          child: Text(
            '?',
            style: TextStyle(
              color: const Color(0xFF28567E),
              fontSize: isCompact ? 22 : 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (showClueLabel)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                clueLabel ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2B4C67),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
