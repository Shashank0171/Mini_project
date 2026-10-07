import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ai_mobile_assistant/app.dart';
import 'package:ai_mobile_assistant/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize storage service
  final storageService = StorageService();
  await storageService.init();

  runApp(const AIMobileAssistantApp());
}
