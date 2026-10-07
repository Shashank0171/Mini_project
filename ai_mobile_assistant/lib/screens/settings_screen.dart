import 'package:flutter/material.dart';
import 'package:ai_mobile_assistant/localization/app_localizations.dart';
import 'package:ai_mobile_assistant/models/app_language.dart';
import 'package:ai_mobile_assistant/models/emergency_contact.dart';
import 'package:ai_mobile_assistant/services/storage_service.dart';
import 'package:ai_mobile_assistant/services/voice_service.dart';
import 'package:ai_mobile_assistant/theme/app_theme.dart';
import 'package:ai_mobile_assistant/utils/constants.dart';

/// Settings screen with language, voice, accessibility, contacts, and about sections.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  final VoiceService _voiceService = VoiceService();

  String _selectedLanguage = 'en';
  bool _voiceEnabled = true;
  double _speechRate = 0.5;
  bool _largeText = false;
  bool _highContrast = false;
  bool _voiceFeedback = true;
  bool _voiceNavigation = true;
  List<EmergencyContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _storageService.init();
    await _voiceService.init();
    setState(() {
      _selectedLanguage = _storageService.getLanguage();
      _voiceEnabled = _storageService.getVoiceEnabled();
      _speechRate = _storageService.getSpeechRate();
      _largeText = _storageService.getLargeText();
      _highContrast = _storageService.getHighContrast();
      _voiceFeedback = _storageService.getVoiceFeedback();
      _voiceNavigation = _storageService.getVoiceNavigation();
      _contacts = _storageService.getEmergencyContacts();
    });
  }

  Future<void> _changeLanguage(String code) async {
    setState(() => _selectedLanguage = code);
    await _storageService.setLanguage(code);
    AppLocalizations.setLanguage(code);
    await _voiceService.setLanguage(code);
    _voiceService.speak(AppLocalizations.t('languageChanged'));
    setState(() {}); // Rebuild with new translations
  }

  Future<void> _addContactDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.t('addContact')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.t('contactName'),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: AppLocalizations.t('contactPhone'),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relationController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.t('contactRelationship'),
                  prefixIcon: const Icon(Icons.people),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.t('add')),
          ),
        ],
      ),
    );

    if (result == true &&
        nameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty) {
      final contact = EmergencyContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        phone: phoneController.text,
        relationship:
            relationController.text.isEmpty ? '-' : relationController.text,
      );
      _contacts.add(contact);
      await _storageService.setEmergencyContacts(_contacts);
      setState(() {});
    }

    nameController.dispose();
    phoneController.dispose();
    relationController.dispose();
  }

  Future<void> _removeContact(EmergencyContact contact) async {
    _contacts.removeWhere((c) => c.id == contact.id);
    await _storageService.setEmergencyContacts(_contacts);
    setState(() {});
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.t('settings')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Language Section
          _buildSectionHeader(AppLocalizations.t('language')),
          ...AppLanguage.supportedLanguages.map((lang) {
            final isSelected = _selectedLanguage == lang.code;
            return Semantics(
              label:
                  '${lang.name}. ${isSelected ? "Selected" : "Tap to select"}',
              child: ListTile(
                leading: Radio<String>(
                  value: lang.code,
                  groupValue: _selectedLanguage,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (val) {
                    if (val != null) _changeLanguage(val);
                  },
                ),
                title: Text('${lang.flag} ${lang.nativeName}',
                    style: const TextStyle(fontSize: 18)),
                subtitle:
                    Text(lang.name, style: const TextStyle(fontSize: 14)),
                onTap: () => _changeLanguage(lang.code),
              ),
            );
          }),
          const Divider(),

          // Voice Section
          _buildSectionHeader(AppLocalizations.t('voice')),
          SwitchListTile(
            title: Text(AppLocalizations.t('enableVoice'),
                style: const TextStyle(fontSize: 18)),
            value: _voiceEnabled,
            activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.4),
            activeColor: AppTheme.primaryColor,
            onChanged: (val) async {
              setState(() => _voiceEnabled = val);
              await _storageService.setVoiceEnabled(val);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.t('speechRate')}: ${_speechRate.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 18),
                ),
                Semantics(
                  label: '${AppLocalizations.t('speechRate')} slider',
                  child: Slider(
                    value: _speechRate,
                    min: AppConstants.minSpeechRate,
                    max: AppConstants.maxSpeechRate,
                    divisions: 9,
                    onChanged: (val) async {
                      setState(() => _speechRate = val);
                      await _storageService.setSpeechRate(val);
                      await _voiceService.setSpeechRate(val);
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () =>
                  _voiceService.speak(AppLocalizations.t('appName')),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Test Voice',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
          const Divider(),

          // Accessibility Section
          _buildSectionHeader(AppLocalizations.t('accessibility')),
          SwitchListTile(
            title: Text(AppLocalizations.t('largeText'),
                style: const TextStyle(fontSize: 18)),
            value: _largeText,
            activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.4),
            activeColor: AppTheme.primaryColor,
            onChanged: (val) async {
              setState(() => _largeText = val);
              await _storageService.setLargeText(val);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Restart app to apply text size changes')),
                );
              }
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.t('highContrast'),
                style: const TextStyle(fontSize: 18)),
            value: _highContrast,
            activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.4),
            activeColor: AppTheme.primaryColor,
            onChanged: (val) async {
              setState(() => _highContrast = val);
              await _storageService.setHighContrast(val);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Restart app to apply contrast changes')),
                );
              }
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.t('voiceFeedback'),
                style: const TextStyle(fontSize: 18)),
            value: _voiceFeedback,
            activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.4),
            activeColor: AppTheme.primaryColor,
            onChanged: (val) async {
              setState(() => _voiceFeedback = val);
              await _storageService.setVoiceFeedback(val);
            },
          ),
          const Divider(),

          // Emergency Contacts Section
          _buildSectionHeader(AppLocalizations.t('emergencyContacts')),
          if (_contacts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.t('noEmergencyContacts'),
                style: const TextStyle(
                    fontSize: 16, color: AppTheme.textSecondary),
              ),
            )
          else
            ..._contacts.map((c) => ListTile(
                  leading:
                      const Icon(Icons.person, color: AppTheme.primaryColor),
                  title:
                      Text(c.name, style: const TextStyle(fontSize: 18)),
                  subtitle: Text('${c.phone} • ${c.relationship}'),
                  trailing: IconButton(
                    icon:
                        const Icon(Icons.delete, color: AppTheme.errorColor),
                    onPressed: () => _removeContact(c),
                    tooltip: AppLocalizations.t('removeContact'),
                  ),
                )),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: _addContactDialog,
              icon: const Icon(Icons.person_add),
              label: Text(AppLocalizations.t('addContact'),
                  style: const TextStyle(fontSize: 16)),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48)),
            ),
          ),
          const Divider(),

          // Navigation Section
          _buildSectionHeader(AppLocalizations.t('navigationSettings')),
          SwitchListTile(
            title: Text(AppLocalizations.t('voiceNavigation'),
                style: const TextStyle(fontSize: 18)),
            value: _voiceNavigation,
            activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.4),
            activeColor: AppTheme.primaryColor,
            onChanged: (val) async {
              setState(() => _voiceNavigation = val);
              await _storageService.setVoiceNavigation(val);
            },
          ),
          const Divider(),

          // About Section
          _buildSectionHeader(AppLocalizations.t('about')),
          ListTile(
            leading:
                const Icon(Icons.info, color: AppTheme.primaryColor),
            title: Text(AppLocalizations.t('projectTitle'),
                style: const TextStyle(fontSize: 18)),
            subtitle: const Text(
                'AI Based Mobile Assistant for Visually Impaired Individuals'),
          ),
          ListTile(
            leading:
                const Icon(Icons.verified, color: AppTheme.primaryColor),
            title: Text(
                '${AppLocalizations.t('version')}: ${AppConstants.appVersion}',
                style: const TextStyle(fontSize: 18)),
          ),
          ListTile(
            leading:
                const Icon(Icons.code, color: AppTheme.primaryColor),
            title: Text(AppLocalizations.t('developer'),
                style: const TextStyle(fontSize: 18)),
            subtitle: const Text('AI Mobile Assistant Team'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
