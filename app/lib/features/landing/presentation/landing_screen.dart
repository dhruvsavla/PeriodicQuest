import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/responsive/app_sizes.dart';
import '../../../core/responsive/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/router/app_navigation.dart';
import '../../../shared/decorations/app_gradients.dart';
import '../../../shared/widgets/animated_cloud.dart';
import '../../../shared/widgets/sparkle_band.dart';
import '../../../shared/widgets/twinkling_sparkle_field.dart';
import '../../game_mode/presentation/game_mode_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late final AnimationController _cloudCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _sparkleCtrl;
  late final AnimationController _btnCtrl;

  @override
  void initState() {
    super.initState();
    _cloudCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.cloudCycle,
    )..repeat();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.floatCycle,
    )..repeat();
    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.sparkleCycle,
    )..repeat();
    _btnCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.buttonPress,
    );
  }

  @override
  void dispose() {
    _cloudCtrl.dispose();
    _floatCtrl.dispose();
    _sparkleCtrl.dispose();
    _btnCtrl.dispose();
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
    final sw = bc.maxWidth; // full screen width — clouds/sparkles use this
    final h = bc.maxHeight;
    final isLandscape = Responsive.isLandscape(context);
    final w = math.min(
      sw,
      Responsive.contentMaxWidth(context),
    ); // content width cap
    final lh = math.min(h, w * 1.85);
    final cardSz = math.min(w * (isLandscape ? 0.18 : 0.22), 110.w);

    return Stack(
      children: [
        // ── Moving cloud blobs ────────────────────────────────────────────
        AnimatedCloud(
          cloudController: _cloudCtrl,

          size: sw * 0.9,
          baseLeft: -sw * 0.22,
          top: h * 0.04,
          phase: 0.00,
          amp: sw * 0.05,
        ),
        AnimatedCloud(
          cloudController: _cloudCtrl,

          size: sw * 0.70,
          baseLeft: sw * 0.43,
          top: h * 0.22,
          phase: 0.50,
          amp: sw * 0.04,
        ),
        AnimatedCloud(
          cloudController: _cloudCtrl,

          size: sw * 0.58,
          baseLeft: -sw * 0.06,
          top: h * 0.62,
          phase: 0.25,
          amp: sw * 0.03,
        ),

        // ── Twinkling sparkles ─────────────────────────────────────────────
        ..._sparkles(sw, h),

        // ── Main content centred, capped at w ─────────────────────────────
        Center(
          child: SizedBox(
            width: w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: lh * 0.030),
                LandingOutlinedTitle(fontSize: math.min(52.sp, w * 0.11)),
                SizedBox(height: lh * 0.008),
                Text(
                  AppStrings.tagline,
                  style: TextStyle(
                    fontSize: math.min(AppSizes.subtitleFont, w * 0.039),
                    color: const Color(0xFF3D6B80),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: lh * 0.012),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      _robot(w, lh),
                      _card(
                        w: w,
                        h: lh,
                        sz: cardSz,
                        left: true,
                        top: false,
                        num: 7,
                        sym: 'N',
                        name: 'Nitrogen',
                        color: const Color(0xFF5BBD70),
                        angle: -0.10,
                        phase: 0.50,
                      ),
                      _card(
                        w: w,
                        h: lh,
                        sz: cardSz,
                        left: false,
                        top: false,
                        num: 2,
                        sym: 'He',
                        name: 'Helium',
                        color: const Color(0xFF8B6EC7),
                        angle: 0.10,
                        phase: 0.75,
                      ),
                      _card(
                        w: w,
                        h: lh,
                        sz: cardSz,
                        left: true,
                        top: true,
                        num: 1,
                        sym: 'H',
                        name: 'Hydrogen',
                        color: const Color(0xFFF5C030),
                        angle: -0.12,
                        phase: 0.00,
                      ),
                      _card(
                        w: w,
                        h: lh,
                        sz: cardSz,
                        left: false,
                        top: true,
                        num: 8,
                        sym: 'O',
                        name: 'Oxygen',
                        color: const Color(0xFF9C7BD4),
                        angle: 0.12,
                        phase: 0.25,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    math.max(w * 0.08, AppSpacing.md),
                    0,
                    math.max(w * 0.08, AppSpacing.md),
                    lh * 0.032,
                  ),
                  child: _startButton(context, w, lh),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Sparkles ───────────────────────────────────────────────────────────────

  List<Widget> _sparkles(double w, double h) {
    final bands = <SparkleBand>[
      SparkleBand(
        left: w * 0.04,
        top: h * 0.038,
        size: 20.0,
        colorArgb: 0xFFFFFFFF,
        phase: 0.00,
      ),
      SparkleBand(
        left: w * 0.93,
        top: h * 0.068,
        size: 15.0,
        colorArgb: 0xFFFFE082,
        phase: 0.10,
      ),
      SparkleBand(
        left: w * 0.29,
        top: h * 0.018,
        size: 11.0,
        colorArgb: 0xCCFFFFFF,
        phase: 0.20,
      ),
      SparkleBand(
        left: w * 0.66,
        top: h * 0.013,
        size: 9.0,
        colorArgb: 0xFFFFE082,
        phase: 0.30,
      ),
      SparkleBand(
        left: w * 0.07,
        top: h * 0.710,
        size: 24.0,
        colorArgb: 0xFFFFE082,
        phase: 0.40,
      ),
      SparkleBand(
        left: w * 0.92,
        top: h * 0.730,
        size: 18.0,
        colorArgb: 0xFFFFFFFF,
        phase: 0.50,
      ),
      SparkleBand(
        left: w * 0.44,
        top: h * 0.730,
        size: 11.0,
        colorArgb: 0xFFFFE082,
        phase: 0.60,
      ),
      SparkleBand(
        left: w * 0.56,
        top: h * 0.690,
        size: 10.0,
        colorArgb: 0xCCFFFFFF,
        phase: 0.70,
      ),
      SparkleBand(
        left: w * 0.02,
        top: h * 0.440,
        size: 11.0,
        colorArgb: 0xFFFFE082,
        phase: 0.80,
      ),
      SparkleBand(
        left: w * 0.97,
        top: h * 0.490,
        size: 13.0,
        colorArgb: 0xCCFFFFFF,
        phase: 0.90,
      ),
    ];
    return buildTwinklingSparkles(
      sparkleController: _sparkleCtrl,
      bands: bands,
    );
  }

  // ── Floating element card ──────────────────────────────────────────────────

  Widget _card({
    required double w,
    required double h,
    required double sz,
    required bool left,
    required bool top,
    required int num,
    required String sym,
    required String name,
    required Color color,
    required double angle,
    required double phase,
  }) {
    return Positioned(
      left: left ? (top ? w * 0.015 : -w * 0.12) : null,
      right: left ? null : (top ? w * 0.015 : -w * 0.12),

      // Lower the top value so they sit near the robot's hands/sides
      top: top ? h * 0.010 : h * 0.420,
      child: AnimatedBuilder(
        animation: _floatCtrl,
        builder: (_, child) {
          final dy = -7.0 * math.sin((_floatCtrl.value + phase) * math.pi * 2);
          return Transform.translate(offset: Offset(0, dy), child: child);
        },
        child: Transform.rotate(
          angle: angle,
          child: LandingElementPreviewCard(
            atomicNumber: num,
            symbol: sym,
            name: name,
            color: color,
            size: sz,
          ),
        ),
      ),
    );
  }

  // ── Floating robot ─────────────────────────────────────────────────────────

  Widget _robot(double w, double h) {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (_, child) {
        final dy = -10.0 * math.sin(_floatCtrl.value * math.pi * 2);
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: SizedBox(
        width: w * 0.60,
        height: h * 0.63,
        child: const CustomPaint(painter: LandingRobotPainter()),
      ),
    );
  }

  // ── Start button with press animation ─────────────────────────────────────

  Widget _startButton(BuildContext context, double w, double h) {
    final clampedH = (h * 0.082).clamp(48.h, 70.h);
    return GestureDetector(
      onTapDown: (_) => _btnCtrl.forward(),
      onTapUp: (_) => _btnCtrl.reverse(),
      onTapCancel: () => _btnCtrl.reverse(),
      onTap: () => Navigator.push(context, slideRoute(const GameModePage())),
      child: AnimatedBuilder(
        animation: _btnCtrl,
        builder: (_, child) =>
            Transform.scale(scale: 1 - 0.04 * _btnCtrl.value, child: child),
        child: Container(
          width: double.infinity,
          height: clampedH,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFDD55), Color(0xFFFFAA1A)],
            ),
            borderRadius: BorderRadius.circular(clampedH / 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFCC7700),
                blurRadius: 0,
                offset: Offset(0, 5),
              ),
              BoxShadow(
                color: Color(0x55FF9900),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            AppStrings.startGame,
            style: TextStyle(
              fontSize: math.min(AppSizes.subtitleFont, w * 0.048),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF7A4800),
              letterSpacing: 3.w,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Outlined title ───────────────────────────────────────────────────────────

class LandingOutlinedTitle extends StatelessWidget {
  final double fontSize;
  const LandingOutlinedTitle({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final text = AppStrings.appTitle;
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 9.r
              ..strokeJoin = StrokeJoin.round
              ..color = const Color(0xFFFFD080),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4.r
              ..strokeJoin = StrokeJoin.round
              ..color = const Color(0xFFCC8820),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF8B5E1A),
          ),
        ),
      ],
    );
  }
}

// ─── Element card ─────────────────────────────────────────────────────────────

class LandingElementPreviewCard extends StatelessWidget {
  final int atomicNumber;
  final String symbol;
  final String name;
  final Color color;
  final double size;

  const LandingElementPreviewCard({
    super.key,
    required this.atomicNumber,
    required this.symbol,
    required this.name,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final w = size;
    final h = size * 1.10;
    final light = Color.lerp(color, Colors.white, 0.28)!;
    final dark = Color.lerp(color, Colors.black, 0.18)!;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, color, dark],
          stops: const [0.0, 0.45, 1.0],
        ),
        borderRadius: BorderRadius.circular(w * 0.14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.55),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 2,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gloss sheen at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: h * 0.42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(w * 0.14),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              w * 0.10,
              w * 0.07,
              w * 0.07,
              w * 0.08,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$atomicNumber',
                  style: TextStyle(
                    fontSize: w * 0.14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      symbol,
                      style: TextStyle(
                        fontSize: w * 0.44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: w * 0.115,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Robot mascot (CustomPainter) ─────────────────────────────────────────────

class LandingRobotPainter extends CustomPainter {
  const LandingRobotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const cLight = Color(0xFF8DCDE8);
    const cMid = Color(0xFF6CBAD8);
    const cDark = Color(0xFF52A8C6);

    // ── Ground shadow ──────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.945),
        width: w * 0.52,
        height: h * 0.04,
      ),
      Paint()
        ..color = const Color(0x33207090)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // ── Legs ──────────────────────────────────────────────────────────────
    _rr(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.345, h * 0.895),
        width: w * 0.185,
        height: h * 0.135,
      ),
      w * 0.092,
      Paint()..color = cDark,
    );
    _rr(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.655, h * 0.895),
        width: w * 0.185,
        height: h * 0.135,
      ),
      w * 0.092,
      Paint()..color = cDark,
    );

    // Leg highlight strip
    _rr(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.345, h * 0.875),
        width: w * 0.08,
        height: h * 0.03,
      ),
      w * 0.015,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    _rr(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.655, h * 0.875),
        width: w * 0.08,
        height: h * 0.03,
      ),
      w * 0.015,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    // ── Arms ──────────────────────────────────────────────────────────────
    _rotRR(
      canvas,
      Offset(w * 0.075, h * 0.565),
      w * 0.13,
      h * 0.225,
      w * 0.065,
      -0.30,
      Paint()..color = cMid,
    );
    _rotRR(
      canvas,
      Offset(w * 0.925, h * 0.565),
      w * 0.13,
      h * 0.225,
      w * 0.065,
      0.30,
      Paint()..color = cMid,
    );

    // ── Body ──────────────────────────────────────────────────────────────
    final bodyRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.515),
      width: w * 0.72,
      height: h * 0.61,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(w * 0.30)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cLight, cMid, cDark],
          stops: [0.0, 0.45, 1.0],
        ).createShader(bodyRect),
    );

    // Body gloss sheen
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.38, h * 0.245),
        width: w * 0.24,
        height: h * 0.09,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.38),
    );

    // ── Antenna ───────────────────────────────────────────────────────────
    canvas.drawLine(
      Offset(w * 0.5, h * 0.205),
      Offset(w * 0.5, h * 0.075),
      Paint()
        ..color = cDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.024
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.050),
      w * 0.044,
      Paint()..color = cDark,
    );
    canvas.drawCircle(
      Offset(w * 0.488, h * 0.042),
      w * 0.016,
      Paint()..color = Colors.white.withValues(alpha: 0.65),
    );

    // ── Eye sclera ────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.385),
      w * 0.247,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.385),
      w * 0.247,
      Paint()
        ..color = const Color(0xFFBBDEEF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Iris
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.385),
      w * 0.160,
      Paint()..color = const Color(0xFF4A90B8),
    );

    // Pupil
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.385),
      w * 0.093,
      Paint()..color = const Color(0xFF1A3545),
    );

    // Highlights
    canvas.drawCircle(
      Offset(w * 0.454, h * 0.366),
      w * 0.037,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w * 0.553, h * 0.416),
      w * 0.019,
      Paint()..color = Colors.white,
    );

    // ── Mouth ─────────────────────────────────────────────────────────────
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.420, h * 0.556)
        ..quadraticBezierTo(w * 0.500, h * 0.584, w * 0.580, h * 0.556),
      Paint()
        ..color = const Color(0xFFFF7070)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.027
        ..strokeCap = StrokeCap.round,
    );
  }

  void _rr(Canvas canvas, Rect rect, double r, Paint paint) => canvas.drawRRect(
    RRect.fromRectAndRadius(rect, Radius.circular(r)),
    paint,
  );

  void _rotRR(
    Canvas canvas,
    Offset c,
    double bw,
    double bh,
    double r,
    double angle,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    _rr(
      canvas,
      Rect.fromCenter(center: Offset.zero, width: bw, height: bh),
      r,
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
