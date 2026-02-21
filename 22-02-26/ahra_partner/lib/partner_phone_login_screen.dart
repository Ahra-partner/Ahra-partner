import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PartnerPhoneLoginScreen extends StatefulWidget {
  const PartnerPhoneLoginScreen({super.key});

  @override
  State<PartnerPhoneLoginScreen> createState() =>
      _PartnerPhoneLoginScreenState();
}

class _PartnerPhoneLoginScreenState
    extends State<PartnerPhoneLoginScreen> {

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String verificationId = '';
  bool otpSent = false;

  Future<void> sendOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${phoneController.text.trim()}",
      verificationCompleted:
          (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance
            .signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "OTP Failed")),
        );
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          otpSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  Future<void> verifyOtp() async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      await FirebaseAuth.instance
          .signInWithCredential(credential);

      // ✅ AuthRouter automatically handle chestundi
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid OTP"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Partner Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            if (!otpSent)
              TextField(
                controller: phoneController,
                keyboardType:
                    TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Mobile Number",
                ),
              ),

            if (otpSent)
              TextField(
                controller: otpController,
                keyboardType:
                    TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed:
                  otpSent ? verifyOtp : sendOtp,
              child: Text(
                  otpSent ? "Verify OTP" : "Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}