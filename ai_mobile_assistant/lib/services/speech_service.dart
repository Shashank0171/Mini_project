import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Speech-to-text wrapper for voice command input.
/// Supports English, Telugu, and Hindi locales.
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isAvailable;

  Future<bool> init() async {
    _isAvailable = await _speech.initialize(
      onError: (error) {
        // Handle speech recognition errors silently
      },
      onStatus: (status) {
        // Handle status changes silently
      },
    );
    return _isAvailable;
  }

  Future<void> startListening({
    required Function(String) onResult,
    required String languageCode,
  }) async {
    if (!_isAvailable) return;

    String localeId;
    if (languageCode == 'te') {
      localeId = 'te-IN';
    } else if (languageCode == 'hi') {
      localeId = 'hi-IN';
    } else {
      localeId = 'en-IN';
    }

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        cancelOnError: true,
        partialResults: false,
      ),
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}
