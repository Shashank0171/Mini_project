import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:ai_mobile_assistant/localization/app_localizations.dart';
import 'package:ai_mobile_assistant/services/api_service.dart';
import 'package:ai_mobile_assistant/services/voice_service.dart';
import 'package:ai_mobile_assistant/theme/app_theme.dart';
import 'package:ai_mobile_assistant/utils/permissions.dart';
import 'package:ai_mobile_assistant/widgets/accessible_button.dart';
import 'package:ai_mobile_assistant/widgets/loading_widget.dart';

/// Scene description screen using camera + AI backend (BLIP model).
class SceneDescriptionScreen extends StatefulWidget {
  const SceneDescriptionScreen({super.key});

  @override
  State<SceneDescriptionScreen> createState() => _SceneDescriptionScreenState();
}

class _SceneDescriptionScreenState extends State<SceneDescriptionScreen> {
  CameraController? _cameraController;
  final VoiceService _voiceService = VoiceService();
  final ApiService _apiService = ApiService();

  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _description;
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
      _cameraController = CameraController(cameras.first, ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = '${AppLocalizations.t('error')}: $e');
    }
  }

  Future<void> _captureAndDescribe() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
      _description = null;
      _errorMessage = null;
    });

    _voiceService.speak(AppLocalizations.t('describing'));

    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() => _capturedImagePath = image.path);

      final file = File(image.path);
      final description = await _apiService.describeScene(file);

      if (!mounted) return;

      if (description.isEmpty) {
        setState(() => _description = '');
        _voiceService.speak(AppLocalizations.t('noDescription'));
      } else {
        setState(() => _description = description);
        _voiceService.speak(description);
      }
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString();
      if (errorMsg.contains('Connection') || errorMsg.contains('SocketException')) {
        setState(() => _errorMessage = AppLocalizations.t('backendUnavailable'));
      } else {
        setState(() => _errorMessage = AppLocalizations.t('sceneModelNotConfigured'));
      }
      _voiceService.speak(_errorMessage!);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _retake() {
    _voiceService.stop();
    setState(() {
      _description = null;
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
        title: Text(AppLocalizations.t('sceneDescription')),
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
        Expanded(
          flex: 3,
          child: _capturedImagePath != null
              ? Image.file(File(_capturedImagePath!), fit: BoxFit.contain)
              : CameraPreview(_cameraController!),
        ),
        Expanded(
          flex: 2,
          child: _isProcessing
              ? LoadingWidget(message: AppLocalizations.t('describing'))
              : _buildResultArea(),
        ),
      ],
    );
  }

  Widget _buildResultArea() {
    if (_errorMessage != null) return _buildError(_errorMessage!);

    if (_description != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Semantics(
                  label: _description!.isEmpty
                      ? AppLocalizations.t('noDescription')
                      : _description,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.landscape, color: AppTheme.primaryColor, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.t('sceneDescription'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _description!.isEmpty
                              ? AppLocalizations.t('noDescription')
                              : _description!,
                          style: const TextStyle(fontSize: 20, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AccessibleButton(
                    label: AppLocalizations.t('readAloud'),
                    icon: Icons.volume_up,
                    onPressed: _description!.isNotEmpty
                        ? () => _voiceService.speak(_description!)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AccessibleButton(
                    label: AppLocalizations.t('retake'),
                    icon: Icons.refresh,
                    backgroundColor: Colors.orange,
                    onPressed: _retake,
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
            AppLocalizations.t('sceneDescriptionDesc'),
            style: const TextStyle(fontSize: 18, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AccessibleButton(
            label: AppLocalizations.t('captureImage'),
            icon: Icons.camera_alt,
            isLarge: true,
            onPressed: _captureAndDescribe,
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
