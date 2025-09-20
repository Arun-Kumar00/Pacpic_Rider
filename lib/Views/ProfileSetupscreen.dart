import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pacpic_rider/views/main_screen.dart'; // Import your main screen

class RiderProfileSetupScreen extends StatefulWidget {
  const RiderProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<RiderProfileSetupScreen> createState() => _RiderProfileSetupScreenState();
}

class _RiderProfileSetupScreenState extends State<RiderProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // For better validation
  bool _isSaving = false;

  Future<void> _saveProfile() async {
    // Use the form key to validate
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final phone = user.phoneNumber;

      await FirebaseDatabase.instance.ref('riders/${user.uid}').set({
        'name': _nameController.text.trim(),
        'vehicle': _vehicleController.text.trim(),
        'phone': phone,
        'isAvailable': true,
        'createdAt': ServerValue.timestamp,
      });

      if (mounted) {
        // Navigate to the MainScreen and remove all previous screens
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create profile: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false, // Prevents user from going back
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form( // Wrap in a Form widget
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome! Please complete your profile to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              TextFormField( // Use TextFormField for validation
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField( // Use TextFormField for validation
                controller: _vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle No.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your vehicle No.' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isSaving
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Save & Continue'),
              )
            ],
          ),
        ),
      ),
    );
  }
}