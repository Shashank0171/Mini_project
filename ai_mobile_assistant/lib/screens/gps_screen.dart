import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ai_mobile_assistant/localization/app_localizations.dart';
import 'package:ai_mobile_assistant/services/location_service.dart';
import 'package:ai_mobile_assistant/services/navigation_service.dart';
import 'package:ai_mobile_assistant/services/voice_service.dart';
import 'package:ai_mobile_assistant/theme/app_theme.dart';
import 'package:ai_mobile_assistant/utils/permissions.dart';
import 'package:ai_mobile_assistant/widgets/accessible_button.dart';
import 'package:ai_mobile_assistant/widgets/loading_widget.dart';

/// GPS Navigation screen with OpenStreetMap.
class GpsScreen extends StatefulWidget {
  const GpsScreen({super.key});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  final LocationService _locationService = LocationService();
  final NavigationService _navigationService = NavigationService();
  final VoiceService _voiceService = VoiceService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  double? _routeDistance;
  bool _isNavigating = false;
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _searchResults = [];
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _voiceService.init();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final hasPermission = await PermissionUtils.requestLocation();
    if (!hasPermission) {
      setState(() {
        _errorMessage = AppLocalizations.t('locationPermissionRequired');
        _isLoading = false;
      });
      return;
    }

    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null && mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = AppLocalizations.t('locationUnavailable');
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.t('locationUnavailable');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchDestination(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);

    try {
      final results = await _navigationService.searchPlace(query);
      if (mounted) setState(() => _searchResults = results);
    } catch (e) {
      if (mounted) _voiceService.speak(AppLocalizations.t('networkError'));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _selectDestination(Map<String, dynamic> place) async {
    final lat = double.tryParse(place['lat'].toString());
    final lon = double.tryParse(place['lon'].toString());
    if (lat == null || lon == null) return;

    setState(() {
      _destination = LatLng(lat, lon);
      _searchResults = [];
      _searchController.text = place['display_name'] ?? '';
    });

    if (_currentLocation != null) {
      try {
        final route = await _navigationService.getRoute(_currentLocation!, _destination!);
        if (mounted) {
          setState(() {
            _routePoints = route['points'] as List<LatLng>? ?? [];
            _routeDistance = route['distance'] as double?;
          });

          final distanceText = _routeDistance != null
              ? _routeDistance! > 1000
                  ? '${(_routeDistance! / 1000).toStringAsFixed(1)} ${AppLocalizations.t('kilometersAway')}'
                  : '${_routeDistance!.toStringAsFixed(0)} ${AppLocalizations.t('metersAway')}'
              : '';
          _voiceService.speak('${AppLocalizations.t('destination')}. $distanceText');
        }
      } catch (e) {
        if (mounted) {
          _voiceService.speak(AppLocalizations.t('routeNotFound'));
        }
      }
    }
  }

  void _startNavigation() {
    if (_currentLocation == null || _destination == null) return;
    setState(() => _isNavigating = true);
    _voiceService.speak(AppLocalizations.t('navigating'));

    _positionSubscription = _locationService.getPositionStream(
      onPosition: (position) {
        if (!mounted) return;
        final newPos = LatLng(position.latitude, position.longitude);
        setState(() => _currentLocation = newPos);

        final dist = _navigationService.calculateDistance(newPos, _destination!);
        if (dist < 20) {
          _stopNavigation();
          _voiceService.speak(AppLocalizations.t('destinationReached'));
        }
      },
    );
  }

  void _stopNavigation() {
    _positionSubscription?.cancel();
    setState(() => _isNavigating = false);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.t('navigation')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null && _currentLocation == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 56, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              AccessibleButton(label: AppLocalizations.t('retry'), icon: Icons.refresh, onPressed: () {
                setState(() { _errorMessage = null; _isLoading = true; });
                _initLocation();
              }),
            ],
          ),
        ),
      );
    }

    if (_isLoading) return const LoadingWidget();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: Semantics(
            label: AppLocalizations.t('searchDestination'),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.t('searchDestination'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(icon: const Icon(Icons.search), onPressed: () => _searchDestination(_searchController.text)),
              ),
              onSubmitted: _searchDestination,
            ),
          ),
        ),
        // Search results
        if (_searchResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (_, i) {
                final place = _searchResults[i];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: AppTheme.primaryColor),
                  title: Text(place['display_name'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => _selectDestination(place),
                );
              },
            ),
          ),
        // Map
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(17.385, 78.4867),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.aimobileassistant.ai_mobile_assistant',
              ),
              MarkerLayer(
                markers: [
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 3),
                        ),
                        child: const Icon(Icons.my_location, color: Colors.blue, size: 20),
                      ),
                    ),
                  if (_destination != null)
                    Marker(
                      point: _destination!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                ],
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(points: _routePoints, strokeWidth: 5, color: Colors.blue),
                  ],
                ),
            ],
          ),
        ),
        // Distance info + controls
        if (_destination != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: Column(
              children: [
                if (_routeDistance != null)
                  Semantics(
                    label: '${AppLocalizations.t('distance')}: ${_routeDistance! > 1000 ? '${(_routeDistance! / 1000).toStringAsFixed(1)} km' : '${_routeDistance!.toStringAsFixed(0)} m'}',
                    child: Text(
                      '${AppLocalizations.t('distance')}: ${_routeDistance! > 1000 ? '${(_routeDistance! / 1000).toStringAsFixed(1)} km' : '${_routeDistance!.toStringAsFixed(0)} m'}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 12),
                AccessibleButton(
                  label: _isNavigating
                      ? AppLocalizations.t('stopNavigation')
                      : AppLocalizations.t('startNavigation'),
                  icon: _isNavigating ? Icons.stop : Icons.navigation,
                  backgroundColor: _isNavigating ? Colors.red : AppTheme.primaryColor,
                  onPressed: _isNavigating ? _stopNavigation : _startNavigation,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
