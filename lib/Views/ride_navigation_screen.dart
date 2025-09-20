// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class RideNavigationScreen extends StatefulWidget {
//   final String orderId;
//   const RideNavigationScreen({super.key, required this.orderId});
//
//   @override
//   State<RideNavigationScreen> createState() => _RideNavigationScreenState();
// }
//
// class _RideNavigationScreenState extends State<RideNavigationScreen> {
//   // In a real app, you would use a directions API to draw a polyline route.
//   // For simplicity, we will just show markers for the rider and restaurant.
//   Set<Marker> _markers = {};
//   LatLng? _restaurantLocation;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchOrderDetails();
//   }
//
//   Future<void> _fetchOrderDetails() async {
//     final snapshot = await FirebaseDatabase.instance.ref().child('orders/${widget.orderId}').get();
//     if (snapshot.exists) {
//       final data = Map<String, dynamic>.from(snapshot.value as Map);
//       setState(() {
//         _restaurantLocation = LatLng(
//           data['restaurantLocation']['latitude'],
//           data['restaurantLocation']['longitude'],
//         );
//         _markers.add(Marker(
//           markerId: const MarkerId('restaurant'),
//           position: _restaurantLocation!,
//           infoWindow: const InfoWindow(title: 'Restaurant'),
//         ));
//       });
//     }
//   }
//
//   Future<void> _completePickup() async {
//     final riderId = FirebaseAuth.instance.currentUser!.uid;
//     try {
//       // Set rider's availability back to true
//       await FirebaseDatabase.instance.ref().child('riders/$riderId').update({'isAvailable': true});
//
//       // Optionally, update order status to something like 'picked_up' or 'completed'
//       await FirebaseDatabase.instance.ref().child('orders/${widget.orderId}').update({'status': 'completed'});
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Pickup complete! You are now available for new rides.")),
//       );
//       Navigator.of(context).pop(); // Go back to the home screen
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to update status: $e")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Navigate to Restaurant')),
//       body: _restaurantLocation == null
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _restaurantLocation!,
//               zoom: 15,
//             ),
//             markers: _markers,
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: ElevatedButton(
//               onPressed: _completePickup,
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 16)),
//               child: const Text('Reached Restaurant', style: TextStyle(fontSize: 18, color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//
// // IMPORTANT: Replace this with your own Google Maps API Key
// const String googleMapsApiKey = "AIzaSyBRaty5Cs4xkv1dgudw_mS0PYyMxms4HFQ";
//
// class RideNavigationScreen extends StatefulWidget {
//   final String orderId;
//   const RideNavigationScreen({super.key, required this.orderId});
//
//   @override
//   State<RideNavigationScreen> createState() => _RideNavigationScreenState();
// }
//
// class _RideNavigationScreenState extends State<RideNavigationScreen> {
//   // --- NEW STATE VARIABLES ---
//   GoogleMapController? _mapController;
//   Position? _currentPosition;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   LatLng? _restaurantLocation;
//   StreamSubscription<Position>? _positionStream;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchOrderAndDrawRoute();
//   }
//
//   @override
//   void dispose() {
//     // Stop listening to location updates when the screen is closed
//     _positionStream?.cancel();
//     _mapController?.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchOrderAndDrawRoute() async {
//     // First, get the rider's current location
//     _currentPosition = await Geolocator.getCurrentPosition();
//
//     // Then, get the restaurant's location from the order
//     final snapshot = await FirebaseDatabase.instance.ref().child('orders/${widget.orderId}').get();
//     if (snapshot.exists) {
//       final data = Map<String, dynamic>.from(snapshot.value as Map);
//       _restaurantLocation = LatLng(
//         data['restaurantLocation']['latitude'],
//         data['restaurantLocation']['longitude'],
//       );
//
//       // Now that we have both points, get the route
//       await _getPolyline();
//       _listenToRiderLocation();
//     }
//   }
//
//   // --- NEW FUNCTION TO GET THE ROUTE ---
//   Future<void> _getPolyline() async {
//     if (_currentPosition == null || _restaurantLocation == null) return;
//
//     PolylinePoints polylinePoints = PolylinePoints();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleMapsApiKey,
//       PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//       PointLatLng(_restaurantLocation!.latitude, _restaurantLocation!.longitude),
//     );
//
//     if (result.points.isNotEmpty) {
//       List<LatLng> polylineCoordinates = [];
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//
//       setState(() {
//         // Add the route line to the map
//         _polylines.add(Polyline(
//           polylineId: const PolylineId('route'),
//           color: Colors.blue,
//           points: polylineCoordinates,
//           width: 5,
//         ));
//
//         // Add markers for rider and restaurant
//         _markers.add(Marker(
//           markerId: const MarkerId('rider'),
//           position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//           infoWindow: const InfoWindow(title: 'You'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         ));
//         _markers.add(Marker(
//           markerId: const MarkerId('restaurant'),
//           position: _restaurantLocation!,
//           infoWindow: const InfoWindow(title: 'Restaurant'),
//         ));
//       });
//
//       // Animate camera to fit the route
//       _mapController?.animateCamera(
//         CameraUpdate.newLatLngBounds(
//           LatLngBounds(
//             southwest: LatLng(
//                 _currentPosition!.latitude < _restaurantLocation!.latitude ? _currentPosition!.latitude : _restaurantLocation!.latitude,
//                 _currentPosition!.longitude < _restaurantLocation!.longitude ? _currentPosition!.longitude : _restaurantLocation!.longitude
//             ),
//             northeast: LatLng(
//                 _currentPosition!.latitude > _restaurantLocation!.latitude ? _currentPosition!.latitude : _restaurantLocation!.latitude,
//                 _currentPosition!.longitude > _restaurantLocation!.longitude ? _currentPosition!.longitude : _restaurantLocation!.longitude
//             ),
//           ),
//           50.0, // Padding
//         ),
//       );
//     }
//   }
//
//   // --- NEW FUNCTION TO UPDATE RIDER'S MARKER IN REAL-TIME ---
//   void _listenToRiderLocation() {
//     _positionStream = Geolocator.getPositionStream().listen((Position position) {
//       setState(() {
//         _currentPosition = position;
//         // Update the rider marker's position
//         _markers.removeWhere((m) => m.markerId.value == 'rider');
//         _markers.add(Marker(
//           markerId: const MarkerId('rider'),
//           position: LatLng(position.latitude, position.longitude),
//           infoWindow: const InfoWindow(title: 'You'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         ));
//       });
//       // Optionally, animate the camera to the new position
//       _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
//     });
//   }
//
//   Future<void> _completePickup() async {
//     // ... This function remains exactly the same ...
//     final riderId = FirebaseAuth.instance.currentUser!.uid;
//     try {
//       await FirebaseDatabase.instance.ref().child('riders/$riderId').update({'isAvailable': true});
//       await FirebaseDatabase.instance.ref().child('orders/${widget.orderId}').update({'status': 'completed'});
//
//       if(mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Pickup complete! You are now available for new rides.")),
//         );
//         Navigator.of(context).pop();
//       }
//     } catch (e) {
//       if(mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to update status: $e")),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Navigate to Restaurant')),
//       body: _currentPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: (controller) => _mapController = controller,
//             initialCameraPosition: CameraPosition(
//               target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//               zoom: 15,
//             ),
//             markers: _markers,
//             polylines: _polylines, // Display the route
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: ElevatedButton(
//               onPressed: _completePickup,
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 16)),
//               child: const Text('Reached Restaurant', style: TextStyle(fontSize: 18, color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RideNavigationScreen extends StatefulWidget {
  final String orderId;
  const RideNavigationScreen({super.key, required this.orderId});

  @override
  State<RideNavigationScreen> createState() => _RideNavigationScreenState();
}

class _RideNavigationScreenState extends State<RideNavigationScreen> {
  LatLng? _restaurantLocation;
  String _restaurantName = "Loading...";
  String _restaurantAddress = "Loading address...";

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    final orderSnapshot = await FirebaseDatabase.instance.ref().child('orders/${widget.orderId}').get();
    if (mounted && orderSnapshot.exists) {
      final orderData = Map<String, dynamic>.from(orderSnapshot.value as Map);
      
      // Also fetch the restaurant's address from its own profile for accuracy
      final restaurantProfileSnapshot = await FirebaseDatabase.instance.ref('restaurants/${orderData['restaurantId']}/profile').get();
      if (restaurantProfileSnapshot.exists) {
        final profileData = Map<String, dynamic>.from(restaurantProfileSnapshot.value as Map);
        _restaurantAddress = profileData['address'] ?? 'Address not available';
      }

      setState(() {
        _restaurantName = orderData['restaurantName'] ?? 'The Restaurant';
        _restaurantLocation = LatLng(
          orderData['restaurantLocation']['latitude'],
          orderData['restaurantLocation']['longitude'],
        );
      });
    }
  }

  Future<void> _launchGoogleMapsNavigation() async {
    if (_restaurantLocation == null) return;

    final lat = _restaurantLocation!.latitude;
    final lng = _restaurantLocation!.longitude;
    // This URL format is best for launching turn-by-turn navigation
    final url = Uri.parse('google.navigation:q=$lat,$lng&mode=d');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Fallback if Google Maps is not installed
      final webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Maps not installed. Opening in browser.')),
        );
      }
      await launchUrl(webUrl);
    }
  }

  // --- THIS FUNCTION IS NOW CORRECTED ---
  Future<void> _completePickup() async {
    final riderId = FirebaseAuth.instance.currentUser!.uid;
    try {
      // 1. Set rider's availability back to true
      await FirebaseDatabase.instance.ref().child('riders/$riderId').update({'isAvailable': true});
      
      // 2. Update order status to 'completed'
      await FirebaseDatabase.instance.ref().child('orders/${widget.orderId}').update({'status': 'completed'});

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ride complete! You are now available for new rides.")),
        );
        // This is now the only way to leave the screen
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update status: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget prevents the user from going back using the back button or gesture
    return PopScope(
      canPop: false, // This blocks the back gesture/button
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pickup Navigation'),
          automaticallyImplyLeading: false, // This removes the default back arrow
        ),
        body: _restaurantLocation == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.storefront, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 20),
              Text(
                'Head to:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _restaurantName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _restaurantAddress,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.navigation_rounded),
                label: const Text('Start Navigation'),
                onPressed: _launchGoogleMapsNavigation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _completePickup,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Reached Restaurant', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
