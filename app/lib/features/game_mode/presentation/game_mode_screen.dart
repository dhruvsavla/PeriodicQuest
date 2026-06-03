import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/responsive/app_radius.dart';
import '../../../core/responsive/app_sizes.dart';
import '../../../core/responsive/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/router/app_navigation.dart';
import '../../../shared/decorations/app_gradients.dart';
import '../../../shared/widgets/animated_cloud.dart';
import '../../../shared/widgets/sparkle_band.dart';
import '../../../shared/widgets/twinkling_sparkle_field.dart';
import '../../../shared/widgets/pill_back_button.dart';
import '../../quiz/data/quiz_question_generator.dart';
import '../../quiz/presentation/quiz_home_page.dart';
import '../../adventure/presentation/adventure_screen.dart';
import '../../explore/presentation/explore_screen.dart';
import 'game_mode_icons.dart';

class GameModePage extends StatefulWidget {
  const GameModePage({
    super.key,
    this.quizQuestionGenerator = const QuizQuestionGenerator(),
    this.quizRandomSeed,
  });

  final QuizQuestionGenerator quizQuestionGenerator;
  final int? quizRandomSeed;

  @override
  State<GameModePage> createState() => _GameModePageState();
}

class _GameModePageState extends State<GameModePage>
    with TickerProviderStateMixin {
  late final AnimationController _sparkleCtrl;
  late final AnimationController _cloudCtrl;

  @override
  void initState() {
    super.initState();
    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.sparkleCycle,
    )..repeat();
    _cloudCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.cloudCycle,
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleCtrl.dispose();
    _cloudCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.skyBlue),
        child: SafeArea(child: LayoutBuilder(builder: _buildLayout)),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, BoxConstraints bc) {
    final sw = bc.maxWidth;
    final h = bc.maxHeight;
    final w = math.min(sw, Responsive.contentMaxWidth(context));
    final lh = math.min(h, w * 1.85);

    return Stack(
      children: [
        AnimatedCloud(
          cloudController: _cloudCtrl,

          size: sw * 0.9,
          baseLeft: -sw * 0.22,
          top: h * 0.05,
          phase: 0.00,
          amp: sw * 0.05,
        ),
        AnimatedCloud(
          cloudController: _cloudCtrl,

          size: sw * 0.70,
          baseLeft: sw * 0.43,
          top: h * 0.60,
          phase: 0.50,
          amp: sw * 0.04,
        ),
        ..._sparkles(sw, h),
        Center(
          child: SizedBox(
            width: w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: lh * 0.025),
                Padding(
                  padding: EdgeInsets.only(
                    left: math.max(w * 0.04, AppSpacing.sm),
                  ),
                  child: PillBackButton(
                    contentWidth: w,
                    foreground: const Color(0xFF3D6B80),
                  ),
                ),
                SizedBox(height: lh * 0.030),
                Center(
                  child: Text(
                    AppStrings.chooseGame,
                    style: TextStyle(
                      fontSize: math.min(AppSizes.titleFont, w * 0.079),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A3A5C),
                    ),
                  ),
                ),
                SizedBox(height: lh * 0.007),
                Center(
                  child: Text(
                    AppStrings.pickFunWay,
                    style: TextStyle(
                      fontSize: math.min(AppSizes.subtitleFont, w * 0.036),
                      color: const Color(0xFF5A7A8A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: lh * 0.04),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                    children: [
                      _ModeCard(
                        bg: const Color(0xFFB8D4F8),
                        border: const Color(0xFF7AB0E0),
                        iconBg: const Color(0xFFD8ECFF),
                        iconPainter: const BeakerIconPainter(),
                        title: AppStrings.exploreMode,
                        subtitle: AppStrings.exploreModeSubtitle,
                        onTap: () => Navigator.push(
                          context,
                          slideRoute(const ExplorePage()),
                        ),
                      ),
                      SizedBox(height: lh * 0.025),
                      _ModeCard(
                        bg: Color(0xFFFFD04A),
                        border: Color(0xFFDDA800),
                        iconBg: Color(0xFFFFEA90),
                        iconPainter: RobotIconPainter(),
                        title: AppStrings.quizMode,
                        subtitle: AppStrings.quizModeSubtitle,
                        onTap: () => Navigator.push(
                          context,
                          slideRoute(
                            QuizHomePage(
                              questionGenerator: widget.quizQuestionGenerator,
                              randomSeed: widget.quizRandomSeed,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: lh * 0.025),
                      _ModeCard(
                        bg: const Color(0xFFCCAEF5),
                        border: const Color(0xFF9B72D8),
                        iconBg: const Color(0xFFE8D5FF),
                        iconPainter: const StarIconPainter(),
                        title: AppStrings.adventureMode,
                        subtitle: AppStrings.adventureModeSubtitle,
                        onTap: () => Navigator.push(
                          context,
                          slideRoute(const AdventurePage()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _sparkles(double w, double h) {
    final bands = <SparkleBand>[
      SparkleBand(
        left: w * 0.04,
        top: h * 0.040,
        size: 16.0,
        colorArgb: 0xFFFFFFFF,
        phase: 0.00,
      ),
      SparkleBand(
        left: w * 0.93,
        top: h * 0.080,
        size: 12.0,
        colorArgb: 0xFFFFE082,
        phase: 0.15,
      ),
      SparkleBand(
        left: w * 0.07,
        top: h * 0.300,
        size: 10.0,
        colorArgb: 0xFFFFE082,
        phase: 0.30,
      ),
      SparkleBand(
        left: w * 0.95,
        top: h * 0.350,
        size: 10.0,
        colorArgb: 0xCCFFFFFF,
        phase: 0.45,
      ),
      SparkleBand(
        left: w * 0.05,
        top: h * 0.650,
        size: 18.0,
        colorArgb: 0xFFFFE082,
        phase: 0.60,
      ),
      SparkleBand(
        left: w * 0.93,
        top: h * 0.700,
        size: 14.0,
        colorArgb: 0xFFFFFFFF,
        phase: 0.75,
      ),
    ];
    return buildTwinklingSparkles(
      sparkleController: _sparkleCtrl,
      bands: bands,
    );
  }
}

// ─── Mode card ────────────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  final Color bg;
  final Color border;
  final Color iconBg;
  final CustomPainter iconPainter;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ModeCard({
    required this.bg,
    required this.border,
    required this.iconBg,
    required this.iconPainter,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cw = constraints.maxWidth;
        final iconSz = math.min(74.0, cw * 0.20);
        final pad = math.max(AppSpacing.sm, cw * 0.038);
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(pad),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: border, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: border.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: iconSz,
                  height: iconSz,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBg,
                  ),
                  child: CustomPaint(painter: iconPainter),
                ),
                SizedBox(width: math.max(10.0, cw * 0.04)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: math.min(21.0, cw * 0.056),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A3A5C),
                        ),
                      ),
                      SizedBox(height: math.max(3.0, cw * 0.012)),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: math.min(13.0, cw * 0.035),
                          color: const Color(0xFF3A5A70),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
