
// import 'dart:io';
//
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:pacpic_rider/LoginPage.dart';
// import 'package:pacpic_rider/services/background_service.dart';
// import 'package:pacpic_rider/views/available_rides_screen.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:device_info_plus/device_info_plus.dart';
//
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   // Initialize the service once when the app starts.
//   // It will automatically handle login/logout internally.
//   await initializeService();
//   await setupPushNotifications();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PacPic Rider',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const AuthGate(),
//     );
//   }
// }
// Future<void> setupPushNotifications() async {
//   final fcm = FirebaseMessaging.instance;
//
//   // 1. Request Permission
//   await fcm.requestPermission();
//
//   // 2. Get the token
//   final token = await fcm.getToken();
//   debugPrint("FCM Token: $token"); // For testing
//
//   // 3. Save the token to the current rider's profile
//   final user = FirebaseAuth.instance.currentUser;
//   if (user != null) {
//     await FirebaseDatabase.instance
//         .ref('riders/${user.uid}')
//         .update({'fcmToken': token});
//   }
//
//   // Also, save the token whenever it refreshes
//   fcm.onTokenRefresh.listen((newToken) {
//     if (user != null) {
//       FirebaseDatabase.instance
//           .ref('riders/${user.uid}')
//           .update({'fcmToken': newToken});
//     }
//   });
// }
// // AuthGate remains simple and clean. It just routes the user.
// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         } else if (snapshot.hasData) {
//           // User is logged in, show the home screen.
//           return const RiderHomeScreen();
//         } else {
//           // User is not logged in, show the login screen.
//           return const LoginScreen();
//         }
//       },
//     );
//   }
// }
//
// // --- EXAMPLE: How to handle permissions in your HomeScreen ---
// // You would add this logic to your existing RiderHomeScreen widget.
//
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:pacpic_rider/LoginPage.dart';
// import 'package:pacpic_rider/services/background_service.dart';
// import 'package:pacpic_rider/views/available_rides_screen.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // All startup tasks are now handled here
//   await initializeService();
//   await setupPushNotifications();
//   await requestCorePermissions(); // <-- Added this line
//
//   runApp(const MyApp());
// }
//
// // This NEW function handles location permissions
// Future<void> requestCorePermissions() async {
//   // Request foreground location permission
//   var status = await Permission.location.request();
//
//   // If granted, then request background location permission for the service
//   if (status.isGranted) {
//     await Permission.locationAlways.request();
//   }
// }
//
// Future<void> setupPushNotifications() async {
//   final fcm = FirebaseMessaging.instance;
//   await fcm.requestPermission();
//   final token = await fcm.getToken();
//   debugPrint("FCM Token: $token"); // For testing
//
//   // Listen to auth state to save token only when logged in
//   FirebaseAuth.instance.authStateChanges().listen((User? user) {
//     if (user != null && token != null) {
//       FirebaseDatabase.instance
//           .ref('riders/${user.uid}')
//           .update({'fcmToken': token});
//     }
//   });
//
//   fcm.onTokenRefresh.listen((newToken) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       FirebaseDatabase.instance
//           .ref('riders/${user.uid}')
//           .update({'fcmToken': newToken});
//     }
//   });
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PacPic Rider',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const AuthGate(),
//     );
//   }
// }
//
// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         } else if (snapshot.hasData) {
//           return const RiderHomeScreen();
//         } else {
//           return const LoginScreen();
//         }
//       },
//     );
//   }
// }
import 'package:firebase_database/firebase_database.dart';
import 'package:pacpic_rider/Views/main_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pacpic_rider/LoginPage.dart';
import 'package:pacpic_rider/services/background_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // All startup tasks are now handled here
  await initializeService();
  await setupPushNotifications();
  await requestCorePermissions();

  runApp(const MyApp());
}

Future<void> requestCorePermissions() async {
  var status = await Permission.location.request();
  if (status.isGranted) {
    await Permission.locationAlways.request();
  }
}

Future<void> setupPushNotifications() async {
  final fcm = FirebaseMessaging.instance;
  await fcm.requestPermission();
  final token = await fcm.getToken();
  debugPrint("FCM Token: $token"); // For testing

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null && token != null) {
      FirebaseDatabase.instance
          .ref('riders/${user.uid}')
          .update({'fcmToken': token});
    }
  });

  fcm.onTokenRefresh.listen((newToken) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseDatabase.instance
          .ref('riders/${user.uid}')
          .update({'fcmToken': newToken});
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PacPic Rider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // --- THIS IS THE FIX ---
      // We removed the 'home' property and added 'initialRoute'
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
      },
      // --- END OF FIX ---
    );
  }
}

// In your main.dart file

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // --- CHANGE THIS LINE ---
          // Pass the user data to the MainScreen
          return MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}