import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../language_screen.dart';

class PartnerLoginDummyScreen extends StatelessWidget {
  const PartnerLoginDummyScreen({super.key});

  Future<void> _loginDummyPartner(BuildContext context) async {
    try {
      // 🔑 DUMMY PARTNER CREDENTIALS
      const email = 'svreddy8389@gmail.com';
      const password = '838956';

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ VERY IMPORTANT FLOW
      // Dummy login → compulsory language selection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LanguageScreen(
            fromSettings: false, // 👈 compulsory first-time language
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Login failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dummy Partner Login'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _loginDummyPartner(context),
          child: const Text('Login as Dummy Partner'),
        ),
      ),
    );
  }
}
