/// Application-wide constants.
class AppConstants {
  AppConstants._();

  /// Backend API base URL — change this to your server address.
  static const String apiBaseUrl = 'http://192.168.0.110:8000';

  /// App info
  static const String appName = 'AI Mobile Assistant';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'AI Based Mobile Assistant for Visually Impaired Individuals';

  /// Feature identifiers
  static const String featureObjectDetection = 'object_detection';
  static const String featureTextReader = 'text_reader';
  static const String featureSceneDescription = 'scene_description';
  static const String featureNavigation = 'navigation';
  static const String featureSOS = 'sos';
  static const String featureSettings = 'settings';

  /// Storage keys
  static const String keyLanguage = 'selected_language';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyVoiceEnabled = 'voice_enabled';
  static const String keySpeechRate = 'speech_rate';
  static const String keyLargeText = 'large_text';
  static const String keyHighContrast = 'high_contrast';
  static const String keyVoiceFeedback = 'voice_feedback';
  static const String keyEmergencyContacts = 'emergency_contacts';
  static const String keyVoiceNavigation = 'voice_navigation';

  /// Default values
  static const String defaultLanguage = 'en';
  static const double defaultSpeechRate = 0.5;
  static const double minSpeechRate = 0.1;
  static const double maxSpeechRate = 1.0;

  /// API endpoints
  static const String endpointDetect = '/detect';
  static const String endpointDescribe = '/describe';

  /// Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Confidence threshold for displaying detections
  static const double confidenceThreshold = 0.5;
}
