import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_router.dart';

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

  // 🔥 Cooldown Timer
  int resendSeconds = 0;
  Timer? timer;

  void startTimer() {
    resendSeconds = 60;

    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          resendSeconds--;
        });
      }
    });
  }

  Future<void> sendOtp() async {

    if (phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid mobile number")),
      );
      return;
    }

    startTimer();

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

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AuthRouter(),
        ),
        (route) => false,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid OTP"),
        ),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Partner Login")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            if (!otpSent)
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Mobile Number",
                ),
              ),

            if (otpSent)
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                ),
              ),

            const SizedBox(height: 20),

            // 🔥 SEND OTP BUTTON
            if (!otpSent)
              ElevatedButton(
                onPressed:
                    resendSeconds == 0 ? sendOtp : null,
                child: resendSeconds == 0
                    ? const Text("Send OTP")
                    : Text(
                        "Resend OTP in $resendSeconds sec",
                      ),
              ),

            // 🔥 VERIFY OTP BUTTON
            if (otpSent)
              ElevatedButton(
                onPressed: verifyOtp,
                child: const Text("Verify OTP"),
              ),
          ],
        ),
      ),
    );
  }
}