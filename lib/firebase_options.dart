import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Default Firebase configuration for Android
// Generated from google-services.json
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Android configuration from google-services.json
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      appId: '1:956265194974:android:03416e364c059bdcbf694f',
      messagingSenderId: '956265194974',
      projectId: 'athlete-traning-bda61',
      databaseURL: 'https://athlete-traning-bda61-default-rtdb.asia-southeast1.firebasedatabase.app',
      storageBucket: 'athlete-traning-bda61.firebasestorage.app',
    );
  }
}
