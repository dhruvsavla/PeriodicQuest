import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/audio/element_audio_service.dart';
import '../../../core/responsive/app_radius.dart';
import '../../../core/responsive/app_sizes.dart';
import '../../../core/responsive/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../domain/elements/chemical_element.dart';
import '../../../domain/elements/element_translations_es.dart';

class ElementDetailSheet extends StatefulWidget {
  final ChemicalElement elem;

  const ElementDetailSheet({super.key, required this.elem});

  @override
  State<ElementDetailSheet> createState() => _ElementDetailSheetState();
}

class _ElementDetailSheetState extends State<ElementDetailSheet> {
  final _audio = ElementAudioService.instance;
  bool _showSpanish = false;

  Future<void> _speakCurrentElement() async {
    final es = kElementTranslationsEs[widget.elem.z];
    final text = _showSpanish
        ? '${es?.name ?? widget.elem.name}. ${es?.fact ?? widget.elem.fact}'
        : '${widget.elem.name}. ${widget.elem.fact}';
    final languageCode = _showSpanish ? 'es-ES' : 'en-US';
    await _audio.speakText(text: text, languageCode: languageCode);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _speakCurrentElement();
    });
  }

  @override
  void dispose() {
    _audio.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = periodicCategoryColor(widget.elem.cat);
    final dw = Responsive.modalWidth(context);
    final es = kElementTranslationsEs[widget.elem.z];

    return Material(
      color: Colors.transparent,
      child: Container(
        width: dw,
        constraints: BoxConstraints(
          maxWidth: AppSizes.modalWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 32.r,
              offset: Offset(0, 12.h),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(dw * 0.055),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Title row ─────────────────────────────────────────────────
              Row(
                children: [
                  const Spacer(),
                  Text(
                    _showSpanish
                        ? (es?.name ?? widget.elem.name)
                        : widget.elem.name,
                    style: TextStyle(
                      fontSize: math.min(26.0, dw * 0.072),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1A4A),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 17.sp,
                        color: const Color(0xFF555555),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: dw * 0.042),
              // ── Card + info row ───────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ElementMiniCard(elem: widget.elem, color: color, dw: dw),
                  SizedBox(width: dw * 0.038),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('Atomic Number:', '${widget.elem.z}'),
                        SizedBox(height: dw * 0.02),
                        _infoRow('Atomic Weight:', '${widget.elem.mass}'),
                        SizedBox(height: dw * 0.026),
                        Text(
                          _showSpanish
                              ? (es?.desc ?? widget.elem.desc)
                              : widget.elem.desc,
                          style: TextStyle(
                            fontSize: math.min(13.5, dw * 0.034),
                            color: const Color(0xFF333333),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: dw * 0.04),
              // ── Fun Fact ──────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(dw * 0.038),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: const Color(0xFFFFE082),
                    width: 1.5.w,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _showSpanish ? '¡Dato Curioso!' : 'Fun Fact!',
                      style: TextStyle(
                        fontSize: math.min(14.0, dw * 0.036),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7A5800),
                      ),
                    ),
                    SizedBox(height: dw * 0.018),
                    Text(
                      _showSpanish
                          ? (es?.fact ?? widget.elem.fact)
                          : widget.elem.fact,
                      style: TextStyle(
                        fontSize: math.min(13.0, dw * 0.033),
                        color: const Color(0xFF5A4A00),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: dw * 0.036),
              // ── Action buttons ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _AudioReplayButton(
                      audio: _audio,
                      dw: dw,
                      showSpanish: _showSpanish,
                      onReplay: _speakCurrentElement,
                    ),
                  ),
                  SizedBox(width: dw * 0.026),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _showSpanish = !_showSpanish);
                        _speakCurrentElement();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _showSpanish
                            ? const Color(0xFF7A4A00)
                            : const Color(0xFF5A7A8A),
                        side: BorderSide(
                          color: _showSpanish
                              ? const Color(0xFFE8A030)
                              : const Color(0xFFB8D4E8),
                        ),
                        backgroundColor: _showSpanish
                            ? const Color(0xFFFFF3DC)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      ),
                      child: Text(
                        _showSpanish ? 'English' : 'Traducir',
                        style: TextStyle(fontSize: math.min(12.0, dw * 0.030)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: dw * 0.026),
              // ── OK button ─────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B8BE8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    padding: EdgeInsets.symmetric(vertical: dw * 0.036),
                    elevation: 3,
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: math.min(17.0, dw * 0.042),
                      fontWeight: FontWeight.w700,
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

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 13.sp, color: const Color(0xFF333333)),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' $value'),
        ],
      ),
    );
  }
}

// ─── Audio replay button ──────────────────────────────────────────────────────

class _AudioReplayButton extends StatelessWidget {
  final ElementAudioService audio;
  final double dw;
  final bool showSpanish;
  final Future<void> Function() onReplay;

  const _AudioReplayButton({
    required this.audio,
    required this.dw,
    required this.showSpanish,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: audio.isPlaying,
      builder: (context, playing, _) {
        return OutlinedButton(
          onPressed: playing ? null : onReplay,
          style: OutlinedButton.styleFrom(
            foregroundColor: playing
                ? const Color(0xFF3A7A5A)
                : const Color(0xFF5A7A8A),
            side: BorderSide(
              color: playing
                  ? const Color(0xFF88D4B0)
                  : const Color(0xFFB8D4E8),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (playing) _PulsingDot() else const Text('🔊'),
              SizedBox(width: 4.w),
              Text(
                playing
                    ? (showSpanish ? 'Reproduciendo…' : 'Playing…')
                    : (showSpanish ? 'Reproducir audio' : 'Play Audio'),
                style: TextStyle(fontSize: math.min(12.0, dw * 0.030)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Pulsing dot shown while audio plays ─────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF3A7A5A),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Mini element card ────────────────────────────────────────────────────────

class _ElementMiniCard extends StatelessWidget {
  final ChemicalElement elem;
  final Color color;
  final double dw;

  const _ElementMiniCard({
    required this.elem,
    required this.color,
    required this.dw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dw * 0.28,
      height: dw * 0.33,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Color.lerp(color, Colors.black, 0.18)!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.55),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${elem.z}',
              style: TextStyle(
                fontSize: dw * 0.036,
                fontWeight: FontWeight.w700,
                color: Colors.black.withValues(alpha: 0.6),
                height: 1.0,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  elem.sym,
                  style: TextStyle(
                    fontSize: dw * 0.120,
                    fontWeight: FontWeight.w900,
                    color: Colors.black.withValues(alpha: 0.82),
                    height: 1.0,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                elem.name,
                style: TextStyle(
                  fontSize: dw * 0.028,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withValues(alpha: 0.70),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Center(
              child: Text(
                '${elem.mass}',
                style: TextStyle(
                  fontSize: dw * 0.026,
                  color: Colors.black.withValues(alpha: 0.60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
