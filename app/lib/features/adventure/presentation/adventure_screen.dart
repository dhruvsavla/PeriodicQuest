import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_durations.dart';
import '../../../shared/decorations/app_gradients.dart';
import '../../../shared/widgets/animated_cloud.dart';
import '../../../shared/widgets/pill_back_button.dart';
import '../../../shared/widgets/sparkle_band.dart';
import '../../../shared/widgets/twinkling_sparkle_field.dart';
import 'lab_experiment_screen.dart';
import 'story_quest_screen.dart';

class AdventurePage extends StatefulWidget {
  const AdventurePage({super.key});

  @override
  State<AdventurePage> createState() => _AdventurePageState();
}

class _AdventurePageState extends State<AdventurePage>
    with TickerProviderStateMixin {
  late final AnimationController _cloudCtrl;
  late final AnimationController _sparkleCtrl;
  int _tab = 0;

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
  }

  @override
  void dispose() {
    _cloudCtrl.dispose();
    _sparkleCtrl.dispose();
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

    return Stack(
      children: [
        AnimatedCloud(
          cloudController: _cloudCtrl,
          size: w * 0.72,
          baseLeft: -w * 0.16,
          top: h * 0.02,
          phase: 0.00,
          amp: w * 0.04,
        ),
        AnimatedCloud(
          cloudController: _cloudCtrl,
          size: w * 0.56,
          baseLeft: w * 0.52,
          top: h * 0.09,
          phase: 0.50,
          amp: w * 0.03,
        ),
        AnimatedCloud(
          cloudController: _cloudCtrl,
          size: w * 0.45,
          baseLeft: -w * 0.06,
          top: h * 0.72,
          phase: 0.75,
          amp: w * 0.025,
        ),
        ..._buildSparkles(w, h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(w * 0.04, h * 0.018, w * 0.04, 0),
              child: Row(
                children: [
                  PillBackButton(
                    contentWidth: w,
                    foreground: const Color(0xFF3D3070),
                  ),
                  Expanded(
                    child: Text(
                      'Adventure Mode',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: math.min(26.0, w * 0.062),
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1A4A),
                      ),
                    ),
                  ),
                  // Mirror spacer so title stays centred
                  SizedBox(width: math.max(60.0, w * 0.18)),
                ],
              ),
            ),
            SizedBox(height: h * 0.016),
            // ── Pill tab switcher ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.055),
              child: _PillTabSwitcher(
                selectedIndex: _tab,
                onTabChanged: (i) => setState(() => _tab = i),
                tabs: const ['🧪  Lab Experiment', '🗺️  Story Quest'],
              ),
            ),
            SizedBox(height: h * 0.014),
            // ── Tab content ──────────────────────────────────────────────
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [LabExperimentScreen(), StoryQuestScreen()],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildSparkles(double w, double h) {
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
    ];
    return buildTwinklingSparkles(
      sparkleController: _sparkleCtrl,
      bands: bands,
    );
  }
}

// ─── Pill tab switcher ────────────────────────────────────────────────────────

class _PillTabSwitcher extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<String> tabs;

  const _PillTabSwitcher({
    required this.selectedIndex,
    required this.onTabChanged,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B72D8).withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0xFF9B72D8), Color(0xFFBB90FF)],
                        )
                      : null,
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF9B72D8,
                            ).withValues(alpha: 0.40),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : const Color(0xFF6A5A9A),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
