import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ai_mobile_assistant/services/voice_service.dart';
import 'package:ai_mobile_assistant/theme/app_theme.dart';
import 'package:ai_mobile_assistant/utils/constants.dart';

/// Currency detection screen — captures note and identifies denomination.
class CurrencyDetectionScreen extends StatefulWidget {
  const CurrencyDetectionScreen({super.key});

  @override
  State<CurrencyDetectionScreen> createState() => _CurrencyDetectionScreenState();
}

class _CurrencyDetectionScreenState extends State<CurrencyDetectionScreen> {
  CameraController? _cameraController;
  final VoiceService _voiceService = VoiceService();
  bool _isProcessing = false;
  String _result = '';
  String _denomination = '';
  double _confidence = 0.0;
  bool _detected = false;
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _voiceService.init();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (mounted) setState(() => _cameraReady = true);
    _voiceService.speak('Currency detection ready. Point camera at a note and tap detect.');
  }

  Future<void> _detectCurrency() async {
    if (_isProcessing || _cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
      _result = 'Analyzing...';
    });

    try {
      final image = await _cameraController!.takePicture();
      final file = File(image.path);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.apiBaseUrl}/currency'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send().timeout(
        const Duration(seconds: 10),
      );
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (mounted) {
        setState(() {
          _detected = data['detected'] ?? false;
          _denomination = data['denomination'] ?? 'Unknown';
          _confidence = (data['confidence'] ?? 0.0).toDouble();
          _result = _detected
              ? 'Detected: $_denomination note'
              : 'Could not identify. Try again.';
          _isProcessing = false;
        });

        if (_detected) {
          _voiceService.speak('This is a $_denomination rupee note');
        } else {
          _voiceService.speak('Could not identify the currency. Please try again with better lighting.');
        }
      }

      // Clean up
      if (file.existsSync()) file.deleteSync();
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = 'Error: Check connection';
          _isProcessing = false;
        });
        _voiceService.speak('Error detecting currency. Please check the connection.');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Currency Detection'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Camera preview
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _cameraReady && _cameraController != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              CameraPreview(_cameraController!),
                              // Overlay guide
                              Center(
                                child: Container(
                                  width: 260,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _detected
                                          ? AppTheme.successColor
                                          : AppTheme.primaryLight.withValues(alpha: 0.6),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Place note here',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            color: AppTheme.surfaceColor,
                            child: const Center(
                              child: CircularProgressIndicator(color: AppTheme.primaryLight),
                            ),
                          ),
                  ),
                ),
              ),

              // Result panel
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Result card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: _detected
                              ? LinearGradient(
                                  colors: [
                                    AppTheme.successColor.withValues(alpha: 0.15),
                                    AppTheme.successColor.withValues(alpha: 0.05),
                                  ],
                                )
                              : AppTheme.cardGradient,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: _detected
                                ? AppTheme.successColor.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _detected ? Icons.check_circle : Icons.currency_rupee,
                              size: 40,
                              color: _detected ? AppTheme.successColor : AppTheme.primaryLight,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _denomination.isNotEmpty ? _denomination : '---',
                              style: TextStyle(
                                fontSize: _detected ? 36 : 28,
                                fontWeight: FontWeight.w900,
                                color: _detected ? AppTheme.successColor : Colors.white,
                              ),
                            ),
                            if (_result.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                _result,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                            if (_detected && _confidence > 0) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _confidence,
                                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                                  valueColor: const AlwaysStoppedAnimation(AppTheme.successColor),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Detect button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _detectCurrency,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.currency_rupee, size: 22),
                          label: Text(
                            _isProcessing ? 'Detecting...' : 'Detect Currency',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryLight,
                            foregroundColor: AppTheme.primaryDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
