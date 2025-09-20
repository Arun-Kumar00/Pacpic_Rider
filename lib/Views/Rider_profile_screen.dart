import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RiderProfileScreen extends StatefulWidget {
  const RiderProfileScreen({super.key});

  @override
  State<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleController = TextEditingController();
  final String _riderId = FirebaseAuth.instance.currentUser!.uid;

  bool _isLoading = true;
  bool _isEditing = false; // To control view/edit mode

  @override
  void initState() {
    super.initState();
    _loadRiderData();
  }

  Future<void> _loadRiderData() async {
    final snapshot = await FirebaseDatabase.instance.ref('riders/$_riderId').get();
    if (mounted && snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _vehicleController.text = data['vehicle'] ?? '';
    }
    if (mounted) setState(() { _isLoading = false; });
  }

  Future<void> _saveProfile() async {
    setState(() { _isLoading = true; });
    try {
      await FirebaseDatabase.instance.ref('riders/$_riderId').update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'vehicle': _vehicleController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save profile: $e")),
      );
    }
    if (mounted) setState(() {
      _isLoading = false;
      _isEditing = false; // Exit edit mode after saving
    });
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  // Helper widget for building the text fields
  Widget _buildProfileField(String label, IconData icon, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing, // Only editable when in edit mode
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: _isEditing ? const UnderlineInputBorder() : InputBorder.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This screen is now a tab, so it doesn't need its own Scaffold or AppBar.
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Details Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileField('Your Name', Icons.person, _nameController),
                  const Divider(),
                  _buildProfileField('Phone Number', Icons.phone, _phoneController),
                  const Divider(),
                  _buildProfileField('Vehicle', Icons.motorcycle, _vehicleController),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Edit/Save/Cancel Buttons
          if (_isEditing)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _isEditing = false);
                      _loadRiderData(); // Revert any changes
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                    child: const Text('Save Profile', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                onPressed: () => setState(() => _isEditing = true),
              ),
            ),

          const Spacer(), // Pushes logout button to the bottom

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: _showLogoutConfirmation,
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:pacpic_rider/Views/available_rides_screen.dart';

// class RiderProfileSetupScreen extends StatefulWidget {
// const RiderProfileSetupScreen({Key? key}) : super(key: key);

// @override
// State<RiderProfileSetupScreen> createState() => _RiderProfileSetupScreenState();
// }

// class _RiderProfileSetupScreenState extends State<RiderProfileSetupScreen> {
// final _nameController = TextEditingController();
// final _vehicleController = TextEditingController();
// bool _isSaving = false;

// void _saveProfile() async {
// final name = _nameController.text.trim();
// final vehicle = _vehicleController.text.trim();

// if (name.isEmpty || vehicle.isEmpty) {
// ScaffoldMessenger.of(context).showSnackBar(
// const SnackBar(content: Text('Please fill all fields')),
// );
// return;
// }

// setState(() => _isSaving = true);

// final uid = FirebaseAuth.instance.currentUser!.uid;
// final phone = FirebaseAuth.instance.currentUser!.phoneNumber;

// await FirebaseDatabase.instance.ref('riders/$uid').set({
// 'name': name,
// 'vehicle': vehicle,
// 'phone': phone,
// 'isAvailable': true,
// });

// setState(() => _isSaving = false);

// Navigator.pushReplacement(
// context,
// MaterialPageRoute(builder: (_) => const AvailableRidesScreen()),
// );
// }

// @override
// Widget build(BuildContext context) {
// return Scaffold(
// appBar: AppBar(
// title: const Text('Complete Your Profile'),
// ),
// body: Padding(
// padding: const EdgeInsets.all(20),
// child: Column(
// children: [
// const Text(
// 'PacPic Rider Profile',
// style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// ),
// const SizedBox(height: 30),
// TextField(
// controller: _nameController,
// decoration: const InputDecoration(
// labelText: 'Full Name',
// border: OutlineInputBorder(),
// ),
// ),
// const SizedBox(height: 20),
// TextField(
// controller: _vehicleController,
// decoration: const InputDecoration(
// labelText: 'Vehicle Type (e.g. Bike, Scooter)',
// border: OutlineInputBorder(),
// ),
// ),
// const SizedBox(height: 30),
// ElevatedButton(
// onPressed: _isSaving ? null : _saveProfile,
// child: _isSaving
// ? const CircularProgressIndicator(color: Colors.white)
// : const Text('Save & Continue'),
// style: ElevatedButton.styleFrom(
// minimumSize: const Size(double.infinity, 50),
// ),
// )
// ],
// ),
// ),
// );
// }
// }