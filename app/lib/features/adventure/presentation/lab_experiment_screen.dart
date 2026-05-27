import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/element_audio_service.dart';
import '../../../domain/elements/chemical_element.dart';
import '../../../domain/elements/periodic_table_data.dart';
import '../data/lab_reaction.dart';

// ─── Lab theme constants ──────────────────────────────────────────────────────

const _kBenchDark = Color(0xFF0F172A);
const _kBenchMid = Color(0xFF1E293B);
const _kBenchLight = Color(0xFF334155);
const _kLabGreen = Color(0xFF10B981);
const _kLabAmber = Color(0xFFF59E0B);
const _kLabBlue = Color(0xFF60A5FA);
const _kLabText = Color(0xFFE2E8F0);
const _kLabDim = Color(0xFF94A3B8);
const _kLabBorder = Color(0xFF475569);

// ─── Main screen ─────────────────────────────────────────────────────────────

class LabExperimentScreen extends StatefulWidget {
  const LabExperimentScreen({super.key});

  @override
  State<LabExperimentScreen> createState() => _LabExperimentScreenState();
}

class _LabExperimentScreenState extends State<LabExperimentScreen>
    with TickerProviderStateMixin {
  final _audio = ElementAudioService.instance;

  ChemicalElement? _slotA;
  ChemicalElement? _slotB;
  LabReaction? _reaction;
  bool _showResult = false;
  bool _isNewDiscovery = false;
  bool _reactPending = false;
  final List<LabReaction> _discovered = [];

  late final AnimationController _reactCtrl;
  late final AnimationController _shakeCtrl;
  late final AnimationController _resultCtrl;
  late final AnimationController _noReactionCtrl;
  late final AnimationController _bubbleCtrl;
  late final PageController _trayPageCtrl;
  int _trayPage = 0;

  @override
  void initState() {
    super.initState();
    _trayPageCtrl = PageController();

    _reactCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
    _resultCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _noReactionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _bubbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _reactCtrl.dispose();
    _shakeCtrl.dispose();
    _resultCtrl.dispose();
    _noReactionCtrl.dispose();
    _bubbleCtrl.dispose();
    _trayPageCtrl.dispose();
    super.dispose();
  }

  // ── Interaction ──────────────────────────────────────────────────────────────

  void _placeElement(ChemicalElement elem) {
    if (_reactPending) return;
    if (_showResult) {
      _doClear(firstElem: elem);
      return;
    }
    setState(() {
      if (_slotA == null) {
        _slotA = elem;
      } else if (_slotB == null) {
        _slotB = elem;
        _reactPending = true;
      }
    });
    if (_reactPending) _triggerReaction();
  }

  void _clearSlot({required bool isA}) {
    if (_reactPending || _showResult) return;
    setState(() {
      if (isA) {
        _slotA = null;
      } else {
        _slotB = null;
      }
    });
  }

  void _clearLab() => _doClear();

  void _doClear({ChemicalElement? firstElem}) {
    _audio.stop();
    _reactCtrl.reset();
    _resultCtrl.reset();
    _shakeCtrl.reset();
    _noReactionCtrl.reset();
    setState(() {
      _slotA = firstElem;
      _slotB = null;
      _reaction = null;
      _showResult = false;
      _isNewDiscovery = false;
      _reactPending = false;
    });
  }

  Future<void> _triggerReaction() async {
    await Future.delayed(const Duration(milliseconds: 440));
    if (!mounted) return;

    final reaction = findLabReaction(_slotA!.z, _slotB!.z);

    if (reaction != null) {
      final isNew = !_discovered.any((r) => r.compound == reaction.compound);
      setState(() {
        _reaction = reaction;
        _isNewDiscovery = isNew;
        if (isNew) _discovered.add(reaction);
        _reactPending = false;
      });
      await _reactCtrl.forward();
      if (!mounted) return;
      setState(() => _showResult = true);
      _resultCtrl.forward(from: 0);
      await _audio.speakText(
        'You created ${reaction.compound}! ${reaction.fact}',
      );
    } else {
      _shakeCtrl.forward(from: 0);
      _noReactionCtrl.forward(from: 0);
      setState(() => _reactPending = false);
      await Future.delayed(const Duration(milliseconds: 1700));
      if (!mounted) return;
      await _noReactionCtrl.reverse();
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildLayout);
  }

  Widget _buildLayout(BuildContext context, BoxConstraints bc) {
    final w = bc.maxWidth;
    // Cap pad so wide screens don't produce giant spacing.
    final pad = math.min(w * 0.046, 20.0);
    final tileW = math.min(56.0, w * 0.136).clamp(42.0, 56.0);
    final tileH = tileW * 1.18;
    // pad is already capped so pad*1.6 is at most 32px on wide screens.
    final trayH = tileH * 2 + pad * 1.6 + 50.0;

    return Container(
      color: _kBenchDark,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availH = constraints.maxHeight;
                // Fixed overhead for title + hint + spacers inside the column.
                const titleHint = 60.0;
                final vPad = math.min(pad * 0.4, 8.0);
                final containerPad = math.min(w * 0.045, 14.0);
                // How tall the workbench container can be without overflowing.
                // 0.08 accounts for spacers between title/hint/container
                // and the no-reaction banner gap below.
                final maxContainerH =
                    availH - vPad - titleHint - availH * 0.08;
                // Derive max slot size from that container budget.
                final maxSlotH =
                    (maxContainerH - containerPad * 2 - 32) / 1.18;
                final slotSz = math.min(
                  math.min(124.0, w * 0.28),
                  math.max(50.0, maxSlotH),
                );

                return Padding(
                  padding:
                      EdgeInsets.fromLTRB(pad, vPad, pad, 0),
                  child: Column(
                    mainAxisAlignment: _showResult
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      _buildLabTitle(w),
                      SizedBox(
                        height: _showResult
                            ? availH * 0.008
                            : availH * 0.015,
                      ),
                      _buildHintText(w),
                      SizedBox(
                        height: _showResult
                            ? availH * 0.012
                            : availH * 0.025,
                      ),
                      if (_showResult)
                        Expanded(
                          child: _buildWorkbenchArea(w, slotSz, availH),
                        )
                      else ...[
                        _buildWorkbenchArea(w, slotSz, availH),
                        SizedBox(height: availH * 0.02),
                        _buildNoReactionBanner(w),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          if (!_showResult) _buildTray(w, tileW, tileH, trayH, pad),
        ],
      ),
    );
  }

  Widget _buildLabTitle(double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('⚗️', style: TextStyle(fontSize: 20)),
        SizedBox(width: w * 0.025),
        Text(
          'CHEMISTRY LAB',
          style: TextStyle(
            fontSize: math.min(15.0, w * 0.038),
            fontWeight: FontWeight.w800,
            color: _kLabGreen,
            letterSpacing: 2.0,
          ),
        ),
        SizedBox(width: w * 0.025),
        const Text('🔬', style: TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget _buildHintText(double w) {
    final String msg;
    if (_showResult) {
      msg = '> tap any element to run a new experiment';
    } else if (_slotA == null) {
      msg = '> select two elements to combine them';
    } else if (_slotB == null) {
      msg = '> now pick a second element...';
    } else {
      msg = '> mixing reagents...';
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: Container(
        key: ValueKey(msg),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _kBenchMid,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kLabBorder, width: 1),
        ),
        child: Text(
          msg,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: math.min(12.5, w * 0.031),
            color: _kLabGreen,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildWorkbenchArea(double w, double slotSz, double availH) {
    if (_showResult) return _buildResultCard(w, availH);

    return Container(
      padding: EdgeInsets.all(math.min(w * 0.045, 14.0)),
      decoration: BoxDecoration(
        color: _kBenchMid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kLabBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grid background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CustomPaint(painter: _LabGridPainter()),
            ),
          ),
          // Decorative Erlenmeyer flask — top-left corner
          Positioned(
            top: 4,
            left: 4,
            child: CustomPaint(
              size: const Size(28, 36),
              painter: _ErlenmeyerPainter(
                color: _kLabBlue.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Decorative beaker — top-right corner
          Positioned(
            top: 4,
            right: 4,
            child: CustomPaint(
              size: const Size(26, 32),
              painter: _BeakerPainter(
                color: _kLabAmber.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Reaction row
          AnimatedBuilder(
            animation: Listenable.merge([_reactCtrl, _shakeCtrl]),
            builder: (context, child) {
              final slotOpacity =
                  (1.0 - _reactCtrl.value).clamp(0.0, 1.0);
              final shakeX =
                  math.sin(_shakeCtrl.value * math.pi * 5) *
                  11.0 *
                  (1 - _shakeCtrl.value);
              return Opacity(
                opacity: slotOpacity,
                child: Transform.translate(
                  offset: Offset(shakeX, 0),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSlot(w, slotSz, _slotA, isA: true),
                  SizedBox(width: w * 0.038),
                  _BunsenBurnerIcon(
                    active: (_slotA != null && _slotB != null) ||
                        _reactPending,
                  ),
                  SizedBox(width: w * 0.038),
                  _buildSlot(w, slotSz, _slotB, isA: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(
    double w,
    double slotSz,
    ChemicalElement? elem, {
    required bool isA,
  }) {
    final label = isA ? 'a' : 'b';
    return GestureDetector(
      onTap: elem != null ? () => _clearSlot(isA: isA) : null,
      child: SizedBox(
        width: slotSz,
        height: slotSz * 1.18,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 340),
          transitionBuilder: (child, anim) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.35, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
              ),
              child: FadeTransition(opacity: anim, child: child),
            );
          },
          child: elem == null
              ? _EmptyTestTube(key: ValueKey('empty-$label'), size: slotSz)
              : _FilledTestTube(
                  key: ValueKey('elem-${elem.z}-$label'),
                  elem: elem,
                  size: slotSz,
                  bubbleAnim: _bubbleCtrl,
                ),
        ),
      ),
    );
  }

  Widget _buildResultCard(double w, double availH) {
    final r = _reaction;
    if (r == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardH = constraints.maxHeight;
        final sp = math.min(cardH * 0.018, 10.0);
        return Center(
          child: _buildResultCardContent(w, sp, cardH, r),
        );
      },
    );
  }

  Widget _buildResultCardContent(
    double w,
    double sp,
    double availH,
    LabReaction r,
  ) {
    final colorA = periodicCategoryColor(_slotA!.cat);
    final colorB = periodicCategoryColor(_slotB!.cat);
    final blendColor = Color.lerp(colorA, colorB, 0.5)!;

    // Tube and flask sizes bounded by available height so nothing overflows.
    final tubeSize = math.min(60.0, availH * 0.09);
    final flaskH = math.min(w * 0.38, availH * 0.36);
    final flaskW = math.min(w * 0.52, flaskH * (0.52 / 0.46));

    return ScaleTransition(
      scale: Tween<double>(begin: 0.55, end: 1.0).animate(
        CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOutBack),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _resultCtrl, curve: Curves.easeIn),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: math.min(w * 0.06, 28.0),
            vertical: sp * 1.2,
          ),
          decoration: BoxDecoration(
            color: _kBenchMid,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: blendColor.withValues(alpha: 0.55),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: blendColor.withValues(alpha: 0.20),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isNewDiscovery) ...[
                _NewDiscoveryBadge(),
                SizedBox(height: sp * 0.8),
              ],

              // Two element test tubes + plus sign
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MiniTube(elem: _slotA!, color: colorA, size: tubeSize),
                  SizedBox(width: w * 0.05),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kBenchLight,
                      border: Border.all(color: _kLabBorder, width: 1.5),
                    ),
                    child: const Center(
                      child: Text(
                        '+',
                        style: TextStyle(
                          fontSize: 18,
                          color: _kLabText,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: w * 0.05),
                  _MiniTube(elem: _slotB!, color: colorB, size: tubeSize),
                ],
              ),

              SizedBox(height: sp * 0.6),

              // "reacts to form" arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    color: blendColor,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'reacts to form',
                    style: TextStyle(
                      fontSize: 11,
                      color: _kLabDim,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

              SizedBox(height: sp * 0.5),

              // Erlenmeyer flask with gradient liquid + emoji
              SizedBox(
                width: flaskW,
                height: flaskH,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ResultFlaskPainter(
                          colorA: colorA,
                          colorB: colorB,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: w * 0.04),
                      child: Text(
                        r.emoji,
                        style: TextStyle(
                          fontSize: math.min(42.0, w * 0.105),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: sp * 0.7),

              Text(
                r.compound,
                style: TextStyle(
                  fontSize: math.min(24.0, w * 0.058),
                  fontWeight: FontWeight.w900,
                  color: _kLabText,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: sp * 0.5),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorA.withValues(alpha: 0.20),
                      colorB.withValues(alpha: 0.20),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: blendColor.withValues(alpha: 0.50),
                  ),
                ),
                child: Text(
                  r.formula,
                  style: TextStyle(
                    fontSize: math.min(18.0, w * 0.046),
                    fontWeight: FontWeight.w900,
                    color: blendColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              SizedBox(height: sp),

              Text(
                r.fact,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: math.min(12.5, w * 0.031),
                  color: _kLabDim,
                  height: 1.5,
                ),
              ),

              SizedBox(height: sp * 1.2),

              Row(
                children: [
                  Expanded(
                    child: _LabOutlineBtn(
                      icon: Icons.volume_up_rounded,
                      label: 'Speak',
                      onTap: () =>
                          _audio.speakText('${r.compound}. ${r.fact}'),
                    ),
                  ),
                  SizedBox(width: w * 0.030),
                  Expanded(
                    child: _LabFillBtn(
                      icon: Icons.science_rounded,
                      label: 'New Mix',
                      onTap: _clearLab,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoReactionBanner(double w) {
    return FadeTransition(
      opacity: _noReactionCtrl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF2D1515),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cancel_outlined,
              color: Color(0xFFEF4444),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'No reaction! Try different elements',
              style: TextStyle(
                fontSize: math.min(13.0, w * 0.033),
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Element tray ─────────────────────────────────────────────────────────────

  Widget _buildTray(
    double w,
    double tileW,
    double tileH,
    double trayH,
    double pad,
  ) {
    return Container(
      height: trayH,
      decoration: BoxDecoration(
        color: _kBenchMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(
          top: BorderSide(color: _kLabBorder, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, pad * 0.55, pad, 0),
            child: Row(
              children: [
                const Icon(Icons.science, size: 13, color: _kLabGreen),
                const SizedBox(width: 5),
                const Text(
                  'ELEMENT RACK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _kLabGreen,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                if (_discovered.isNotEmpty)
                  GestureDetector(
                    onTap: () => _openJournal(context),
                    child: _JournalBadge(count: _discovered.length),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _buildTrayPages(w, tileW, tileH, pad),
          ),
          _buildTrayDots(w),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildTrayPages(
    double w,
    double tileW,
    double tileH,
    double pad,
  ) {
    final tileSlot = tileW + 5.0; // tile width + margin
    final tilesPerRow = math.max(4, (w / tileSlot).floor());
    final tilesPerPage = tilesPerRow * 2;
    final all = kPeriodicElements;
    final pageCount = (all.length / tilesPerPage).ceil();

    return PageView.builder(
      controller: _trayPageCtrl,
      onPageChanged: (p) => setState(() => _trayPage = p),
      itemCount: pageCount,
      itemBuilder: (_, page) {
        final start = page * tilesPerPage;
        final end = math.min(start + tilesPerPage, all.length);
        final elems = all.sublist(start, end);
        final mid = (elems.length / 2).ceil();
        final rowA = elems.sublist(0, mid);
        final rowB = elems.sublist(mid);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: pad * 0.5,
            vertical: pad * 0.28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    rowA.map((e) => _buildTrayTile(e, tileW, tileH)).toList(),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    rowB.map((e) => _buildTrayTile(e, tileW, tileH)).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrayDots(double w) {
    final tileW = math.min(56.0, w * 0.136).clamp(42.0, 56.0);
    final tilesPerRow = math.max(4, (w / (tileW + 5.0)).floor());
    final pageCount = (kPeriodicElements.length / (tilesPerRow * 2)).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (i) {
        final active = i == _trayPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: active ? 16 : 6,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: active ? _kLabGreen : _kLabBorder,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildTrayTile(ChemicalElement elem, double tileW, double tileH) {
    final color = periodicCategoryColor(elem.cat);
    final border = Color.lerp(color, Colors.black, 0.18)!;
    final inSlot = _slotA?.z == elem.z || _slotB?.z == elem.z;

    return GestureDetector(
      onTap: () => _placeElement(elem),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: tileW,
        height: tileH,
        margin: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: inSlot ? color.withValues(alpha: 0.42) : color,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: inSlot ? _kLabGreen : border,
            width: inSlot ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: inSlot
                  ? _kLabGreen.withValues(alpha: 0.45)
                  : border.withValues(alpha: 0.28),
              blurRadius: inSlot ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${elem.z}',
              style: TextStyle(
                fontSize: math.max(7.0, tileW * 0.175),
                color: Colors.black.withValues(alpha: 0.50),
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
            Text(
              elem.sym,
              style: TextStyle(
                fontSize: math.max(14.0, tileW * 0.44),
                fontWeight: FontWeight.w900,
                color: Colors.black.withValues(alpha: 0.82),
                height: 1.0,
              ),
            ),
            Text(
              elem.name,
              style: TextStyle(
                fontSize: math.max(5.5, tileW * 0.115),
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.60),
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _openJournal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _JournalSheet(discovered: List.unmodifiable(_discovered)),
    );
  }
}

// ─── Mini test tube (used in result card) ────────────────────────────────────

class _MiniTube extends StatelessWidget {
  final ChemicalElement elem;
  final Color color;
  final double size;

  const _MiniTube({
    required this.elem,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final h = size * 1.18;
    return SizedBox(
      width: size,
      height: h,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size, h),
            painter: _TestTubePainter(
              liquidColor: color,
              fillLevel: 0.60,
              isEmpty: false,
            ),
          ),
          Positioned(
            top: h * 0.10,
            left: 0,
            right: 0,
            bottom: h * 0.16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  elem.sym,
                  style: TextStyle(
                    fontSize: size * 0.26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                Text(
                  elem.name,
                  style: TextStyle(
                    fontSize: size * 0.09,
                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty test tube slot ─────────────────────────────────────────────────────

class _EmptyTestTube extends StatelessWidget {
  final double size;

  const _EmptyTestTube({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size * 1.18),
            painter: _TestTubePainter(
              liquidColor: Colors.transparent,
              fillLevel: 0,
              isEmpty: true,
            ),
          ),
          Positioned(
            bottom: size * 0.32,
            child: Text(
              'tap to\nadd',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: math.min(9.0, size * 0.075),
                color: Colors.white.withValues(alpha: 0.28),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filled test tube slot ────────────────────────────────────────────────────

class _FilledTestTube extends StatelessWidget {
  final ChemicalElement elem;
  final double size;
  final Animation<double> bubbleAnim;

  const _FilledTestTube({
    super.key,
    required this.elem,
    required this.size,
    required this.bubbleAnim,
  });

  @override
  Widget build(BuildContext context) {
    final color = periodicCategoryColor(elem.cat);
    final h = size * 1.18;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: size,
          height: h,
          child: Stack(
            children: [
              // Tube shape + liquid fill
              CustomPaint(
                size: Size(size, h),
                painter: _TestTubePainter(
                  liquidColor: color,
                  fillLevel: 0.65,
                  isEmpty: false,
                ),
              ),
              // Animated bubbles
              AnimatedBuilder(
                animation: bubbleAnim,
                builder: (context, child) => CustomPaint(
                  size: Size(size, h),
                  painter: _BubblesPainter(
                    progress: bubbleAnim.value,
                    color: color,
                    tubeWidthFraction: 0.46,
                  ),
                ),
              ),
              // Element label overlay
              Positioned(
                top: h * 0.10,
                left: 0,
                right: 0,
                bottom: h * 0.16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${elem.z}',
                      style: TextStyle(
                        fontSize: size * 0.088,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.0,
                      ),
                    ),
                    Text(
                      elem.sym,
                      style: TextStyle(
                        fontSize: size * 0.270,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      elem.name,
                      style: TextStyle(
                        fontSize: size * 0.070,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Dismiss badge
        Positioned(
          top: -6,
          right: -6,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _kBenchMid,
              shape: BoxShape.circle,
              border: Border.all(color: _kLabBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.close,
              size: 13,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Bunsen burner icon ───────────────────────────────────────────────────────

class _BunsenBurnerIcon extends StatelessWidget {
  final bool active;

  const _BunsenBurnerIcon({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: active
          ? const Text(
              '🔥',
              key: ValueKey(true),
              style: TextStyle(fontSize: 30),
            )
          : Container(
              key: const ValueKey(false),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kBenchDark,
                border: Border.all(color: _kLabBorder, width: 2),
              ),
              child: const Center(
                child: Text(
                  '+',
                  style: TextStyle(
                    fontSize: 22,
                    color: _kLabBorder,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
            ),
    );
  }
}

// ─── New discovery badge ──────────────────────────────────────────────────────

class _NewDiscoveryBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C30), Color(0xFFFFB340)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C30).withValues(alpha: 0.40),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Text(
        '🎉  NEW DISCOVERY!',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ─── Journal badge ────────────────────────────────────────────────────────────

class _JournalBadge extends StatelessWidget {
  final int count;

  const _JournalBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B72D8), Color(0xFFBB90FF)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B72D8).withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.book_rounded, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            'Journal · $count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action buttons ───────────────────────────────────────────────────────────

class _LabOutlineBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LabOutlineBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: _kLabDim,
        side: const BorderSide(color: _kLabBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        padding: const EdgeInsets.symmetric(vertical: 11),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

class _LabFillBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LabFillBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kLabGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        padding: const EdgeInsets.symmetric(vertical: 11),
        elevation: 4,
        shadowColor: _kLabGreen.withValues(alpha: 0.45),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

// ─── Discovery journal bottom sheet ──────────────────────────────────────────

class _JournalSheet extends StatelessWidget {
  final List<LabReaction> discovered;

  const _JournalSheet({required this.discovered});

  @override
  Widget build(BuildContext context) {
    final total = kLabReactions.length;
    return DraggableScrollableSheet(
      initialChildSize: 0.66,
      minChildSize: 0.42,
      maxChildSize: 0.92,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: _kBenchMid,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: _kLabBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    const Text(
                      '📓  Discovery Journal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _kLabText,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _kLabGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _kLabGreen.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        '${discovered.length} / $total',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _kLabGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: LinearProgressIndicator(
                  value: discovered.length / total,
                  backgroundColor: _kLabBorder,
                  valueColor: const AlwaysStoppedAnimation(_kLabGreen),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.55,
                  ),
                  itemCount: total,
                  itemBuilder: (_, i) {
                    final r = kLabReactions[i];
                    final found =
                        discovered.any((d) => d.compound == r.compound);
                    return _JournalCard(reaction: r, found: found);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _JournalCard extends StatelessWidget {
  final LabReaction reaction;
  final bool found;

  const _JournalCard({required this.reaction, required this.found});

  @override
  Widget build(BuildContext context) {
    if (found) {
      return Container(
        decoration: BoxDecoration(
          color: _kBenchLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _kLabGreen.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _kLabGreen.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(reaction.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                reaction.compound,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _kLabText,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              reaction.formula,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _kLabGreen,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _kBenchDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kLabBorder, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_rounded,
            size: 26,
            color: Colors.white.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 5),
          Text(
            '???',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CustomPainters ───────────────────────────────────────────────────────────

class _LabGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    const spacing = 22.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_LabGridPainter old) => false;
}

class _TestTubePainter extends CustomPainter {
  final Color liquidColor;
  final double fillLevel;
  final bool isEmpty;

  _TestTubePainter({
    required this.liquidColor,
    required this.fillLevel,
    required this.isEmpty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final tubeW = w * 0.46;
    final tubeLeft = (w - tubeW) / 2;
    final tubeRight = tubeLeft + tubeW;
    final bodyTop = h * 0.10;
    final bodyBottom = h * 0.84;
    final radius = tubeW / 2;

    final tubePath = Path()
      ..moveTo(tubeLeft, bodyTop)
      ..lineTo(tubeLeft, bodyBottom)
      ..arcToPoint(
        Offset(tubeRight, bodyBottom),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(tubeRight, bodyTop);

    // Glass fill
    canvas.drawPath(
      tubePath,
      Paint()
        ..color =
            Colors.white.withValues(alpha: isEmpty ? 0.05 : 0.08)
        ..style = PaintingStyle.fill,
    );

    // Liquid fill
    if (fillLevel > 0 && liquidColor != Colors.transparent) {
      final bodyH = bodyBottom - bodyTop;
      final liquidTop = bodyBottom - bodyH * fillLevel;

      final liquidPath = Path();
      if (liquidTop <= bodyBottom - radius) {
        liquidPath
          ..moveTo(tubeLeft, liquidTop)
          ..lineTo(tubeLeft, bodyBottom)
          ..arcToPoint(
            Offset(tubeRight, bodyBottom),
            radius: Radius.circular(radius),
            clockwise: false,
          )
          ..lineTo(tubeRight, liquidTop)
          ..close();
      } else {
        // Fill only the bottom arc
        liquidPath
          ..moveTo(tubeLeft, bodyBottom)
          ..arcToPoint(
            Offset(tubeRight, bodyBottom),
            radius: Radius.circular(radius),
            clockwise: false,
          )
          ..close();
      }

      canvas.drawPath(
        liquidPath,
        Paint()
          ..color = liquidColor.withValues(alpha: 0.78)
          ..style = PaintingStyle.fill,
      );

      // Surface shimmer
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w / 2, liquidTop),
          width: tubeW * 0.82,
          height: 5,
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.fill,
      );
    }

    // Glass border
    canvas.drawPath(
      tubePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Rim at top
    final rimLeft = tubeLeft - 4;
    final rimRight = tubeRight + 4;
    canvas.drawRRect(
      RRect.fromLTRBR(
        rimLeft,
        h * 0.03,
        rimRight,
        bodyTop + 5,
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        rimLeft,
        h * 0.03,
        rimRight,
        bodyTop + 5,
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Shine strip on left
    canvas.drawRRect(
      RRect.fromLTRBR(
        tubeLeft + tubeW * 0.08,
        bodyTop + 6,
        tubeLeft + tubeW * 0.22,
        bodyBottom * 0.78,
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_TestTubePainter old) =>
      old.liquidColor != liquidColor || old.fillLevel != fillLevel;
}

class _BubblesPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double tubeWidthFraction;

  _BubblesPainter({
    required this.progress,
    required this.color,
    required this.tubeWidthFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final tubeW = w * tubeWidthFraction;
    final tubeLeft = (w - tubeW) / 2;
    final bodyBottom = h * 0.84;
    final bodyTop = h * 0.10;
    final bodyH = bodyBottom - bodyTop;
    final liquidTop = bodyBottom - bodyH * 0.65;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    const offsets = [0.0, 0.38, 0.72];
    for (var i = 0; i < offsets.length; i++) {
      final phase = (progress + offsets[i]) % 1.0;
      final bubbleY = bodyBottom - (phase * (bodyBottom - liquidTop) * 0.92);
      if (bubbleY < liquidTop || bubbleY > bodyBottom) continue;

      final xFrac = 0.25 + (i * 0.25);
      final bubbleX = tubeLeft + tubeW * xFrac;
      final radius = 1.8 + phase * 2.2;

      canvas.drawCircle(Offset(bubbleX, bubbleY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_BubblesPainter old) => old.progress != progress;
}

class _ErlenmeyerPainter extends CustomPainter {
  final Color color;

  _ErlenmeyerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Neck
    canvas.drawRRect(
      RRect.fromLTRBR(w * 0.36, 0, w * 0.64, h * 0.38, const Radius.circular(2)),
      paint,
    );

    // Body (Erlenmeyer shape)
    final body = Path()
      ..moveTo(w * 0.36, h * 0.36)
      ..lineTo(w * 0.04, h)
      ..lineTo(w * 0.96, h)
      ..lineTo(w * 0.64, h * 0.36)
      ..close();
    canvas.drawPath(body, paint);

    // Liquid stripe
    final liquid = Path()
      ..moveTo(w * 0.12, h * 0.70)
      ..lineTo(w * 0.05, h * 0.98)
      ..lineTo(w * 0.95, h * 0.98)
      ..lineTo(w * 0.88, h * 0.70)
      ..close();
    canvas.drawPath(
      liquid,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_ErlenmeyerPainter old) => old.color != color;
}

class _BeakerPainter extends CustomPainter {
  final Color color;

  _BeakerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Body (slight trapezoid)
    final body = Path()
      ..moveTo(w * 0.06, h * 0.10)
      ..lineTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w * 0.94, h * 0.10)
      ..close();
    canvas.drawPath(body, paint);

    // Rim
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, w, h * 0.13, const Radius.circular(2)),
      paint,
    );

    // Spout notch
    final spout = Path()
      ..moveTo(w * 0.75, h * 0.10)
      ..lineTo(w * 0.68, -h * 0.06)
      ..lineTo(w, -h * 0.06)
      ..lineTo(w * 0.94, h * 0.10)
      ..close();
    canvas.drawPath(spout, paint);

    // Liquid stripe
    final liquid = Path()
      ..moveTo(w * 0.04, h * 0.65)
      ..lineTo(0, h * 0.98)
      ..lineTo(w, h * 0.98)
      ..lineTo(w * 0.96, h * 0.65)
      ..close();
    canvas.drawPath(
      liquid,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_BeakerPainter old) => old.color != color;
}

class _ResultFlaskPainter extends CustomPainter {
  final Color colorA;
  final Color colorB;

  _ResultFlaskPainter({required this.colorA, required this.colorB});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Neck ─────────────────────────────────────────────────────
    const nL = 0.41;
    const nR = 0.59;
    final neckBot = h * 0.28;

    canvas.drawRRect(
      RRect.fromLTRBR(w * nL, 0, w * nR, neckBot, const Radius.circular(4)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(w * nL, 0, w * nR, neckBot, const Radius.circular(4)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Rim – slightly wider than neck
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * nL - 3,
        -2,
        w * nR + 3,
        8,
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill,
    );

    // ── Body (curved Erlenmeyer shoulders) ────────────────────────
    final bodyPath = Path()
      ..moveTo(w * nL, neckBot)
      ..cubicTo(w * nL, h * 0.44, w * 0.06, h * 0.38, w * 0.06, h * 0.50)
      ..lineTo(w * 0.06, h * 0.93)
      ..lineTo(w * 0.94, h * 0.93)
      ..lineTo(w * 0.94, h * 0.50)
      ..cubicTo(w * 0.94, h * 0.38, w * nR, h * 0.44, w * nR, neckBot)
      ..close();

    // Glass background
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.fill,
    );

    // ── Gradient liquid (clipped to body) ─────────────────────────
    final liquidY = h * 0.50;
    final liquidPath = Path()
      ..moveTo(w * 0.06, liquidY)
      ..lineTo(w * 0.06, h * 0.93)
      ..lineTo(w * 0.94, h * 0.93)
      ..lineTo(w * 0.94, liquidY)
      ..close();

    canvas.save();
    canvas.clipPath(bodyPath);

    canvas.drawPath(
      liquidPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            colorA.withValues(alpha: 0.82),
            colorB.withValues(alpha: 0.82),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(
          Rect.fromLTRB(w * 0.06, liquidY, w * 0.94, h * 0.93),
        )
        ..style = PaintingStyle.fill,
    );

    // Surface shimmer
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, liquidY),
        width: w * 0.84,
        height: 7,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.32)
        ..style = PaintingStyle.fill,
    );

    // Bubbles
    for (final (cx, cy, r) in [
      (w * 0.24, h * 0.80, 2.5),
      (w * 0.56, h * 0.86, 2.0),
      (w * 0.70, h * 0.74, 1.5),
      (w * 0.38, h * 0.70, 1.8),
    ]) {
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill,
      );
    }

    // Left shine strip
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.09,
        h * 0.34,
        w * 0.14,
        h * 0.80,
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..style = PaintingStyle.fill,
    );

    canvas.restore();

    // Body outline (on top)
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_ResultFlaskPainter old) =>
      old.colorA != colorA || old.colorB != colorB;
}
