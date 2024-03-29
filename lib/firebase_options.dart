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
    apiKey: 'AIzaSyCvXFsLEwYM_iP5DUN0ZidAuddYmyMZIP0',
    appId: '1:781976423389:web:efad9e0c15b723bc138434',
    messagingSenderId: '781976423389',
    projectId: 'expensetracker-20621',
    authDomain: 'expensetracker-20621.firebaseapp.com',
    storageBucket: 'expensetracker-20621.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDsLPKaZq-JogkC8v0Pe-PW70KlbO-V6jQ',
    appId: '1:781976423389:android:9a5d7df5222a5964138434',
    messagingSenderId: '781976423389',
    projectId: 'expensetracker-20621',
    storageBucket: 'expensetracker-20621.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRb_Zx_PPtV9w_mKNjr8tRtuQWv4feJAI',
    appId: '1:781976423389:ios:1d129dff0763f231138434',
    messagingSenderId: '781976423389',
    projectId: 'expensetracker-20621',
    storageBucket: 'expensetracker-20621.appspot.com',
    iosClientId: '781976423389-db7uijiun23aed6imqr6jhaovnha572u.apps.googleusercontent.com',
    iosBundleId: 'com.example.expenseTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCRb_Zx_PPtV9w_mKNjr8tRtuQWv4feJAI',
    appId: '1:781976423389:ios:1d129dff0763f231138434',
    messagingSenderId: '781976423389',
    projectId: 'expensetracker-20621',
    storageBucket: 'expensetracker-20621.appspot.com',
    iosClientId: '781976423389-db7uijiun23aed6imqr6jhaovnha572u.apps.googleusercontent.com',
    iosBundleId: 'com.example.expenseTracker',
  );
}
