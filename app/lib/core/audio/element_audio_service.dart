import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../domain/elements/chemical_element.dart';

/// Singleton TTS service for element narration.
///
/// Usage:
///   await ElementAudioService.instance.init();   // call once in main()
///   await ElementAudioService.instance.speakElement(element);
///   await ElementAudioService.instance.stop();
///   ElementAudioService.instance.dispose();      // call when app exits
class ElementAudioService {
  ElementAudioService._();

  static final ElementAudioService instance = ElementAudioService._();

  final FlutterTts _tts = FlutterTts();

  /// Reactive playing state — listen to update UI without polling.
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);

  bool _initialised = false;

  // ─── Initialisation ────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42); // slower, easier for children
    await _tts.setPitch(1.12); // slightly warm/friendly tone
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() => isPlaying.value = true);
    _tts.setCompletionHandler(() => isPlaying.value = false);
    _tts.setCancelHandler(() => isPlaying.value = false);
    _tts.setErrorHandler((_) => isPlaying.value = false);
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Speaks the element name followed by its fun fact.
  ///
  /// Stops any in-progress narration first so tapping multiple elements
  /// quickly never overlaps audio.
  Future<void> speakElement(ChemicalElement element) async {
    await stop();
    final text = '${element.name}. ${element.fact}';
    await _tts.speak(text);
  }

  /// Speaks arbitrary text (used for compound announcements in Lab Experiment).
  Future<void> speakText(String text) async {
    await stop();
    await _tts.speak(text);
  }

  /// Stops narration immediately.
  Future<void> stop() async {
    if (isPlaying.value) {
      await _tts.stop();
      isPlaying.value = false;
    }
  }

  /// Release TTS resources. Call from your top-level app dispose / on exit.
  void dispose() {
    _tts.stop();
    isPlaying.dispose();
  }
}
