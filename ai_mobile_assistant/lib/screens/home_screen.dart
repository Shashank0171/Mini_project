import 'package:flutter/material.dart';
import 'package:ai_mobile_assistant/localization/app_localizations.dart';
import 'package:ai_mobile_assistant/services/voice_service.dart';
import 'package:ai_mobile_assistant/services/speech_service.dart';
import 'package:ai_mobile_assistant/services/storage_service.dart';
import 'package:ai_mobile_assistant/widgets/feature_card.dart';
import 'package:ai_mobile_assistant/theme/app_theme.dart';

/// Modern home screen with glassmorphic cards and animated voice FAB.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  late AnimationController _fabController;
  late Animation<double> _fabPulse;
  late AnimationController _greetController;
  late Animation<double> _greetOpacity;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
    _fabPulse = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
    _greetController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _greetOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _greetController, curve: Curves.easeOut),
    );
    _initServices();
  }

  Future<void> _initServices() async {
    final storage = StorageService();
    await storage.init();
    final lang = storage.getLanguage();
    AppLocalizations.setLanguage(lang);
    await _voiceService.init();
    await _voiceService.setLanguage(lang);
    await _speechService.init();
    if (storage.getVoiceFeedback()) {
      await _voiceService.speak(AppLocalizations.t('appName'));
    }
  }

  void _navigateTo(String route) => Navigator.pushNamed(context, route);

  Future<void> _startVoiceCommand() async {
    if (!_speechService.isAvailable) {
      _voiceService.speak(AppLocalizations.t('speechNotAvailable'));
      return;
    }
    setState(() => _isListening = true);
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: AppTheme.primaryLight.withValues(alpha: 0.2)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryLight.withValues(alpha: 0.4),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('Listening...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              Text(AppLocalizations.t('voiceCommandHint'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primaryLight),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final lang = AppLocalizations.currentLanguage;
    _speechService.startListening(
      onResult: (String text) {
        setState(() => _isListening = false);
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        _handleVoiceCommand(text);
      },
      languageCode: lang,
    );
    Future.delayed(const Duration(seconds: 5), () {
      if (_isListening && mounted) {
        _speechService.stopListening();
        setState(() => _isListening = false);
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  void _handleVoiceCommand(String text) {
    final lowerText = text.toLowerCase();
    String? route;
    if (lowerText.contains('object') || lowerText.contains('detect')) route = '/object-detection';
    else if (lowerText.contains('text') || lowerText.contains('read') || lowerText.contains('ocr')) route = '/text-reader';
    else if (lowerText.contains('scene') || lowerText.contains('describe') || lowerText.contains('surround')) route = '/scene-description';
    else if (lowerText.contains('navigate') || lowerText.contains('gps') || lowerText.contains('map') || lowerText.contains('direction')) route = '/gps';
    else if (lowerText.contains('sos') || lowerText.contains('emergency') || lowerText.contains('help')) route = '/sos';
    else if (lowerText.contains('setting')) route = '/settings';
    // Telugu
    if (route == null) {
      if (lowerText.contains('వస్తువు') || lowerText.contains('గుర్తింపు')) route = '/object-detection';
      else if (lowerText.contains('వచనం') || lowerText.contains('చదవ')) route = '/text-reader';
      else if (lowerText.contains('పరిసరాల') || lowerText.contains('వివరణ')) route = '/scene-description';
      else if (lowerText.contains('నావిగేషన్')) route = '/gps';
      else if (lowerText.contains('అత్యవసర')) route = '/sos';
      else if (lowerText.contains('సెట్టింగ్')) route = '/settings';
    }
    // Hindi
    if (route == null) {
      if (lowerText.contains('वस्तु') || lowerText.contains('पहचान')) route = '/object-detection';
      else if (lowerText.contains('पाठ') || lowerText.contains('पढ़')) route = '/text-reader';
      else if (lowerText.contains('दृश्य') || lowerText.contains('विवरण')) route = '/scene-description';
      else if (lowerText.contains('नेविगेशन')) route = '/gps';
      else if (lowerText.contains('आपातकालीन')) route = '/sos';
      else if (lowerText.contains('सेटिंग')) route = '/settings';
    }
    if (route != null) _navigateTo(route);
    else _voiceService.speak(AppLocalizations.t('commandNotRecognized'));
  }

  @override
  void dispose() {
    _fabController.dispose();
    _greetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              FadeTransition(
                opacity: _greetOpacity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryLight.withValues(alpha: 0.25),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset('assets/images/app_logo.jpg', fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppTheme.primaryGradient.createShader(bounds),
                              child: const Text(
                                'AI Assist',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            Text(
                              'Smart Vision for Everyone',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.4),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Settings button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings_outlined, color: Colors.white54, size: 22),
                          onPressed: () => _navigateTo('/settings'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Quick status bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryLight.withValues(alpha: 0.08),
                        AppTheme.secondaryColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: AppTheme.primaryLight.withValues(alpha: 0.7)),
                      const SizedBox(width: 8),
                      Text(
                        'Tap a feature or use voice command',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Feature cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildFeature(Icons.visibility_rounded, AppLocalizations.t('objectDetection'),
                        AppLocalizations.t('objectDetectionDesc'), const Color(0xFF00E5FF), '/object-detection'),
                    _buildFeature(Icons.document_scanner_rounded, AppLocalizations.t('textReader'),
                        AppLocalizations.t('textReaderDesc'), const Color(0xFF00E676), '/text-reader'),
                    _buildFeature(Icons.panorama_rounded, AppLocalizations.t('sceneDescription'),
                        AppLocalizations.t('sceneDescriptionDesc'), const Color(0xFFFFAB00), '/scene-description'),
                    _buildFeature(Icons.explore_rounded, AppLocalizations.t('navigation'),
                        AppLocalizations.t('navigationDesc'), const Color(0xFF7B2FFF), '/gps'),
                    _buildFeature(Icons.currency_rupee_rounded, 'Currency Detection',
                        'Identify Indian currency notes', const Color(0xFFFF9800), '/currency'),
                    _buildFeature(Icons.emergency_rounded, AppLocalizations.t('emergencySOS'),
                        AppLocalizations.t('emergencySOSDesc'), const Color(0xFFFF1744), '/sos'),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Voice FAB
      floatingActionButton: Semantics(
        button: true,
        label: AppLocalizations.t('tapToSpeak'),
        child: ScaleTransition(
          scale: _isListening ? const AlwaysStoppedAnimation(1.0) : _fabPulse,
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _isListening
                  ? const LinearGradient(colors: [Color(0xFFFF1744), Color(0xFFD50000)])
                  : AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: (_isListening ? Colors.red : AppTheme.primaryLight).withValues(alpha: 0.45),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(34),
                onTap: _isListening ? null : _startVoiceCommand,
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFeature(IconData icon, String title, String subtitle, Color color, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FeatureCard(
        icon: icon,
        title: title,
        subtitle: subtitle,
        color: color,
        onTap: () => _navigateTo(route),
      ),
    );
  }
}
