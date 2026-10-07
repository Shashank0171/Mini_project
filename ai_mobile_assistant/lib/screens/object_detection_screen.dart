import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:ai_mobile_assistant/localization/app_localizations.dart';
import 'package:ai_mobile_assistant/services/api_service.dart';
import 'package:ai_mobile_assistant/services/voice_service.dart';
import 'package:ai_mobile_assistant/theme/app_theme.dart';
import 'package:ai_mobile_assistant/utils/permissions.dart';
import 'package:ai_mobile_assistant/widgets/loading_widget.dart';
import 'package:ai_mobile_assistant/models/detection_result.dart';

/// Object detection screen — always tracking objects via camera + YOLOv8.
class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  State<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  final VoiceService _voiceService = VoiceService();
  final ApiService _apiService = ApiService();

  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _hasPermission = false;
  bool _isTracking = true;
  String? _errorMessage;
  List<DetectionResult> _results = [];
  Timer? _trackingTimer;
  String _lastSpoken = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _voiceService.init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _stopTracking();
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    _hasPermission = await PermissionUtils.requestCamera();
    if (!_hasPermission) {
      setState(
          () => _errorMessage = AppLocalizations.t('cameraPermissionRequired'));
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(
            () => _errorMessage = AppLocalizations.t('featureUnavailable'));
        return;
      }
      _cameraController =
          CameraController(cameras.first, ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
        _startTracking();
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = '${AppLocalizations.t('error')}: $e');
      }
    }
  }

  void _startTracking() {
    _trackingTimer?.cancel();
    _isTracking = true;
    // Capture and detect every 2.5 seconds
    _trackingTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (_isTracking && !_isProcessing && mounted) {
        _captureAndDetect();
      }
    });
    // Run first detection immediately
    _captureAndDetect();
  }

  void _stopTracking() {
    _trackingTimer?.cancel();
    _isTracking = false;
  }

  Future<void> _captureAndDetect() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) return;

    _isProcessing = true;

    try {
      final XFile image = await _cameraController!.takePicture();
      final file = File(image.path);
      final results = await _apiService.detectObjects(file);

      // Clean up temp file
      try {
        await file.delete();
      } catch (_) {}

      if (!mounted) return;

      setState(() => _results = results);

      // Only speak if objects changed
      final currentObjects =
          results.map((r) => r.name).toList()..sort();
      final spokenKey = currentObjects.join(',');

      if (spokenKey != _lastSpoken && results.isNotEmpty) {
        _lastSpoken = spokenKey;
        final objectNames = results.map((r) => r.name).toList();
        final sentence =
            AppLocalizations.buildDetectionSentence(objectNames);
        _voiceService.speak(sentence);
      } else if (results.isEmpty && _lastSpoken.isNotEmpty) {
        _lastSpoken = '';
      }
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString();
      if (errorMsg.contains('Connection') ||
          errorMsg.contains('SocketException')) {
        setState(
            () => _errorMessage = AppLocalizations.t('backendUnavailable'));
        _stopTracking();
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTracking();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.t('objectDetection')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Pause/Resume tracking toggle
          IconButton(
            icon: Icon(_isTracking ? Icons.pause : Icons.play_arrow),
            tooltip: _isTracking ? 'Pause tracking' : 'Resume tracking',
            onPressed: () {
              setState(() {
                if (_isTracking) {
                  _stopTracking();
                } else {
                  _startTracking();
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null && !_isCameraInitialized) {
      return _buildErrorView(_errorMessage!);
    }

    if (!_isCameraInitialized) {
      return const LoadingWidget();
    }

    return Stack(
      children: [
        // Full-screen camera preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),

        // Detection results overlay at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildResultsOverlay(),
        ),

        // Tracking indicator at top
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isTracking
                    ? Colors.green.withValues(alpha: 0.85)
                    : Colors.orange.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isTracking ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isTracking ? 'Tracking...' : 'Paused',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (_isTracking && _isProcessing) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Error banner
        if (_errorMessage != null)
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      setState(() => _errorMessage = null);
                      _startTracking();
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultsOverlay() {
    if (_results.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          _isTracking
              ? AppLocalizations.t('objectDetectionDesc')
              : 'Tap play to resume tracking',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle,
                  color: AppTheme.primaryLight, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_results.length} object${_results.length > 1 ? 's' : ''} detected',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...(_results.take(5).map((r) {
            final translatedName =
                AppLocalizations.translateObject(r.name);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      translatedName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      r.confidencePercent,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          })),
          if (_results.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${_results.length - 5} more',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 56, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.t('retry')),
              onPressed: () {
                setState(() => _errorMessage = null);
                _initCamera();
              },
            ),
          ],
        ),
      ),
    );
  }
}
