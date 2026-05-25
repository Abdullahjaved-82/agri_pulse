import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import 'notification_service.dart';

class AppInitializer {
  static Future<void>? _initFuture;

  static Future<void> ensureInitialized() {
    return _initFuture ??= _initialize();
  }

  static Future<void> _initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        print('AppInitializer: Failed to load .env: $e');
      }
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (kDebugMode) {
        print('AppInitializer: Failed to initialize Firebase: $e');
      }
      rethrow;
    }

    try {
      await NotificationService.instance.initialize();
    } catch (e) {
      if (kDebugMode) {
        print('AppInitializer: Failed to initialize NotificationService: $e');
      }
    }
  }
}

