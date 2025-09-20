// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// import 'package:pacpic_rider/Views/ProfileSetupscreen.dart';
// import 'package:pacpic_rider/Views/available_rides_screen.dart';
//
// class OTPScreen extends StatefulWidget {
//   final String verificationId;
//   final String phoneNumber;
//
//   const OTPScreen({
//     Key? key,
//     required this.verificationId,
//     required this.phoneNumber,
//   }) : super(key: key);
//
//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }
//
// class _OTPScreenState extends State<OTPScreen> {
//   final TextEditingController _otpController = TextEditingController();
//   bool _isVerifying = false;
//
//   void _verifyOTP() async {
//     final otp = _otpController.text.trim();
//     if (otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter a valid 6-digit OTP")),
//       );
//       return;
//     }
//
//     setState(() => _isVerifying = true);
//
//     try {
//       final credential = PhoneAuthProvider.credential(
//         verificationId: widget.verificationId,
//         smsCode: otp,
//       );
//
//       // Sign in
//       await FirebaseAuth.instance.signInWithCredential(credential);
//
//       final uid = FirebaseAuth.instance.currentUser!.uid;
//
//       // Check if rider profile exists
//       final snapshot = await FirebaseDatabase.instance.ref('riders/$uid').get();
//
//       setState(() => _isVerifying = false);
//
//       if (snapshot.exists) {
//         // Profile exists → Go to Home
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const RiderHomeScreen()),
//               (route) => false,
//         );
//       } else {
//         // No profile → Go to Setup
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const RiderProfileSetupScreen()),
//               (route) => false,
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       setState(() => _isVerifying = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("OTP Verification Failed: ${e.message}")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Verify OTP'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Enter the 6-digit OTP sent to ${widget.phoneNumber}',
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: _otpController,
//               keyboardType: TextInputType.number,
//               maxLength: 6,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'OTP',
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isVerifying ? null : _verifyOTP,
//               child: _isVerifying
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Verify OTP"),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pacpic_rider/Views/main_screen.dart';
// Assuming these are your correct import paths
import 'package:pacpic_rider/Views/ProfileSetupscreen.dart';
import 'package:pacpic_rider/Views/available_rides_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

final String? riderUid2 = FirebaseAuth.instance.currentUser?.uid;
final String riderid  = riderUid2!;
final riderUid = FirebaseAuth.instance.currentUser?.uid;
class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;

  // --- REVISED FUNCTION ---
  void _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 6-digit OTP")),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      // 1. Create the credential
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      // 2. Sign in the user
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // --- IMPORTANT CHANGE ---
      // If sign-in is successful, stop the loading indicator immediately.
      setState(() => _isVerifying = false);

      // 3. Check if we have a valid user
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;

        // 4. Now, check the database and navigate.
        // This part is now outside the core "verifying" state.
        final snapshot = await FirebaseDatabase.instance.ref('riders/$uid/name').get();

        if (snapshot.exists) {
          // Profile exists → Go to Home
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
                (route) => false,
          );
        } else {
          // No profile → Go to Setup
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const RiderProfileSetupScreen()),
                (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // If anything goes wrong with auth, stop loading and show an error.
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verification Failed: ${e.message}")),
      );
    } catch (e) {
      // Catch any other potential errors (like network issues during DB check)
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- NO CHANGES NEEDED IN THE BUILD METHOD ---
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter the 6-digit OTP sent to ${widget.phoneNumber}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'OTP',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOTP,
              child: _isVerifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify OTP"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
