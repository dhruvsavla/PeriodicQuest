import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/responsive/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../domain/elements/chemical_element.dart';
import '../data/element_catalog_repository.dart';
import '../../../shared/decorations/app_gradients.dart';
import '../../../shared/widgets/animated_cloud.dart';
import '../../../shared/widgets/pill_back_button.dart';
import 'element_detail_sheet.dart';
import 'element_grid_tile.dart';

class AllElementsPage extends StatefulWidget {
  final String? title;
  final List<String>? filterCategories;

  const AllElementsPage({super.key, this.title, this.filterCategories});

  @override
  State<AllElementsPage> createState() => _AllElementsPageState();
}

class _AllElementsPageState extends State<AllElementsPage>
    with TickerProviderStateMixin {
  static const _catalog = ElementCatalogRepository();

  List<ChemicalElement> get _elements {
    final filter = widget.filterCategories;
    if (filter == null) return _catalog.allElements;
    return _catalog.allElements.where((e) => filter.contains(e.cat)).toList();
  }

  late final AnimationController _cloudCtrl;
  late final AnimationController _gridCtrl;

  @override
  void initState() {
    super.initState();
    _cloudCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.cloudCycle,
    )..repeat();
    _gridCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.allElementsGrid,
    )..forward();
  }

  @override
  void dispose() {
    _cloudCtrl.dispose();
    _gridCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.explorePurple),
        child: SafeArea(child: LayoutBuilder(builder: _buildLayout)),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, BoxConstraints bc) {
    final w = bc.maxWidth;
    final h = bc.maxHeight;
    final cols = Responsive.gridColumns(context);
    final contentWidth = math.min(w, Responsive.contentMaxWidth(context));
    final cardW = contentWidth / cols;

    return Stack(
      children: [
        AnimatedCloud(
          cloudController: _cloudCtrl,
          size: w * 0.70,
          baseLeft: -w * 0.15,
          top: h * 0.02,
          phase: 0.0,
          amp: w * 0.04,
        ),
        AnimatedCloud(
          cloudController: _cloudCtrl,
          size: w * 0.55,
          baseLeft: w * 0.55,
          top: h * 0.08,
          phase: 0.5,
          amp: w * 0.03,
        ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ────────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.horizontalPadding(context),
                    h * 0.018,
                    Responsive.horizontalPadding(context),
                    0,
                  ),
                  child: Row(
                    children: [
                      PillBackButton(
                        contentWidth: w,
                        foreground: const Color(0xFF3D3070),
                      ),
                      Expanded(
                        child: Text(
                          widget.title ?? AppStrings.allElements,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: math.min(30.sp, contentWidth * 0.072),
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1A1A4A),
                          ),
                        ),
                      ),
                      // Mirror spacer so title stays centered
                      SizedBox(width: math.max(60.w, contentWidth * 0.18)),
                    ],
                  ),
                ),
                SizedBox(height: h * 0.012),
                // ── Grid ──────────────────────────────────────────────────────
                Expanded(
                  child: AnimatedBuilder(
                    animation: _gridCtrl,
                    builder: (context, ignored) {
                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xs,
                          0,
                          AppSpacing.xs,
                          h * 0.02,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: _elements.length,
                        itemBuilder: (context, i) {
                          final e = _elements[i];
                          final delay = (i % (cols * 5)) * 0.007;
                          final t = math.max(
                            0.0,
                            (_gridCtrl.value - delay) / (1.0 - delay),
                          );
                          final curved = Curves.easeOutBack.transform(
                            t.clamp(0.0, 1.0),
                          );
                          return Opacity(
                            opacity: curved.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 0.4 + 0.6 * curved,
                              child: ElementGridTile(
                                elem: e,
                                cardW: cardW,
                                onTap: () => _showDetail(context, e),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDetail(BuildContext context, ChemicalElement e) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: AppDurations.elementDialog,
      pageBuilder: (ctx, anim, sec) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, sec, ignored) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: anim,
            child: Center(child: ElementDetailSheet(elem: e)),
          ),
        );
      },
    );
  }
}
