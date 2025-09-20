import 'dart:async';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:geolocator/geolocator.dart';
//
// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//       notificationChannelId: 'location_service',
//       initialNotificationTitle: 'PacPic Rider',
//       initialNotificationContent: 'Tracking location in background...',
//       foregroundServiceNotificationId: 888,
//     ),
//     iosConfiguration: IosConfiguration(
//       onForeground: onStart,
//       onBackground: (_) async => true,
//     ),
//   );
//
//   service.startService();
// }
//
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();
//   await Firebase.initializeApp();
//
//   Geolocator.requestPermission();
//
//   Timer.periodic(const Duration(seconds: 15), (timer) async {
//     if (service is AndroidServiceInstance && !(await service.isForegroundService())) return;
//
//     final position = await Geolocator.getCurrentPosition();
//     final uid = FirebaseDatabase.instance.app.options.projectId; // Replace with actual user ID
//
//     FirebaseDatabase.instance.ref("riders/$uid/location").set({
//       "latitude": position.latitude,
//       "longitude": position.longitude,
//       "timestamp": DateTime.now().millisecondsSinceEpoch
//     });
//
//     service.setForegroundNotificationInfo(
//       title: "PacPic Rider",
//       content: "Location: ${position.latitude}, ${position.longitude}",
//     );
//   });
// }
import 'dart:async';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:firebase_database/firebase_database.dart';
import 'package:pacpic_rider/firebase_options.dart'; // Make sure this path is correct

/// Initializes and configures the background service.
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'location_channel',
      initialNotificationTitle: 'PacPic Rider',
      initialNotificationContent: 'Waiting for rider login...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  // Start the service automatically
  service.startService();
}

/// This is the entry point for the background isolate.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // This MUST be called on the new isolate
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  StreamSubscription<Position>? locationSubscription;

  // Listen to Firebase Auth state changes
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      // User is logged out
      locationSubscription?.cancel();
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "PacPic Rider - Offline",
          content: "Please log in to start tracking.",
        );
      }
    } else {
      // User is logged in, get the UID
      final riderUid = user.uid;

      // Start listening to location updates
      locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) {
        // Send location data to Firebase
        FirebaseDatabase.instance.ref("riders/$riderUid/location").set({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        });

        // Update the foreground notification
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: "PacPic Rider - Online",
            content: "You are online and receiving ride requests",
          );
        }
      });
    }
  });
}

/// Entry point for iOS background execution
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  return true;
}