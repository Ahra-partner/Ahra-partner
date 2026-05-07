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

  // 🔥 Resend Token
  int? resendToken;

  // 🔥 Cooldown Timer
  int resendSeconds = 0;
  Timer? timer;

  void startTimer() {

    resendSeconds = 60;

    timer?.cancel();

    timer = Timer.periodic(

      const Duration(seconds: 1),

      (timer) {

        if (resendSeconds == 0) {

          timer.cancel();

        } else {

          setState(() {
            resendSeconds--;
          });
        }
      },
    );
  }

  // 🔥 SEND OTP
  Future<void> sendOtp() async {

    print("SEND OTP CLICKED");

    if (phoneController.text.length != 10) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Enter valid mobile number"),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Sending OTP..."),
      ),
    );

    await FirebaseAuth.instance.verifyPhoneNumber(

      phoneNumber:
          "+91${phoneController.text.trim()}",

      // 🔥 TEMP AUTO VERIFY DISABLED
      verificationCompleted:
          (PhoneAuthCredential credential) async {
      },

      verificationFailed:
          (FirebaseAuthException e) {

        print(e.code);
        print(e.message);

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            content:
                Text(e.message ?? "OTP Failed"),
          ),
        );
      },

      codeSent:
          (String verId, int? token) {

        print("OTP SENT SUCCESS");

        // 🔥 START TIMER ONLY AFTER OTP SENT
        startTimer();

        setState(() {

          verificationId = verId;
          resendToken = token;
          otpSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(
            content: Text("OTP Sent"),
          ),
        );
      },

      codeAutoRetrievalTimeout:
          (String verId) {

        verificationId = verId;
      },
    );
  }

  // 🔥 RESEND OTP
  Future<void> resendOtp() async {

    await FirebaseAuth.instance.verifyPhoneNumber(

      phoneNumber:
          "+91${phoneController.text.trim()}",

      forceResendingToken: resendToken,

      // 🔥 TEMP AUTO VERIFY DISABLED
      verificationCompleted:
          (PhoneAuthCredential credential) async {
      },

      verificationFailed:
          (FirebaseAuthException e) {

        print(e.code);
        print(e.message);

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            content:
                Text(e.message ?? "Resend Failed"),
          ),
        );
      },

      codeSent:
          (String verId, int? token) {

        print("OTP RESENT SUCCESS");

        // 🔥 START TIMER ONLY AFTER OTP RESENT
        startTimer();

        setState(() {

          verificationId = verId;
          resendToken = token;
        });

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(
            content: Text("OTP Resent"),
          ),
        );
      },

      codeAutoRetrievalTimeout:
          (String verId) {

        verificationId = verId;
      },
    );
  }

  // 🔥 VERIFY OTP
  Future<void> verifyOtp() async {

    try {

      final credential =
          PhoneAuthProvider.credential(

        verificationId: verificationId,

        smsCode:
            otpController.text.trim(),
      );

      await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(

        MaterialPageRoute(
          builder: (_) =>
              const AuthRouter(),
        ),

        (route) => false,
      );

    } catch (e) {

      print(e);

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

      appBar: AppBar(
        title: const Text("Partner Login"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            // 🔥 MOBILE FIELD
            if (!otpSent)
              TextField(

                controller: phoneController,

                keyboardType:
                    TextInputType.phone,

                decoration:
                    const InputDecoration(
                  labelText: "Mobile Number",
                ),
              ),

            // 🔥 OTP FIELD
            if (otpSent)
              TextField(

                controller: otpController,

                keyboardType:
                    TextInputType.number,

                autofillHints: const [
                  AutofillHints.oneTimeCode,
                ],

                decoration:
                    const InputDecoration(
                  labelText: "Enter OTP",
                ),
              ),

            const SizedBox(height: 20),

            // 🔥 SEND OTP BUTTON
            if (!otpSent)
              ElevatedButton(

                onPressed:
                    resendSeconds == 0
                        ? sendOtp
                        : null,

                child: resendSeconds == 0
                    ? const Text("Send OTP")
                    : Text(
                        "Send Again in $resendSeconds sec",
                      ),
              ),

            // 🔥 VERIFY OTP BUTTON
            if (otpSent)
              ElevatedButton(

                onPressed: verifyOtp,

                child:
                    const Text("Verify OTP"),
              ),

            // 🔥 RESEND OTP BUTTON
            if (otpSent)
              Column(

                children: [

                  const SizedBox(height: 10),

                  TextButton(

                    onPressed:
                        resendSeconds == 0
                            ? resendOtp
                            : null,

                    child: Text(

                      resendSeconds == 0
                          ? "Resend OTP"
                          : "Resend in $resendSeconds sec",
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}