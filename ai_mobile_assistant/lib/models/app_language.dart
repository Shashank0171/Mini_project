/// Model representing a supported language in the application.
class AppLanguage {
  final String name;
  final String nativeName;
  final String code;
  final String speechLocale;
  final String flag;

  const AppLanguage({
    required this.name,
    required this.nativeName,
    required this.code,
    required this.speechLocale,
    required this.flag,
  });

  static const english = AppLanguage(
    name: 'English',
    nativeName: 'English',
    code: 'en',
    speechLocale: 'en-IN',
    flag: '🇬🇧',
  );

  static const telugu = AppLanguage(
    name: 'Telugu',
    nativeName: 'తెలుగు',
    code: 'te',
    speechLocale: 'te-IN',
    flag: 'తె',
  );

  static const hindi = AppLanguage(
    name: 'Hindi',
    nativeName: 'हिंदी',
    code: 'hi',
    speechLocale: 'hi-IN',
    flag: '🇮🇳',
  );

  static const List<AppLanguage> supportedLanguages = [
    english,
    telugu,
    hindi,
  ];

  static AppLanguage fromCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => english,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLanguage &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
