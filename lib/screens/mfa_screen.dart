import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class MFAScreen extends StatefulWidget {
  const MFAScreen({super.key});

  @override
  State<MFAScreen> createState() => _MFAScreenState();
}

class _MFAScreenState extends State<MFAScreen> {
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  String _verificationId = "";

  Future<void> _sendCode() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      },
      verificationFailed: (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
      },
      codeSent: (verificationId, _) {
        setState(() => _verificationId = verificationId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Code sent! Check SMS.")));
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> _verifyCode() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _smsCodeController.text.trim(),
    );

    await FirebaseAuth.instance.currentUser?.multiFactor.enroll(
      PhoneMultiFactorGenerator.getAssertion(credential),
      displayName: "phone",
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            ElevatedButton(
              onPressed: _sendCode,
              child: const Text("Send Code"),
            ),
            TextField(
              controller: _smsCodeController,
              decoration: const InputDecoration(labelText: "Enter SMS Code"),
            ),
            ElevatedButton(onPressed: _verifyCode, child: const Text("Verify")),
          ],
        ),
      ),
    );
  }
}
