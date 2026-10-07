import 'package:flutter_tts/flutter_tts.dart';

/// Flutter TTS wrapper for text-to-speech functionality.
/// Supports English, Telugu, and Hindi.
class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });
    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
    });
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  Future<void> setLanguage(String languageCode) async {
    String locale;
    if (languageCode == 'te') {
      locale = 'te-IN';
    } else if (languageCode == 'hi') {
      locale = 'hi-IN';
    } else {
      locale = 'en-IN';
    }

    try {
      final isSupported = await _flutterTts.isLanguageAvailable(locale);
      if (isSupported) {
        await _flutterTts.setLanguage(locale);
      }
    } catch (_) {
      // Gracefully handle unsupported language
    }
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }
}
