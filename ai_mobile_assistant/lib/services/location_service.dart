import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Location service wrapping Geolocator for GPS functionality.
class LocationService {
  /// Get the current GPS position.
  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Reverse geocode a position to a human-readable address using Nominatim.
  Future<String> getAddressFromPosition(Position position) async {
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json');
      final response = await http.get(uri, headers: {
        'User-Agent': 'AIMobileAssistant/1.0',
      });
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['display_name'] ?? '${position.latitude}, ${position.longitude}';
      }
      return '${position.latitude}, ${position.longitude}';
    } catch (e) {
      return '${position.latitude}, ${position.longitude}';
    }
  }

  /// Check if location services are enabled.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get a stream of position updates.
  StreamSubscription<Position> getPositionStream({
    Function(Position)? onPosition,
  }) {
    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
    return stream.listen(onPosition);
  }
}
