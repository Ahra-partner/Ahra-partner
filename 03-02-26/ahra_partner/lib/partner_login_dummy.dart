import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      // ✅ IMPORTANT
      // AuthRouter will automatically redirect after login
      // So we just POP this screen
      Navigator.pop(context);
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
