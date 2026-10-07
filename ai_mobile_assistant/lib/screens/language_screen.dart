import 'package:flutter/material.dart';
import 'package:ai_mobile_assistant/models/app_language.dart';
import 'package:ai_mobile_assistant/localization/app_localizations.dart';
import 'package:ai_mobile_assistant/services/storage_service.dart';
import 'package:ai_mobile_assistant/services/voice_service.dart';
import 'package:ai_mobile_assistant/widgets/language_card.dart';
import 'package:ai_mobile_assistant/theme/app_theme.dart';

/// Language selection screen shown on first launch.
/// Allows user to choose English, Telugu, or Hindi.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguageCode = 'en';
  bool _isLoading = false;

  Future<void> _onLanguageSelected(AppLanguage language) async {
    setState(() {
      _selectedLanguageCode = language.code;
    });
  }

  Future<void> _onContinue() async {
    setState(() => _isLoading = true);

    try {
      final storageService = StorageService();
      await storageService.init();

      // Save language
      await storageService.setLanguage(_selectedLanguageCode);
      AppLocalizations.setLanguage(_selectedLanguageCode);

      // Initialize voice and speak confirmation
      final voiceService = VoiceService();
      await voiceService.init();
      await voiceService.setLanguage(_selectedLanguageCode);
      await voiceService.speak(AppLocalizations.t('languageChanged'));

      // Mark first launch done
      await storageService.setFirstLaunchDone();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Title in all three languages
              Semantics(
                header: true,
                label: 'Select your language',
                child: const Column(
                  children: [
                    Icon(
                      Icons.language,
                      size: 56,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Select Your Language',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'మీ భాషను ఎంచుకోండి / अपनी भाषा चुनें',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Language cards
              Expanded(
                child: ListView.separated(
                  itemCount: AppLanguage.supportedLanguages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final language = AppLanguage.supportedLanguages[index];
                    return LanguageCard(
                      language: language,
                      isSelected: _selectedLanguageCode == language.code,
                      onTap: () => _onLanguageSelected(language),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Continue button
              Semantics(
                button: true,
                label: 'Continue with selected language',
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.buttonBorderRadius,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continue'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
