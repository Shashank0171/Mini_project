import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Navigation service using OSRM for routing and Nominatim for place search.
class NavigationService {
  /// Search for a place using Nominatim OpenStreetMap API.
  Future<List<Map<String, dynamic>>> searchPlace(String query) async {
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5');
      final response = await http.get(uri, headers: {
        'User-Agent': 'AIMobileAssistant/1.0',
      });

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        return json.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get route between two points using OSRM public API.
  Future<Map<String, dynamic>> getRoute(LatLng start, LatLng end) async {
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&steps=true';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['routes'] != null && (json['routes'] as List).isNotEmpty) {
          final route = json['routes'][0];

          // Convert GeoJSON coordinates to LatLng
          final coordinates = route['geometry']['coordinates'] as List;
          final points = coordinates
              .map<LatLng>((coord) => LatLng(
                    (coord[1] as num).toDouble(),
                    (coord[0] as num).toDouble(),
                  ))
              .toList();

          final steps = route['legs'][0]['steps'] as List? ?? [];
          final instructions = steps
              .map<Map<String, dynamic>>((step) => {
                    'text': step['name'] ?? '',
                    'distance': step['distance'] ?? 0,
                    'duration': step['duration'] ?? 0,
                    'maneuver': step['maneuver'] ?? {},
                  })
              .toList();

          return {
            'points': points,
            'distance': (route['distance'] as num).toDouble(),
            'duration': (route['duration'] as num).toDouble(),
            'instructions': instructions,
          };
        }
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Get a voice instruction translated to the selected language.
  String getVoiceInstruction(
      Map<String, dynamic> instruction, String langCode) {
    final maneuver = instruction['maneuver'] as Map<String, dynamic>? ?? {};
    String type = maneuver['type']?.toString() ?? '';
    String modifier = maneuver['modifier']?.toString() ?? '';
    String name = instruction['text']?.toString() ?? '';

    if (langCode == 'te') {
      if (type == 'arrive') return 'మీరు గమ్యస్థానానికి చేరుకున్నారు';
      if (modifier.contains('left')) return 'ఎడమ వైపు తిరగండి';
      if (modifier.contains('right')) return 'కుడి వైపు తిరగండి';
      return 'నేరుగా వెళ్ళండి';
    } else if (langCode == 'hi') {
      if (type == 'arrive') return 'आप अपने गंतव्य पर पहुंच गए हैं';
      if (modifier.contains('left')) return 'बाईं ओर मुड़ें';
      if (modifier.contains('right')) return 'दाईं ओर मुड़ें';
      return 'सीधे जाएं';
    }

    if (type == 'arrive') return 'You have arrived at your destination';
    if (type == 'turn') {
      return 'Turn $modifier${name.isNotEmpty ? ' onto $name' : ''}';
    }
    return 'Continue straight${name.isNotEmpty ? ' on $name' : ''}';
  }

  /// Calculate distance between two points in meters.
  double calculateDistance(LatLng p1, LatLng p2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((p2.latitude - p1.latitude) * p) / 2 +
        math.cos(p1.latitude * p) *
            math.cos(p2.latitude * p) *
            (1 - math.cos((p2.longitude - p1.longitude) * p)) /
            2;
    return 12742000 * math.asin(math.sqrt(a));
  }
}
