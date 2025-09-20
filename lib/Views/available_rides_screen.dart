// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:pacpic_rider/views/ride_navigation_screen.dart';

// class AvailableRidesScreen extends StatefulWidget {
//   // 1. ADD THIS: It now requires the riderId to be passed in.
//   final String riderId;
//   const AvailableRidesScreen({super.key, required this.riderId});

//   @override
//   State<AvailableRidesScreen> createState() => _AvailableRidesScreenState();
// }

// class _AvailableRidesScreenState extends State<AvailableRidesScreen> {
//   final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref().child('orders');

//   // 2. REMOVED: The line fetching the riderId from FirebaseAuth is gone.
//   // final String _riderId = FirebaseAuth.instance.currentUser!.uid;

//   StreamSubscription? _ordersSubscription;
//   List<DataSnapshot> _availableOrders = [];

//   @override
//   void initState() {
//     super.initState();
//     _listenForAvailableOrders();
//   }

//   @override
//   void dispose() {
//     _ordersSubscription?.cancel();
//     super.dispose();
//   }

//   void _listenForAvailableOrders() {
//     _ordersSubscription = _ordersRef
//         .orderByChild('status')
//         .equalTo('pending')
//         .onValue
//         .listen((event) {
//       if (mounted && event.snapshot.exists) {
//         final orders = event.snapshot.children.toList();
//         setState(() => _availableOrders = orders);
//       } else if(mounted) {
//         setState(() => _availableOrders = []);
//       }
//     });
//   }

//   Future<void> _acceptOrder(String orderId) async {
//     try {
//       await _ordersRef.child(orderId).update({
//         'status': 'accepted',
//         'riderId': widget.riderId, // 3. USE WIDGET.RIDERID HERE
//       });
//       await FirebaseDatabase.instance
//           .ref()
//           .child('riders/${widget.riderId}') // 4. AND HERE
//           .update({'isAvailable': false});

//       if(mounted){
//         Navigator.of(context).push(MaterialPageRoute(
//           builder: (ctx) => RideNavigationScreen(orderId: orderId),
//         ));
//       }
//     } catch (e) {
//       if(mounted){
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to accept order: $e")),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_availableOrders.isEmpty) {
//       return const Center(child: Text('No available rides right now.'));
//     }

//     return ListView.builder(
//       itemCount: _availableOrders.length,
//       itemBuilder: (context, index) {
//         final orderSnapshot = _availableOrders[index];
//         final orderData = Map<String, dynamic>.from(orderSnapshot.value as Map);

//         return FutureBuilder<Position>(
//           future: Geolocator.getCurrentPosition(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Card(
//                 margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 child: ListTile(title: Text("Calculating distance...")),
//               );
//             }
//             final riderPosition = snapshot.data!;
//             final restaurantLocation = orderData['restaurantLocation'];
//             final riderToRestaurantDist = Geolocator.distanceBetween(
//                 riderPosition.latitude, riderPosition.longitude,
//                 restaurantLocation['latitude'], restaurantLocation['longitude']
//             ) / 1000;

//             Widget distanceTextWidget;
//             if (orderData['orderType'] == 'tier') {
//               distanceTextWidget = Text('Restaurant to customer: ${orderData['deliveryTier']}');
//             } else {
//               final distance = orderData['distance'] != null
//                   ? '${orderData['distance'].toStringAsFixed(2)} km'
//                   : 'N/A';
//               distanceTextWidget = Text('Restaurant to customer: $distance');
//             }

//             final double restaurantPrice = (orderData['price'] ?? 0.0).toDouble();
//             final double riderEarning = restaurantPrice * 15 / 25;

//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(orderData['restaurantName'] ?? 'New Order', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                     const Divider(),
//                     Text('Your distance to restaurant: ${riderToRestaurantDist.toStringAsFixed(2)} km'),
//                     distanceTextWidget,
//                     Text(
//                         'Your Earning: ₹${riderEarning.toStringAsFixed(2)}',
//                         style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
//                     ),
//                     const SizedBox(height: 10),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () => _acceptOrder(orderSnapshot.key!),
//                         child: const Text('Accept Ride'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:pacpic_rider/views/ride_navigation_screen.dart';

// class AvailableRidesScreen extends StatefulWidget {
// const AvailableRidesScreen({super.key});

// @override
// State<AvailableRidesScreen> createState() => _AvailableRidesScreenState();
// }

// class _AvailableRidesScreenState extends State<AvailableRidesScreen> {
// final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref().child('orders');
// final String _riderId = FirebaseAuth.instance.currentUser!.uid;
// StreamSubscription? _ordersSubscription;
// List<DataSnapshot> _availableOrders = [];

// @override
// void initState() {
// super.initState();
// _listenForAvailableOrders();
// }

// @override
// void dispose() {
// _ordersSubscription?.cancel();
// super.dispose();
// }

// void _listenForAvailableOrders() {
// _ordersSubscription = _ordersRef
// .orderByChild('status')
// .equalTo('pending')
// .onValue
// .listen((event) {
// if (mounted && event.snapshot.exists) {
// final orders = event.snapshot.children.toList();
// setState(() => _availableOrders = orders);
// } else if(mounted) {
// setState(() => _availableOrders = []);
// }
// });
// }

// Future<void> _acceptOrder(String orderId) async {
// try {
// await _ordersRef.child(orderId).update({
// 'status': 'accepted',
// 'riderId': _riderId,
// });
// await FirebaseDatabase.instance
// .ref()
// .child('riders/$_riderId')
// .update({'isAvailable': false});

// if(mounted){
// Navigator.of(context).push(MaterialPageRoute(
// builder: (ctx) => RideNavigationScreen(orderId: orderId),
// ));
// }
// } catch (e) {
// if(mounted){
// ScaffoldMessenger.of(context).showSnackBar(
// SnackBar(content: Text("Failed to accept order: $e")),
// );
// }
// }
// }

// @override
// Widget build(BuildContext context) {
// if (_availableOrders.isEmpty) {
// return const Center(child: Text('No available rides right now.'));
// }

// return ListView.builder(
// itemCount: _availableOrders.length,
// itemBuilder: (context, index) {
// final orderSnapshot = _availableOrders[index];
// final orderData = Map<String, dynamic>.from(orderSnapshot.value as Map);

// return FutureBuilder<Position>(
// future: Geolocator.getCurrentPosition(),
// builder: (context, snapshot) {
// if (!snapshot.hasData) {
// return const Card(
// margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// child: ListTile(title: Text("Calculating distance...")),
// );
// }
// final riderPosition = snapshot.data!;
// final restaurantLocation = orderData['restaurantLocation'];
// final riderToRestaurantDist = Geolocator.distanceBetween(
// riderPosition.latitude, riderPosition.longitude,
// restaurantLocation['latitude'], restaurantLocation['longitude']
// ) / 1000;

// Widget distanceTextWidget;
// if (orderData['orderType'] == 'tier') {
// distanceTextWidget = Text('🍔 ➡️ 🛵 ➡️ 🏠: ${orderData['deliveryTier']}');
// } else {
// final distance = orderData['distance'] != null
// ? '${orderData['distance'].toStringAsFixed(2)} km'
// : 'N/A';
// distanceTextWidget = Text('🍔 ➡️ 🛵 ➡️ 🏠: $distance');
// }

// // --- THIS IS THE CHANGE ---
// // Calculate the rider's earning from the total price
// final double restaurantPrice = (orderData['price'] ?? 0.0).toDouble();
// final double riderEarning = restaurantPrice * 15 / 25;
// // --- END OF CHANGE ---

// return Card(
// margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// child: Padding(
// padding: const EdgeInsets.all(12.0),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text(orderData['restaurantName'] ?? 'New Order', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
// const Divider(),
// Text('📍 ... ➡️ 🍔: ${riderToRestaurantDist.toStringAsFixed(2)} km'),
// distanceTextWidget,
// // Use the new riderEarning variable here
// Text(
// 'Your Earning: ₹${riderEarning.toStringAsFixed(2)}',
// style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
// ),
// const SizedBox(height: 10),
// SizedBox(
// width: double.infinity,
// child: ElevatedButton(
// onPressed: () => _acceptOrder(orderSnapshot.key!),
// child: const Text('Accept Ride'),
// ),
// ),
// ],
// ),
// ),
// );
// },
// );
// },
// );
// }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pacpic_rider/views/ride_navigation_screen.dart';
import 'package:audioplayers/audioplayers.dart'; // Import the new package

class AvailableRidesScreen extends StatefulWidget {
  // It now requires the riderId
  final String riderId;
  const AvailableRidesScreen({super.key, required this.riderId});

  @override
  State<AvailableRidesScreen> createState() => _AvailableRidesScreenState();
}

class _AvailableRidesScreenState extends State<AvailableRidesScreen> {
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref().child('orders');
  StreamSubscription? _ordersSubscription;
  List<DataSnapshot> _availableOrders = [];
  Position? _currentRiderPosition;

  // --- NEW: State for the alarm ---
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAlarmPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      _currentRiderPosition = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {});
        _listenForAvailableOrders();
      }
    } catch (e) {
      // Handle location errors
    }
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _audioPlayer.dispose(); // Clean up the audio player
    super.dispose();
  }

  void _listenForAvailableOrders() {
    _ordersSubscription = _ordersRef
        .orderByChild('status')
        .equalTo('pending')
        .onValue
        .listen((event) {
      if (mounted && event.snapshot.exists) {
        final wasEmpty = _availableOrders.isEmpty;
        final orders = event.snapshot.children.toList();
        setState(() => _availableOrders = orders);

        // --- NEW: Start the alarm if a new ride appears ---
        if (wasEmpty && orders.isNotEmpty) {
          _startAlarm();
        }
      } else if (mounted) {
        // Stop alarm if there are no more rides
        if (_availableOrders.isNotEmpty) {
          _stopAlarm();
        }
        setState(() => _availableOrders = []);
      }
    });
  }

  // --- NEW: Functions to control the alarm ---
  void _startAlarm() async {
    if (_isAlarmPlaying) return;
    setState(() => _isAlarmPlaying = true);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // Make sure your sound file is named 'alarm.mp3' and is in 'assets/sounds/'
    await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
  }

  void _stopAlarm() {
    if (!_isAlarmPlaying) return;
    setState(() => _isAlarmPlaying = false);
    _audioPlayer.stop();
  }

  Future<void> _acceptOrder(String orderId) async {
    _stopAlarm(); // Stop the alarm when a ride is accepted
    try {
      await _ordersRef.child(orderId).update({
        'status': 'accepted',
        'riderId': widget.riderId,
      });
      await FirebaseDatabase.instance
          .ref()
          .child('riders/${widget.riderId}')
          .update({'isAvailable': false});

      if(mounted){
        Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => RideNavigationScreen(orderId: orderId),
        ));
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentRiderPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // --- NEW: Wrap the content in a Column to add the alarm banner ---
    return Column(
      children: [
        // Alarm banner that only appears when the alarm is ringing
        if (_isAlarmPlaying)
          MaterialBanner(
            padding: const EdgeInsets.all(12),
            content: const Text('New ride request available!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.blue,
            actions: [
              TextButton(
                onPressed: _stopAlarm,
                child: const Text('DISMISS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        
        // Your existing ride list
        Expanded(
          child: _availableOrders.isEmpty
              ? const Center(child: Text('No available rides right now.'))
              : ListView.builder(
                  itemCount: _availableOrders.length,
                  itemBuilder: (context, index) {
                    final orderSnapshot = _availableOrders[index];
                    final orderData = Map<String, dynamic>.from(orderSnapshot.value as Map);

                    final restaurantLocation = orderData['restaurantLocation'];
                    final riderToRestaurantDist = Geolocator.distanceBetween(
                        _currentRiderPosition!.latitude, _currentRiderPosition!.longitude,
                        restaurantLocation['latitude'], restaurantLocation['longitude']
                    ) / 1000;

                    Widget distanceTextWidget;
                    if (orderData['orderType'] == 'tier') {
                      distanceTextWidget = Text('Restaurant to customer: ${orderData['deliveryTier']}');
                    } else {
                      final distance = orderData['distance'] != null
                          ? '${orderData['distance'].toStringAsFixed(2)} km'
                          : 'N/A';
                      distanceTextWidget = Text('Restaurant to customer: $distance');
                    }
                    
                    final double restaurantPrice = (orderData['price'] ?? 0.0).toDouble();
                    final double riderEarning = restaurantPrice * 15 / 25;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(orderData['restaurantName'] ?? 'New Order', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const Divider(),
                            Text('Your distance to restaurant: ${riderToRestaurantDist.toStringAsFixed(2)} km'),
                            distanceTextWidget,
                            Text(
                                'Your Earning: ₹${riderEarning.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _acceptOrder(orderSnapshot.key!),
                                child: const Text('Accept Ride'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}