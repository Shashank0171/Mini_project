import 'en.dart' as english;
import 'te.dart' as telugu;
import 'hi.dart' as hindi;

/// Centralized localization system for the application.
/// Supports English, Telugu, and Hindi.
class AppLocalizations {
  static String _currentLanguage = 'en';

  static final Map<String, Map<String, String>> _translations = {
    'en': english.en,
    'te': telugu.te,
    'hi': hindi.hi,
  };

  /// Set the current language.
  static void setLanguage(String languageCode) {
    if (_translations.containsKey(languageCode)) {
      _currentLanguage = languageCode;
    }
  }

  /// Get the current language code.
  static String get currentLanguage => _currentLanguage;

  /// Translate a key to the current language.
  /// Falls back to English if the key is not found in the current language.
  static String translate(String key) {
    final translations = _translations[_currentLanguage];
    if (translations != null && translations.containsKey(key)) {
      return translations[key]!;
    }
    // Fallback to English
    final fallback = _translations['en'];
    if (fallback != null && fallback.containsKey(key)) {
      return fallback[key]!;
    }
    return key;
  }

  /// Shorthand for translate.
  static String t(String key) => translate(key);

  /// Translate with parameter replacement.
  /// Parameters are specified as {paramName} in the translation string.
  static String translateWithParams(String key, Map<String, String> params) {
    String result = translate(key);
    params.forEach((paramKey, value) {
      result = result.replaceAll('{$paramKey}', value);
    });
    return result;
  }

  /// Get all supported language codes.
  static List<String> get supportedLanguages => _translations.keys.toList();

  /// Check if a language is supported.
  static bool isSupported(String languageCode) {
    return _translations.containsKey(languageCode);
  }

  /// Object name translations for detection results.
  static final Map<String, Map<String, String>> _objectTranslations = {
    'person': {'te': 'వ్యక్తి', 'hi': 'व्यक्ति'},
    'bicycle': {'te': 'సైకిల్', 'hi': 'साइकिल'},
    'car': {'te': 'కారు', 'hi': 'कार'},
    'motorcycle': {'te': 'మోటార్‌సైకిల్', 'hi': 'मोटरसाइकिल'},
    'airplane': {'te': 'విమానం', 'hi': 'हवाई जहाज'},
    'bus': {'te': 'బస్సు', 'hi': 'बस'},
    'train': {'te': 'రైలు', 'hi': 'ट्रेन'},
    'truck': {'te': 'ట్రక్కు', 'hi': 'ट्रक'},
    'boat': {'te': 'పడవ', 'hi': 'नाव'},
    'traffic light': {'te': 'ట్రాఫిక్ లైట్', 'hi': 'ट्रैफिक लाइट'},
    'fire hydrant': {'te': 'ఫైర్ హైడ్రంట్', 'hi': 'फायर हाइड्रेंट'},
    'stop sign': {'te': 'స్టాప్ సైన్', 'hi': 'स्टॉप साइन'},
    'parking meter': {'te': 'పార్కింగ్ మీటర్', 'hi': 'पार्किंग मीटर'},
    'bench': {'te': 'బెంచి', 'hi': 'बेंच'},
    'bird': {'te': 'పక్షి', 'hi': 'पक्षी'},
    'cat': {'te': 'పిల్లి', 'hi': 'बिल्ली'},
    'dog': {'te': 'కుక్క', 'hi': 'कुत्ता'},
    'horse': {'te': 'గుర్రం', 'hi': 'घोड़ा'},
    'sheep': {'te': 'గొర్రె', 'hi': 'भेड़'},
    'cow': {'te': 'ఆవు', 'hi': 'गाय'},
    'elephant': {'te': 'ఏనుగు', 'hi': 'हाथी'},
    'bear': {'te': 'ఎలుగుబంటి', 'hi': 'भालू'},
    'zebra': {'te': 'జీబ్రా', 'hi': 'ज़ेबरा'},
    'giraffe': {'te': 'జిరాఫీ', 'hi': 'जिराफ़'},
    'backpack': {'te': 'బ్యాక్‌ప్యాక్', 'hi': 'बैकपैक'},
    'umbrella': {'te': 'గొడుగు', 'hi': 'छाता'},
    'handbag': {'te': 'హ్యాండ్‌బ్యాగ్', 'hi': 'हैंडबैग'},
    'tie': {'te': 'టై', 'hi': 'टाई'},
    'suitcase': {'te': 'సూట్‌కేస్', 'hi': 'सूटकेस'},
    'frisbee': {'te': 'ఫ్రిస్బీ', 'hi': 'फ्रिस्बी'},
    'skis': {'te': 'స్కీలు', 'hi': 'स्की'},
    'snowboard': {'te': 'స్నోబోర్డ్', 'hi': 'स्नोबोर्ड'},
    'sports ball': {'te': 'క్రీడా బంతి', 'hi': 'खेल गेंद'},
    'kite': {'te': 'గాలిపటం', 'hi': 'पतंग'},
    'baseball bat': {'te': 'బేస్‌బాల్ బ్యాట్', 'hi': 'बेसबॉल बैट'},
    'baseball glove': {'te': 'బేస్‌బాల్ గ్లోవ్', 'hi': 'बेसबॉल ग्लव'},
    'skateboard': {'te': 'స్కేట్‌బోర్డ్', 'hi': 'स्केटबोर्ड'},
    'surfboard': {'te': 'సర్ఫ్‌బోర్డ్', 'hi': 'सर्फ़बोर्ड'},
    'tennis racket': {'te': 'టెన్నిస్ రాకెట్', 'hi': 'टेनिस रैकेट'},
    'bottle': {'te': 'బాటిల్', 'hi': 'बोतल'},
    'wine glass': {'te': 'వైన్ గ్లాస్', 'hi': 'वाइन ग्लास'},
    'cup': {'te': 'కప్పు', 'hi': 'कप'},
    'fork': {'te': 'ఫోర్క్', 'hi': 'कांटा'},
    'knife': {'te': 'కత్తి', 'hi': 'चाकू'},
    'spoon': {'te': 'చెంచా', 'hi': 'चम्मच'},
    'bowl': {'te': 'గిన్నె', 'hi': 'कटोरा'},
    'banana': {'te': 'అరటిపండు', 'hi': 'केला'},
    'apple': {'te': 'ఆపిల్', 'hi': 'सेब'},
    'sandwich': {'te': 'శాండ్‌విచ్', 'hi': 'सैंडविच'},
    'orange': {'te': 'నారింజ', 'hi': 'संतरा'},
    'broccoli': {'te': 'బ్రోకలీ', 'hi': 'ब्रोकोली'},
    'carrot': {'te': 'క్యారట్', 'hi': 'गाजर'},
    'hot dog': {'te': 'హాట్ డాగ్', 'hi': 'हॉट डॉग'},
    'pizza': {'te': 'పిజ్జా', 'hi': 'पिज़्ज़ा'},
    'donut': {'te': 'డోనట్', 'hi': 'डोनट'},
    'cake': {'te': 'కేక్', 'hi': 'केक'},
    'chair': {'te': 'కుర్చీ', 'hi': 'कुर्सी'},
    'couch': {'te': 'సోఫా', 'hi': 'सोफ़ा'},
    'potted plant': {'te': 'కుండీ మొక్క', 'hi': 'गमले का पौधा'},
    'bed': {'te': 'మంచం', 'hi': 'बिस्तर'},
    'dining table': {'te': 'డైనింగ్ టేబుల్', 'hi': 'डाइनिंग टेबल'},
    'toilet': {'te': 'టాయిలెట్', 'hi': 'शौचालय'},
    'tv': {'te': 'టీవీ', 'hi': 'टीवी'},
    'laptop': {'te': 'ల్యాప్‌టాప్', 'hi': 'लैपटॉप'},
    'mouse': {'te': 'మౌస్', 'hi': 'माउस'},
    'remote': {'te': 'రిమోట్', 'hi': 'रिमोट'},
    'keyboard': {'te': 'కీబోర్డ్', 'hi': 'कीबोर्ड'},
    'cell phone': {'te': 'సెల్ ఫోన్', 'hi': 'मोबाइल फ़ोन'},
    'microwave': {'te': 'మైక్రోవేవ్', 'hi': 'माइक्रोवेव'},
    'oven': {'te': 'ఓవెన్', 'hi': 'ओवन'},
    'toaster': {'te': 'టోస్టర్', 'hi': 'टोस्टर'},
    'sink': {'te': 'సింక్', 'hi': 'सिंक'},
    'refrigerator': {'te': 'రిఫ్రిజిరేటర్', 'hi': 'रेफ्रिजरेटर'},
    'book': {'te': 'పుస్తకం', 'hi': 'किताब'},
    'clock': {'te': 'గడియారం', 'hi': 'घड़ी'},
    'vase': {'te': 'పూల కుండీ', 'hi': 'फूलदान'},
    'scissors': {'te': 'కత్తెర', 'hi': 'कैंची'},
    'teddy bear': {'te': 'టెడ్డీ బేర్', 'hi': 'टेडी बेयर'},
    'hair drier': {'te': 'హెయిర్ డ్రయ్యర్', 'hi': 'हेयर ड्रायर'},
    'toothbrush': {'te': 'టూత్‌బ్రష్', 'hi': 'टूथब्रश'},
  };

  /// Translate an object name (from YOLO detection) to the current language.
  static String translateObject(String objectName) {
    if (_currentLanguage == 'en') return objectName;
    final lowerName = objectName.toLowerCase();
    final translations = _objectTranslations[lowerName];
    if (translations != null && translations.containsKey(_currentLanguage)) {
      return translations[_currentLanguage]!;
    }
    return objectName; // Return original if no translation found
  }

  /// Build a spoken sentence for detected objects.
  static String buildDetectionSentence(List<String> objectNames) {
    if (objectNames.isEmpty) return translate('noObjectsDetected');

    final translatedNames = objectNames.map((name) => translateObject(name)).toList();
    final prefix = translate('iCanSee');
    final conjunction = translate('and');
    final article = translate('aObject');

    if (translatedNames.length == 1) {
      return '$prefix $article ${translatedNames[0]}.';
    }

    final lastObject = translatedNames.removeLast();
    final objectList = translatedNames.map((n) => '$article $n').join(', ');
    return '$prefix $objectList $conjunction $article $lastObject.';
  }
}
