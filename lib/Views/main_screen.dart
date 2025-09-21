// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart'; // Add this import
// // import 'package:pacpic_rider/views/available_rides_screen.dart';
// // import 'package:pacpic_rider/views/history_screen.dart';
// // import 'package:pacpic_rider/views/Rider_profile_screen.dart';
//
// // class MainScreen extends StatefulWidget {
// //   // Accept the user object
// //   const MainScreen({super.key});
//
// //   @override
// //   State<MainScreen> createState() => _MainScreenState();
// // }
//
// // class _MainScreenState extends State<MainScreen> {
// //   int _selectedIndex = 0;
//
// //   // Make the screens list a state variable
// //   late final List<Widget> _screens;
//
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Initialize the screens here, passing the rider's UID
// //     _screens = <Widget>[
// //       AvailableRidesScreen(),
// //       HistoryScreen(),
// //       RiderProfileScreen(),
// //     ];
// //   }
//
// //   static const List<String> _titles = <String>[
// //     'Available Rides',
// //     'Ride History',
// //     'Your Profile',
// //   ];
//
// //   void _onItemTapped(int index) {
// //     setState(() {
// //       _selectedIndex = index;
// //     });
// //   }
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(_titles[_selectedIndex]),
// //       ),
// //       body: _screens[_selectedIndex],
// //       bottomNavigationBar: BottomNavigationBar(
// //         items: const <BottomNavigationBarItem>[
// //           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
// //           BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
// //           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
// //         ],
// //         currentIndex: _selectedIndex,
// //         onTap: _onItemTapped,
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Add this import
// import 'package:pacpic_rider/views/available_rides_screen.dart';
// import 'package:pacpic_rider/views/history_screen.dart';
// import 'package:pacpic_rider/views/rider_profile_screen.dart';
//
// class MainScreen extends StatefulWidget {
//   // The constructor is simple, as you requested.
//   const MainScreen({super.key});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;
//   late final List<Widget> _screens;
//   bool _isLoading = true; // To show a loading spinner briefly
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeScreens();
//   }
//
//   void _initializeScreens() {
//     // It's safe to get the user here because AuthGate ensures we are logged in.
//     final user = FirebaseAuth.instance.currentUser;
//
//     if (user != null) {
//       // --- THIS IS THE FIX ---
//       // Initialize all screens, passing the rider's UID to each one
//       _screens = <Widget>[
//         AvailableRidesScreen(riderId: user.uid),
//         HistoryScreen(riderId: user.uid),
//         RiderProfileScreen(),
//       ];
//       // --- END OF FIX ---
//
//       // Once screens are ready, stop loading
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     } else {
//       // This is a safety fallback. If this happens, something is wrong.
//       // We safely sign out and let AuthGate redirect to the login screen.
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         FirebaseAuth.instance.signOut();
//       });
//     }
//   }
//
//   static const List<String> _titles = <String>[
//     'Available Rides',
//     'Ride History',
//     'Your Profile',
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Show a loading indicator until the user ID is fetched and screens are ready
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_titles[_selectedIndex]),
//       ),
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pacpic_rider/views/available_rides_screen.dart';
import 'package:pacpic_rider/views/history_screen.dart';
import 'package:pacpic_rider/views/rider_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _screens = <Widget>[
        AvailableRidesScreen(riderId: user.uid),
        HistoryScreen(riderId: user.uid),
        RiderProfileScreen(),
      ];
      if (mounted) setState(() => _isLoading = false);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FirebaseAuth.instance.signOut();
      });
    }
  }



  void _showHelplineDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.support_agent),
            SizedBox(width: 8),
            Text('Rider Helpline'),
          ],
        ),
        content: FutureBuilder<DataSnapshot>(
          future: FirebaseDatabase.instance.ref('helpline/phone').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return const Text('Could not load helpline number.');
            }
            if (snapshot.hasData && snapshot.data!.exists) {
              final phoneNumber = snapshot.data!.value.toString();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('For any issues, please contact:'),
                  const SizedBox(height: 8),
                  Text(phoneNumber,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.call),
                    label: const Text('Call Now'),
                    onPressed: () async {
                      final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
                      if (await canLaunchUrl(callUri)) {
                        await launchUrl(callUri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open dialer.')),
                        );
                      }
                    },
                  )
                ],
              );
            }
            return const Text('Helpline number not available.');
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }


  static const List<String> _titles = <String>[
    'Available Rides',
    'Ride History',
    'Your Profile',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent),
            tooltip: 'Helpline',
            onPressed: _showHelplineDialog,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}