import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ai_mobile_assistant/models/emergency_contact.dart';

/// Emergency SOS service for building and sharing emergency messages.
class SosService {
  /// Send an emergency SOS by building a message and sharing it.
  Future<bool> sendSOS({
    required Position position,
    required List<EmergencyContact> contacts,
    required String languageCode,
  }) async {
    try {
      final message = buildEmergencyMessage(
        position: position,
        languageCode: languageCode,
      );
      await shareEmergencyMessage(message);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Build an emergency message in the selected language with GPS coordinates.
  String buildEmergencyMessage({
    required Position position,
    required String languageCode,
  }) {
    final mapsLink =
        'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    final locationStr =
        'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';

    String text;
    switch (languageCode) {
      case 'te':
        text = 'అత్యవసరం! నాకు సహాయం కావాలి. నా ప్రస్తుత స్థానం:';
        break;
      case 'hi':
        text = 'आपातकाल! मुझे सहायता चाहिए। मेरा वर्तमान स्थान:';
        break;
      default:
        text = 'Emergency! I need assistance. My current location is:';
    }

    return '$text\n\n$locationStr\n\n$mapsLink';
  }

  /// Share the emergency message via platform share sheet.
  Future<void> shareEmergencyMessage(String message) async {
    await Share.share(message);
  }
}
