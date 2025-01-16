/*
// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyBeXOvzMzCx2oSXS8c6f_51V_2iSov0wjE',
    appId: '1:121885362786:web:27bc42939039ec67575f3b',
    messagingSenderId: '121885362786',
    projectId: 'daimonion-app',
    authDomain: 'daimonion-app.firebaseapp.com',
    storageBucket: 'daimonion-app.firebasestorage.app',
    measurementId: 'G-MFBLWLV7Y5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJhJDGICfi4SBnmULFQhTwNUaaGvxPH_M',
    appId: '1:121885362786:android:13fe6c8e4f1bb058575f3b',
    messagingSenderId: '121885362786',
    projectId: 'daimonion-app',
    storageBucket: 'daimonion-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWuVWFwKb2KvMc5hgq0sau5HFDqLRyM40',
    appId: '1:121885362786:ios:5b107658478cadbc575f3b',
    messagingSenderId: '121885362786',
    projectId: 'daimonion-app',
    storageBucket: 'daimonion-app.firebasestorage.app',
    iosBundleId: 'com.example.daimonionApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCWuVWFwKb2KvMc5hgq0sau5HFDqLRyM40',
    appId: '1:121885362786:ios:5b107658478cadbc575f3b',
    messagingSenderId: '121885362786',
    projectId: 'daimonion-app',
    storageBucket: 'daimonion-app.firebasestorage.app',
    iosBundleId: 'com.example.daimonionApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBeXOvzMzCx2oSXS8c6f_51V_2iSov0wjE',
    appId: '1:121885362786:web:b39175232ef45c0e575f3b',
    messagingSenderId: '121885362786',
    projectId: 'daimonion-app',
    authDomain: 'daimonion-app.firebaseapp.com',
    storageBucket: 'daimonion-app.firebasestorage.app',
    measurementId: 'G-C8NGV5P0SE',
  );
}
*/
