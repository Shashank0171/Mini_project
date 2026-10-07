import 'package:flutter/material.dart';
import 'package:ai_mobile_assistant/theme/app_theme.dart';
import 'package:ai_mobile_assistant/localization/app_localizations.dart';
import 'package:ai_mobile_assistant/services/storage_service.dart';
import 'package:ai_mobile_assistant/screens/splash_screen.dart';
import 'package:ai_mobile_assistant/screens/language_screen.dart';
import 'package:ai_mobile_assistant/screens/home_screen.dart';
import 'package:ai_mobile_assistant/screens/object_detection_screen.dart';
import 'package:ai_mobile_assistant/screens/text_reader_screen.dart';
import 'package:ai_mobile_assistant/screens/scene_description_screen.dart';
import 'package:ai_mobile_assistant/screens/gps_screen.dart';
import 'package:ai_mobile_assistant/screens/sos_screen.dart';
import 'package:ai_mobile_assistant/screens/settings_screen.dart';
import 'package:ai_mobile_assistant/screens/currency_detection_screen.dart';

/// Root application widget.
/// Configures Material theme, routing, and language settings.
class AIMobileAssistantApp extends StatefulWidget {
  const AIMobileAssistantApp({super.key});

  @override
  State<AIMobileAssistantApp> createState() => _AIMobileAssistantAppState();
}

class _AIMobileAssistantAppState extends State<AIMobileAssistantApp> {
  bool _highContrast = false;
  bool _largeText = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final storage = StorageService();
    await storage.init();

    final lang = storage.getLanguage();
    AppLocalizations.setLanguage(lang);

    setState(() {
      _highContrast = storage.getHighContrast();
      _largeText = storage.getLargeText();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Mobile Assistant',
      debugShowCheckedModeBanner: false,
      theme: _highContrast ? AppTheme.highContrastTheme : AppTheme.lightTheme,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = AppTheme.getTextScaleFactor(_largeText);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        );
      },
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/language': (_) => const LanguageScreen(),
        '/home': (_) => const HomeScreen(),
        '/object-detection': (_) => const ObjectDetectionScreen(),
        '/text-reader': (_) => const TextReaderScreen(),
        '/scene-description': (_) => const SceneDescriptionScreen(),
        '/gps': (_) => const GpsScreen(),
        '/sos': (_) => const SosScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/currency': (_) => const CurrencyDetectionScreen(),
      },
    );
  }
}
