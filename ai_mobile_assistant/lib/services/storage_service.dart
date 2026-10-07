import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_mobile_assistant/utils/constants.dart';
import 'package:ai_mobile_assistant/models/emergency_contact.dart';

/// SharedPreferences wrapper for persisting app settings.
class StorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getLanguage() {
    return _prefs?.getString(AppConstants.keyLanguage) ?? AppConstants.defaultLanguage;
  }

  Future<void> setLanguage(String languageCode) async {
    await _prefs?.setString(AppConstants.keyLanguage, languageCode);
  }

  bool isFirstLaunch() {
    return _prefs?.getBool(AppConstants.keyFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchDone() async {
    await _prefs?.setBool(AppConstants.keyFirstLaunch, false);
  }

  bool getVoiceEnabled() {
    return _prefs?.getBool(AppConstants.keyVoiceEnabled) ?? true;
  }

  Future<void> setVoiceEnabled(bool enabled) async {
    await _prefs?.setBool(AppConstants.keyVoiceEnabled, enabled);
  }

  double getSpeechRate() {
    return _prefs?.getDouble(AppConstants.keySpeechRate) ?? AppConstants.defaultSpeechRate;
  }

  Future<void> setSpeechRate(double rate) async {
    await _prefs?.setDouble(AppConstants.keySpeechRate, rate);
  }

  bool getLargeText() {
    return _prefs?.getBool(AppConstants.keyLargeText) ?? false;
  }

  Future<void> setLargeText(bool enabled) async {
    await _prefs?.setBool(AppConstants.keyLargeText, enabled);
  }

  bool getHighContrast() {
    return _prefs?.getBool(AppConstants.keyHighContrast) ?? false;
  }

  Future<void> setHighContrast(bool enabled) async {
    await _prefs?.setBool(AppConstants.keyHighContrast, enabled);
  }

  bool getVoiceFeedback() {
    return _prefs?.getBool(AppConstants.keyVoiceFeedback) ?? true;
  }

  Future<void> setVoiceFeedback(bool enabled) async {
    await _prefs?.setBool(AppConstants.keyVoiceFeedback, enabled);
  }

  bool getVoiceNavigation() {
    return _prefs?.getBool(AppConstants.keyVoiceNavigation) ?? true;
  }

  Future<void> setVoiceNavigation(bool enabled) async {
    await _prefs?.setBool(AppConstants.keyVoiceNavigation, enabled);
  }

  List<EmergencyContact> getEmergencyContacts() {
    final String? jsonString = _prefs?.getString(AppConstants.keyEmergencyContacts);
    if (jsonString != null && jsonString.isNotEmpty) {
      return EmergencyContact.fromJsonList(jsonString);
    }
    return [];
  }

  Future<void> setEmergencyContacts(List<EmergencyContact> contacts) async {
    final String jsonString = EmergencyContact.toJsonList(contacts);
    await _prefs?.setString(AppConstants.keyEmergencyContacts, jsonString);
  }
}
