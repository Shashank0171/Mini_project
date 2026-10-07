import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ai_mobile_assistant/localization/app_localizations.dart';
import 'package:ai_mobile_assistant/services/voice_service.dart';
import 'package:ai_mobile_assistant/theme/app_theme.dart';
import 'package:ai_mobile_assistant/utils/permissions.dart';
import 'package:ai_mobile_assistant/widgets/accessible_button.dart';
import 'package:ai_mobile_assistant/widgets/loading_widget.dart';

/// OCR Text Reader screen using Google ML Kit.
class TextReaderScreen extends StatefulWidget {
  const TextReaderScreen({super.key});

  @override
  State<TextReaderScreen> createState() => _TextReaderScreenState();
}

class _TextReaderScreenState extends State<TextReaderScreen> {
  CameraController? _cameraController;
  final VoiceService _voiceService = VoiceService();

  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _recognizedText;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _voiceService.init();
  }

  Future<void> _initCamera() async {
    final hasPermission = await PermissionUtils.requestCamera();
    if (!hasPermission) {
      setState(() => _errorMessage = AppLocalizations.t('cameraPermissionRequired'));
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = AppLocalizations.t('featureUnavailable'));
        return;
      }
      _cameraController = CameraController(cameras.first, ResolutionPreset.high);
      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = '${AppLocalizations.t('error')}: $e');
    }
  }

  Future<void> _captureAndScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
      _recognizedText = null;
      _errorMessage = null;
    });

    _voiceService.speak(AppLocalizations.t('scanning'));

    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() => _capturedImagePath = image.path);

      // Determine script based on language
      final lang = AppLocalizations.currentLanguage;
      TextRecognitionScript script = TextRecognitionScript.latin;
      if (lang == 'hi') {
        script = TextRecognitionScript.devanagiri;
      }

      final textRecognizer = TextRecognizer(script: script);
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      String text = recognizedText.text;

      // If no text found with Devanagari, try Latin as fallback
      if (text.isEmpty && script != TextRecognitionScript.latin) {
        final latinRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final latinResult = await latinRecognizer.processImage(inputImage);
        await latinRecognizer.close();
        text = latinResult.text;
      }

      if (!mounted) return;

      if (text.isEmpty) {
        setState(() => _recognizedText = '');
        _voiceService.speak(AppLocalizations.t('noTextFound'));
      } else {
        setState(() => _recognizedText = text);
        _voiceService.speak('${AppLocalizations.t('textFound')}. $text');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = AppLocalizations.t('ocrNotAvailable'));
      _voiceService.speak(AppLocalizations.t('ocrNotAvailable'));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _readAloud() {
    if (_recognizedText != null && _recognizedText!.isNotEmpty) {
      _voiceService.speak(_recognizedText!);
    }
  }

  void _stopReading() {
    _voiceService.stop();
  }

  void _clearText() {
    _voiceService.stop();
    setState(() {
      _recognizedText = null;
      _capturedImagePath = null;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.t('textReader')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null && !_isCameraInitialized) {
      return _buildError(_errorMessage!);
    }
    if (!_isCameraInitialized) return const LoadingWidget();

    return Column(
      children: [
        // Camera or captured image
        Expanded(
          flex: 2,
          child: _capturedImagePath != null
              ? Image.file(File(_capturedImagePath!), fit: BoxFit.contain)
              : CameraPreview(_cameraController!),
        ),
        // Results area
        Expanded(
          flex: 3,
          child: _isProcessing
              ? LoadingWidget(message: AppLocalizations.t('scanning'))
              : _buildResultsArea(),
        ),
      ],
    );
  }

  Widget _buildResultsArea() {
    if (_recognizedText != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Recognized text
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Semantics(
                  label: _recognizedText!.isEmpty
                      ? AppLocalizations.t('noTextFound')
                      : _recognizedText,
                  child: SingleChildScrollView(
                    child: Text(
                      _recognizedText!.isEmpty
                          ? AppLocalizations.t('noTextFound')
                          : _recognizedText!,
                      style: TextStyle(
                        fontSize: 18,
                        color: _recognizedText!.isEmpty
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AccessibleButton(
                    label: AppLocalizations.t('readAloud'),
                    icon: Icons.volume_up,
                    onPressed: _recognizedText!.isNotEmpty ? _readAloud : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AccessibleButton(
                    label: AppLocalizations.t('stopReading'),
                    icon: Icons.stop,
                    backgroundColor: Colors.orange,
                    onPressed: _stopReading,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AccessibleButton(
                    label: AppLocalizations.t('clearText'),
                    icon: Icons.clear,
                    backgroundColor: Colors.grey,
                    onPressed: _clearText,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.t('textReaderDesc'),
            style: const TextStyle(fontSize: 18, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AccessibleButton(
            label: AppLocalizations.t('scanText'),
            icon: Icons.document_scanner,
            isLarge: true,
            onPressed: _captureAndScan,
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            AccessibleButton(
              label: AppLocalizations.t('retry'),
              icon: Icons.refresh,
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
