// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:intl/intl.dart';
// import 'package:pacpic_rider/views/ride_navigation_screen.dart'; // ADDED: Import for navigation
// import 'package:pacpic_rider/views/customer_delivery_screen.dart'; // ADDED: Import for customer delivery

// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({super.key});

//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   final String _riderId = FirebaseAuth.instance.currentUser!.uid;

//   // --- MODIFIED STATE VARIABLES ---
//   List<DataSnapshot> _completedOrders = [];
//   DataSnapshot? _activeOrder; // ADDED: To hold the current, uncompleted ride
//   double _totalEarnings = 0.0;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchOrders(); // MODIFIED: Renamed function
//   }

//   // --- MODIFIED: This function now fetches BOTH active and completed orders ---
//   Future<void> _fetchOrders() async {
//     // Reset state before fetching
//     _activeOrder = null;
//     _completedOrders = [];
//     _totalEarnings = 0.0;

//     try {
//       final snapshot = await FirebaseDatabase.instance
//           .ref('orders')
//           .orderByChild('riderId')
//           .equalTo(_riderId)
//           .get();

//       if (mounted && snapshot.exists) {
//         double earnings = 0.0;
//         final completed = <DataSnapshot>[];

//         for (final orderSnapshot in snapshot.children) {
//           final data = Map<String, dynamic>.from(orderSnapshot.value as Map);
//           final status = data['status'] as String?;

//           // Check if the order is completed
//           if (status == 'completed') {
//             completed.add(orderSnapshot);
//             final double restaurantPrice = (data['price'] ?? 0.0).toDouble();
//             earnings += (restaurantPrice * 15 / 25);
//           }
//           // --- ADDED LOGIC: Check for any active order ---
//           else if (status == 'pending_pickup' || status == 'out_for_delivery') {
//             _activeOrder = orderSnapshot; // Found an active ride
//           }
//         }

//         // Sort completed orders by date
//         completed.sort((a, b) {
//           final aData = Map<String, dynamic>.from(a.value as Map);
//           final bData = Map<String, dynamic>.from(b.value as Map);
//           return (bData['createdAt'] as int).compareTo(aData['createdAt'] as int);
//         });

//         setState(() {
//           _completedOrders = completed;
//           _totalEarnings = earnings;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching history: $e");
//     }

//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // --- ADDED: Navigation logic for the active ride card ---
//   void _navigateToActiveRide() {
//     if (_activeOrder == null) return;

//     final orderId = _activeOrder!.key!;
//     final data = Map<String, dynamic>.from(_activeOrder!.value as Map);
//     final status = data['status'] as String?;

//     // Navigate to the correct screen based on the order's current status
//     if (status == 'pending_pickup') {
//       Navigator.of(context).push(
//         MaterialPageRoute(builder: (_) => RideNavigationScreen(orderId: orderId)),
//       );
//     } else if (status == 'out_for_delivery') {
//       Navigator.of(context).push(
//         MaterialPageRoute(builder: (_) => CustomerDeliveryScreen(orderId: orderId)),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return RefreshIndicator(
//       onRefresh: _fetchOrders, // MODIFIED: Call the updated function
//       child: Column(
//         children: [
//           // --- ADDED: Widget to display the active ride if it exists ---
//           if (_activeOrder != null)
//             Card(
//               color: Colors.blue.shade50,
//               margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
//               elevation: 4,
//               child: ListTile(
//                 leading: const Icon(Icons.delivery_dining, color: Colors.blue, size: 36),
//                 title: const Text('Active Ride In Progress', style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: const Text('Tap here to continue your delivery'),
//                 trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
//                 onTap: _navigateToActiveRide, // This makes it tappable
//               ),
//             ),

//           // --- Your existing UI for earnings and history ---
//           Card(
//             margin: const EdgeInsets.all(12),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     'Total Earnings',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   Text(
//                     '₹${_totalEarnings.toStringAsFixed(2)}',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           if (_completedOrders.isEmpty)
//             const Expanded(
//                 child: Center(child: Text('You have no completed rides.')))
//           else
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _completedOrders.length,
//                 itemBuilder: (context, index) {
//                   final orderData = Map<String, dynamic>.from(_completedOrdes[index].value as Map);
//                   final createdAt = DateTime.fromMillisecondsSinceEpoch(orderData['createdAt']);
//                   final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
//                   final double restaurantPrice = (orderData['price'] ?? 0.0).toDouble();
//                   final double riderEarning = restaurantPrice * 15 / 25;

//                   return ListTile(
//                     leading: const Icon(Icons.check_circle_outline, color: Colors.green),
//                     title: Text(orderData['restaurantName'] ?? 'Completed Ride'),
//                     subtitle: Text('On $formattedDate'),
//                     trailing: Text('₹${riderEarning.toStringAsFixed(2)}'),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:intl/intl.dart';
// import 'package:pacpic_rider/views/ride_navigation_screen.dart'; // Import the navigation screen
//
// class HistoryScreen extends StatefulWidget {
//   // It now requires the riderId
//   final String riderId;
//   const HistoryScreen({super.key, required this.riderId});
//
//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }
//
// class _HistoryScreenState extends State<HistoryScreen> {
//   // State variables
//   List<DataSnapshot> _completedOrders = [];
//   DataSnapshot? _activeOrder; // To hold the current accepted ride
//   double _totalEarnings = 0.0;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchOrders();
//   }
//
//   /// Fetches both active and completed orders for the rider.
//   Future<void> _fetchOrders() async {
//     // Reset state before fetching
//     if (mounted) {
//       setState(() {
//         _isLoading = true;
//         _activeOrder = null;
//         _completedOrders = [];
//         _totalEarnings = 0.0;
//       });
//     }
//
//     try {
//       final snapshot = await FirebaseDatabase.instance
//           .ref('orders')
//           .orderByChild('riderId')
//           .equalTo(widget.riderId) // Use the passed-in riderId
//           .get();
//
//       if (mounted && snapshot.exists) {
//         double earnings = 0.0;
//         final completed = <DataSnapshot>[];
//         DataSnapshot? active;
//
//         for (final orderSnapshot in snapshot.children) {
//           final data = Map<String, dynamic>.from(orderSnapshot.value as Map);
//           final status = data['status'] as String?;
//
//           if (status == 'completed') {
//             completed.add(orderSnapshot);
//             final double restaurantPrice = (data['price'] ?? 0.0).toDouble();
//             earnings += (restaurantPrice * 15 / 25);
//           }
//           // --- THIS IS THE NEW LOGIC ---
//           // Check if the order is active (accepted but not completed)
//           else if (status == 'accepted') {
//             active = orderSnapshot; // Found the active ride
//           }
//         }
//
//         completed.sort((a, b) {
//           final aData = Map<String, dynamic>.from(a.value as Map);
//           final bData = Map<String, dynamic>.from(b.value as Map);
//           return (bData['createdAt'] as int).compareTo(aData['createdAt'] as int);
//         });
//
//         setState(() {
//           _completedOrders = completed;
//           _activeOrder = active;
//           _totalEarnings = earnings;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching history: $e");
//     }
//
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   /// Navigates the rider back to the active ride's navigation screen.
//   void _navigateToActiveRide() {
//     if (_activeOrder == null) return;
//
//     final orderId = _activeOrder!.key!;
//     Navigator.of(context).push(
//       MaterialPageRoute(builder: (_) => RideNavigationScreen(orderId: orderId)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return RefreshIndicator(
//       onRefresh: _fetchOrders,
//       child: Column(
//         children: [
//           // --- NEW WIDGET: Display the active ride card if one exists ---
//           if (_activeOrder != null)
//             Card(
//               color: Colors.blue.shade50,
//               margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
//               elevation: 4,
//               child: ListTile(
//                 leading: const Icon(Icons.delivery_dining, color: Colors.blue, size: 36),
//                 title: const Text('Active Ride In Progress', style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: const Text('Tap here to continue your delivery'),
//                 trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
//                 onTap: _navigateToActiveRide,
//               ),
//             ),
//
//           // Your existing UI for earnings and history
//           Card(
//             margin: const EdgeInsets.all(12),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     'Total Earnings',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   Text(
//                     '₹${_totalEarnings.toStringAsFixed(2)}',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           if (_completedOrders.isEmpty)
//             const Expanded(
//                 child: Center(child: Text('You have no completed rides.')))
//           else
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _completedOrders.length,
//                 itemBuilder: (context, index) {
//                   final orderData = Map<String, dynamic>.from(_completedOrders[index].value as Map);
//                   final createdAt = DateTime.fromMillisecondsSinceEpoch(orderData['createdAt']);
//                   final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
//                   final double restaurantPrice = (orderData['price'] ?? 0.0).toDouble();
//                   final double riderEarning = restaurantPrice * 15 / 25;
//
//                   return ListTile(
//                     leading: const Icon(Icons.check_circle_outline, color: Colors.green),
//                     title: Text(orderData['restaurantName'] ?? 'Completed Ride'),
//                     subtitle: Text('On $formattedDate'),
//                     trailing: Text('₹${riderEarning.toStringAsFixed(2)}'),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:pacpic_rider/views/ride_navigation_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String riderId;
  const HistoryScreen({super.key, required this.riderId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DataSnapshot> _completedOrders = [];
  DataSnapshot? _activeOrder;
  // NEW: Separate totals for paid and unpaid earnings
  double _unpaidEarnings = 0.0;
  double _totalPaidEarnings = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _activeOrder = null;
        _completedOrders = [];
        _unpaidEarnings = 0.0;
        _totalPaidEarnings = 0.0;
      });
    }

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('orders')
          .orderByChild('riderId')
          .equalTo(widget.riderId)
          .get();

      if (mounted && snapshot.exists) {
        double unpaid = 0.0;
        double paid = 0.0;
        final completed = <DataSnapshot>[];
        DataSnapshot? active;

        for (final orderSnapshot in snapshot.children) {
          final data = Map<String, dynamic>.from(orderSnapshot.value as Map);
          final status = data['status'] as String?;

          if (status == 'completed') {
            completed.add(orderSnapshot);
            final double restaurantPrice = (data['price'] ?? 0.0).toDouble();
            final earning = (restaurantPrice * 15 / 25);

            // NEW: Check if the order has been paid out
            if (data['isPaidToRider'] == true) {
              paid += earning;
            } else {
              unpaid += earning;
            }
          } else if (status == 'accepted') {
            active = orderSnapshot;
          }
        }

        completed.sort((a, b) {
          final aData = Map<String, dynamic>.from(a.value as Map);
          final bData = Map<String, dynamic>.from(b.value as Map);
          return (bData['createdAt'] as int).compareTo(aData['createdAt'] as int);
        });

        setState(() {
          _completedOrders = completed;
          _activeOrder = active;
          _unpaidEarnings = unpaid;
          _totalPaidEarnings = paid;
        });
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _navigateToActiveRide() {
    if (_activeOrder == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RideNavigationScreen(orderId: _activeOrder!.key!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: Column(
        children: [
          if (_activeOrder != null)
            Card(
              color: Colors.blue.shade50,
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.delivery_dining, color: Colors.blue, size: 36),
                title: const Text('Active Ride In Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Tap here to continue your delivery'),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                onTap: _navigateToActiveRide,
              ),
            ),

          // UPDATED: Earnings card now shows unpaid amount
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Outstanding Payment (Unpaid)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.orange.shade800),
                  ),
                  Text(
                    '₹${_unpaidEarnings.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_completedOrders.isEmpty)
            const Expanded(
                child: Center(child: Text('You have no completed rides.')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _completedOrders.length,
                itemBuilder: (context, index) {
                  final orderData = Map<String, dynamic>.from(_completedOrders[index].value as Map);
                  final createdAt = DateTime.fromMillisecondsSinceEpoch(orderData['createdAt']);
                  final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
                  final double restaurantPrice = (orderData['price'] ?? 0.0).toDouble();
                  final double riderEarning = restaurantPrice * 15 / 25;
                  // NEW: Check payment status for each ride
                  final bool isPaid = orderData['isPaidToRider'] == true;

                  return ListTile(
                    leading: Icon(
                      isPaid ? Icons.check_circle : Icons.hourglass_empty,
                      color: isPaid ? Colors.green : Colors.orange,
                    ),
                    title: Text(orderData['restaurantName'] ?? 'Completed Ride'),
                    subtitle: Text('On $formattedDate'),
                    // Show earning and a "Paid" chip
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('₹${riderEarning.toStringAsFixed(2)}'),
                        const SizedBox(width: 8),
                        if (isPaid)
                          const Chip(label: Text('Paid'), backgroundColor: Colors.greenAccent, padding: EdgeInsets.all(2)),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}