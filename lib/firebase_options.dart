// File generated manually from google-services.json values.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDONTojD_Tsv8PVXzSQ-R6y8nKzrR4IAlk',
    appId: '1:284740617538:android:1c0d9009d2aba06d98f4db',
    messagingSenderId: '284740617538',
    projectId: 'agri-pulse-50e41',
    storageBucket: 'agri-pulse-50e41.firebasestorage.app',
  );

  // Web config — you must register a Web App in Firebase Console and
  // replace these placeholder values with the actual ones.
  // Go to: Firebase Console → Project Settings → General → Your apps → Add app (Web)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBJEw2EzHPFfgF6iQeVAPZn7zpA4FM2wr4',
    appId: '1:284740617538:web:08c787d5a2e97ba798f4db',
    messagingSenderId: '284740617538',
    projectId: 'agri-pulse-50e41',
    authDomain: 'agri-pulse-50e41.firebaseapp.com',
    storageBucket: 'agri-pulse-50e41.firebasestorage.app',
  );
}
