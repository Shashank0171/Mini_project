import 'package:permission_handler/permission_handler.dart';

/// Centralized permission handling utility.
class PermissionUtils {
  PermissionUtils._();

  /// Request camera permission.
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request microphone permission.
  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Request location permission.
  static Future<bool> requestLocation() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check camera permission without requesting.
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Check microphone permission without requesting.
  static Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  /// Check location permission without requesting.
  static Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  /// Check if permission is permanently denied.
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    return await permission.isPermanentlyDenied;
  }

  /// Open app settings for the user to manually grant permissions.
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Request all permissions needed for the app.
  static Future<Map<Permission, PermissionStatus>> requestAll() async {
    return await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
    ].request();
  }
}
