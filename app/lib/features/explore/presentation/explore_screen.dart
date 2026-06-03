import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../shared/decorations/app_gradients.dart';
import '../../../shared/widgets/animated_cloud.dart';
import '../../../shared/widgets/sparkle_band.dart';
import '../../../shared/widgets/twinkling_sparkle_field.dart';
import '../../../shared/widgets/pill_back_button.dart';
import '../../element_of_the_day/data/element_of_the_day_repository.dart';
import '../../element_of_the_day/presentation/element_of_the_day_screen.dart';
import '../../elements_catalog/presentation/all_elements_screen.dart';
import 'explore_category_icons.dart';
import 'explore_kawaii_star.dart';

// ─── Explore Page ─────────────────────────────────────────────────────────────

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  static const _elementOfTheDayRepository = ElementOfTheDayRepository();
  late final AnimationController _cloudCtrl;
  late final AnimationController _sparkleCtrl;
  late final AnimationController _cardCtrl;

  @override
  void initState() {
    super.initState();
    _cloudCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.cloudCycle,
    )..repeat();
    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.sparkleCycle,
    )..repeat();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.exploreCard,
    )..forward();
  }

  @override
  void dispose() {
    _cloudCtrl.dispose();
    _sparkleCtrl.dispose();
    _cardCtrl.dispose();
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
    final sw = bc.maxWidth;
    final h = bc.maxHeight;
    final w = math.min(sw, 960.0);
    final lh = math.min(h, w * 1.85);
    final pad = w * 0.045;

    return Stack(
      children: [
        // ── Animated clouds ────────────────────────────────────────────────
        AnimatedCloud(
          cloudController: _cloudCtrl,

          size: sw * 0.85,
          baseLeft: -sw * 0.20,
          top: h * 0.04,
          phase: 0.00,
          amp: sw * 0.05,
        ),
        AnimatedCloud(
          cloudController: _cloudCtrl,

          size: sw * 0.65,
          baseLeft: sw * 0.50,
          top: h * 0.18,
          phase: 0.33,
          amp: sw * 0.04,
        ),
        AnimatedCloud(
          cloudController: _cloudCtrl,

          size: sw * 0.55,
          baseLeft: -sw * 0.08,
          top: h * 0.70,
          phase: 0.66,
          amp: sw * 0.03,
        ),

        // ── Sparkles ──────────────────────────────────────────────────────
        ..._sparkles(sw, h),

        // ── Content centred at width w ────────────────────────────────────
        Center(
          child: SizedBox(
            width: w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: lh * 0.025),
                // Back button
                Padding(
                  padding: EdgeInsets.only(left: pad),
                  child: PillBackButton(
                    contentWidth: w,
                    foreground: const Color(0xFF3D3070),
                  ),
                ),
                SizedBox(height: lh * 0.028),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: Text(
                    AppStrings.chooseExplore,
                    style: TextStyle(
                      fontSize: math.min(34.0, w * 0.075),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1A4A),
                    ),
                  ),
                ),
                SizedBox(height: lh * 0.025),
                // 2×2 category grid
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _categoryCard(
                                  0,
                                  AppStrings.allElements,
                                  AppStrings.allElementsSubtitle,
                                  const Color(0xFFBFE4F8),
                                  const Color(0xFF90C8E8),
                                  const AllElementsCategoryIcon(),
                                  onTap: () => Navigator.push(
                                    context,
                                    slideRoute(const AllElementsPage()),
                                  ),
                                ),
                              ),
                              SizedBox(width: pad * 0.7),
                              Expanded(
                                child: _categoryCard(
                                  1,
                                  AppStrings.metals,
                                  AppStrings.metalsSubtitle,
                                  const Color(0xFFFFF0C0),
                                  const Color(0xFFE8D090),
                                  const MetalsCategoryIcon(),
                                  onTap: () => Navigator.push(
                                    context,
                                    slideRoute(
                                      const AllElementsPage(
                                        title: AppStrings.metals,
                                        filterCategories: [
                                          'alkali',
                                          'alkaline',
                                          'transition',
                                          'post',
                                          'lanthanide',
                                          'actinide',
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: pad * 0.7),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _categoryCard(
                                  2,
                                  AppStrings.nonmetals,
                                  AppStrings.nonmetalsSubtitle,
                                  const Color(0xFFB8EEF0),
                                  const Color(0xFF80C8CC),
                                  const NonmetalsCategoryIcon(),
                                  onTap: () => Navigator.push(
                                    context,
                                    slideRoute(
                                      const AllElementsPage(
                                        title: AppStrings.nonmetals,
                                        filterCategories: [
                                          'nonmetal',
                                          'halogen',
                                          'metalloid',
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: pad * 0.7),
                              Expanded(
                                child: _categoryCard(
                                  3,
                                  AppStrings.nobleGases,
                                  AppStrings.nobleGasesSubtitle,
                                  const Color(0xFFDDD0FF),
                                  const Color(0xFFAA90E8),
                                  const NobleGasesCategoryIcon(),
                                  onTap: () => Navigator.push(
                                    context,
                                    slideRoute(
                                      const AllElementsPage(
                                        title: AppStrings.nobleGases,
                                        filterCategories: ['noble'],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: pad * 0.7),
                // Element of the Day banner
                _elementOfTheDay(w, lh, pad),
                SizedBox(height: pad),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryCard(
    int index,
    String title,
    String subtitle,
    Color bg,
    Color border,
    CustomPainter icon, {
    VoidCallback? onTap,
  }) {
    return AnimatedBuilder(
      animation: _cardCtrl,
      builder: (_, child) {
        final delay = index * 0.15;
        final t = math.max(0.0, (_cardCtrl.value - delay) / (1.0 - delay));
        final curved = Curves.easeOutBack.transform(t.clamp(0.0, 1.0));
        return Opacity(
          opacity: curved.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - curved)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 2),
            boxShadow: [
              BoxShadow(
                color: border.withValues(alpha: 0.45),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, cc) {
              final cw = cc.maxWidth;
              final iconW = math.min(90.0, cw * 0.65);
              final iconH = iconW * 0.88;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: iconW,
                    height: iconH,
                    child: CustomPaint(painter: icon),
                  ),
                  SizedBox(height: cw * 0.055),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: cw * 0.08),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: math.min(17.0, cw * 0.115),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A4A),
                      ),
                    ),
                  ),
                  SizedBox(height: cw * 0.025),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: cw * 0.08),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: math.min(11.5, cw * 0.082),
                        color: const Color(0xFF4A4A7A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: cw * 0.07),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _elementOfTheDay(double w, double h, double pad) {
    return AnimatedBuilder(
      animation: _cardCtrl,
      builder: (_, child) {
        final t = Curves.easeOutBack.transform(_cardCtrl.value.clamp(0.0, 1.0));
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            slideRoute(
              ElementOfTheDayScreen(
                featuredElement: _elementOfTheDayRepository.elementForDate(
                  DateTime.now(),
                ),
              ),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0C8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8C870), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8C870).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: math.min(62.0, w * 0.16),
                      height: math.min(62.0, w * 0.16),
                      child: const CustomPaint(painter: KawaiiStarPainter()),
                    ),
                    SizedBox(width: math.max(10.0, w * 0.035)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.elementOfTheDay,
                            style: TextStyle(
                              fontSize: math.min(18.0, w * 0.048),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1A4A),
                            ),
                          ),
                          SizedBox(height: w * 0.010),
                          Text(
                            AppStrings.elementOfTheDayBody,
                            style: TextStyle(
                              fontSize: math.min(12.5, w * 0.034),
                              color: const Color(0xFF5A4A20),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // NEW TODAY badge
              Positioned(
                top: -10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C30),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDD6800).withValues(alpha: 0.45),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    AppStrings.newTodayBadge,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _sparkles(double w, double h) {
    final bands = <SparkleBand>[
      SparkleBand(
        left: w * 0.04,
        top: h * 0.035,
        size: 16.0,
        colorArgb: 0xFFFFFFFF,
        phase: 0.00,
      ),
      SparkleBand(
        left: w * 0.93,
        top: h * 0.075,
        size: 13.0,
        colorArgb: 0xFFFFE082,
        phase: 0.12,
      ),
      SparkleBand(
        left: w * 0.08,
        top: h * 0.280,
        size: 10.0,
        colorArgb: 0xFFFFE082,
        phase: 0.28,
      ),
      SparkleBand(
        left: w * 0.94,
        top: h * 0.320,
        size: 10.0,
        colorArgb: 0xCCFFFFFF,
        phase: 0.44,
      ),
      SparkleBand(
        left: w * 0.05,
        top: h * 0.720,
        size: 18.0,
        colorArgb: 0xFFFFE082,
        phase: 0.60,
      ),
      SparkleBand(
        left: w * 0.93,
        top: h * 0.760,
        size: 14.0,
        colorArgb: 0xFFFFFFFF,
        phase: 0.76,
      ),
      SparkleBand(
        left: w * 0.50,
        top: h * 0.110,
        size: 9.0,
        colorArgb: 0xFFFFE082,
        phase: 0.88,
      ),
    ];
    return buildTwinklingSparkles(
      sparkleController: _sparkleCtrl,
      bands: bands,
    );
  }
}
