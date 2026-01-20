import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AhraPartnerApp());
}

/* ================= APP ROOT ================= */

class AhraPartnerApp extends StatelessWidget {
  const AhraPartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DummyLoginScreen(), // ✅ Dummy Login first
    );
  }
}

/* ================= DUMMY LOGIN ================= */

class DummyLoginScreen extends StatelessWidget {
  const DummyLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // ✅ IMPORTANT: partnerId pass cheyyadam
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(
                  partnerId: 'dummy_partner_001',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Dummy Login (Day-9)',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
