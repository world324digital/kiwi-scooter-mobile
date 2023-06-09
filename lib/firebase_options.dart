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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAGkIsaHlMzRGJe5IWHqV8Ro9lXsOKTekM",
    authDomain: "kiwi-city-d5730.firebaseapp.com",
    databaseURL: "https://kiwi-city-d5730-default-rtdb.firebaseio.com",
    projectId: "kiwi-city-d5730",
    storageBucket: "kiwi-city-d5730.appspot.com",
    messagingSenderId: "1080982779471",
    appId: "1:1080982779471:web:13a55314a64e6761029c3a",
    measurementId: "G-YJT9XG4KBF",
    // apiKey: "AIzaSyAZZztgD9razvUmANdUKeCRDTtlsOFpMCs",
    // authDomain: "kiwi-scooter.firebaseapp.com",
    // databaseURL: "https://kiwi-scooter-default-rtdb.firebaseio.com",
    // projectId: "kiwi-scooter",
    // storageBucket: "kiwi-scooter.appspot.com",
    // messagingSenderId: "692539061467",
    // appId: "1:692539061467:web:8756e0bee2f5dac2c788fe",
    // measurementId: "G-RC91PN1WS0",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0YV6vgjZWWEBGThS3_rjfVaTNIO6ujMo',
    appId: '1:1080982779471:android:8b66c89ab64af98c029c3a',
    messagingSenderId: '1080982779471',
    projectId: "kiwi-city-d5730",
    databaseURL: "https://kiwi-city-d5730-default-rtdb.firebaseio.com",
    storageBucket: "kiwi-city-d5730.appspot.com",
    // apiKey: 'AIzaSyBIPOZuJL4FEgdWdMiA3QOVN1gk1DVFLGY',
    // appId: '1:692539061467:android:999717682406be14c788fe',
    // messagingSenderId: '692539061467',
    // projectId: "kiwi-scooter",
    // databaseURL: "https://kiwi-scooter-default-rtdb.firebaseio.com",
    // storageBucket: "kiwi-scooter.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAhUUNZr4_qPzztGA2KTM2X7rr8HMQ4fws',
    appId: '1:1080982779471:ios:d95b5a81eb60971b029c3a',
    messagingSenderId: '1080982779471',
    projectId: "kiwi-city-d5730",
    databaseURL: "https://kiwi-city-d5730-default-rtdb.firebaseio.com",
    storageBucket: "kiwi-city-d5730.appspot.com",
    iosClientId:
        '1080982779471-kuilpkalvn39jt33lmal6kdk67cgn2ns.apps.googleusercontent.com',
    iosBundleId: 'com.kiwicity.co',
    // apiKey: 'AIzaSyC8crUAmOLlg8qUMQ4J0Wa8oJyidaHpF-k',
    // appId: '1:692539061467:ios:02b3d6560891d87bc788fe',
    // messagingSenderId: '692539061467',
    // projectId: "kiwi-scooter",
    // databaseURL: "https://kiwi-scooter-default-rtdb.firebaseio.com",
    // storageBucket: "kiwi-scooter.appspot.com",
    // iosClientId:
    //     '692539061467-vmjrj57jp6cem8sjqedou830rv8erldg.apps.googleusercontent.com',
    // iosBundleId: 'com.kiwicity.app',
  );
}
