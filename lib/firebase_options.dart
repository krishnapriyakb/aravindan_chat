// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCkv9pkp77SQ8jza9IqF_z91EheV6GAQI0',
    appId: '1:136836973877:web:e48f24db6a42f6ffccf87c',
    messagingSenderId: '136836973877',
    projectId: 'chat-test-1a0a6',
    authDomain: 'chat-test-1a0a6.firebaseapp.com',
    storageBucket: 'chat-test-1a0a6.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqw1vJRVrxhgHnmiTPb5Tjo8akHOzfa9I',
    appId: '1:136836973877:android:978c4304901aafe1ccf87c',
    messagingSenderId: '136836973877',
    projectId: 'chat-test-1a0a6',
    storageBucket: 'chat-test-1a0a6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGcWnJjm51IJQQLB2nBkodFIGLZtyDVzU',
    appId: '1:136836973877:ios:93cdc55b2c19b286ccf87c',
    messagingSenderId: '136836973877',
    projectId: 'chat-test-1a0a6',
    storageBucket: 'chat-test-1a0a6.appspot.com',
    androidClientId: '136836973877-i430fj9ttikqitvdk009b0k4ibmk7tlj.apps.googleusercontent.com',
    iosClientId: '136836973877-5j85ggb4jes49hhvnri67hnpko5r3j0a.apps.googleusercontent.com',
    iosBundleId: 'com.example.chat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBGcWnJjm51IJQQLB2nBkodFIGLZtyDVzU',
    appId: '1:136836973877:ios:dc729dcc078fd4d7ccf87c',
    messagingSenderId: '136836973877',
    projectId: 'chat-test-1a0a6',
    storageBucket: 'chat-test-1a0a6.appspot.com',
    androidClientId: '136836973877-i430fj9ttikqitvdk009b0k4ibmk7tlj.apps.googleusercontent.com',
    iosClientId: '136836973877-fgjueojjp4ki3ortmnlmmb127rijnpvg.apps.googleusercontent.com',
    iosBundleId: 'com.example.chat.RunnerTests',
  );
}
