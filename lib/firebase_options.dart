// File generated manually from GoogleService-Info.plist (iOS) and google-services.json (Android)
// Equivalent to what FlutterFire CLI would generate with: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Opciones de Firebase para Android
  /// Fuente: android/app/google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyADt7S00PXoj2DMHPe9ikGOIY2VyevRp7g',
    appId: '1:431679242489:android:7dc2de136a2829efa16228',
    messagingSenderId: '431679242489',
    projectId: 'appacerosarequipa-e5183',
    storageBucket: 'appacerosarequipa-e5183.firebasestorage.app',
  );

  /// Opciones de Firebase para iOS
  /// Fuente: ios/Runner/GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqPEdbLlKXH3TtJgs4FDsmXqpDRMqlGkw',
    appId: '1:431679242489:ios:410627d7ee1bbd7ba16228',
    messagingSenderId: '431679242489',
    projectId: 'appacerosarequipa-e5183',
    storageBucket: 'appacerosarequipa-e5183.firebasestorage.app',
    iosClientId: null, // Agregar si usas Google Sign-In en iOS
    iosBundleId: 'com.example.acerosArequipa',
  );
}
