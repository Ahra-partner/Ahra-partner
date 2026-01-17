import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      home: DummyLoginScreen(),
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
          onPressed: () async {
            const partnerId = 'dummy_partner_001';

            final doc = FirebaseFirestore.instance
                .collection('partners')
                .doc(partnerId);

            final snap = await doc.get();

            if (!snap.exists) {
              await doc.set({
                'profileCompleted': false,
                'kycSubmitted': false,
                'kycStatus': 'not_started',
              });
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(partnerId: partnerId),
              ),
            );
          },
          child: const Text('Dummy Login (Day-8)'),
        ),
      ),
    );
  }
}

/* ================= PROFILE SCREEN ================= */

class ProfileScreen extends StatelessWidget {
  final String partnerId;
  ProfileScreen({super.key, required this.partnerId});

  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final skillsCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partner Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
            TextField(controller: skillsCtrl, decoration: const InputDecoration(labelText: 'Skills')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('partners')
                    .doc(partnerId)
                    .update({
                  'name': nameCtrl.text,
                  'address': addressCtrl.text,
                  'skills': skillsCtrl.text,
                  'profileCompleted': true,
                });

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KycScreen(partnerId: partnerId),
                  ),
                );
              },
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= KYC SCREEN ================= */

class KycScreen extends StatelessWidget {
  final String partnerId;
  KycScreen({super.key, required this.partnerId});

  final panCtrl = TextEditingController();
  final aadhaarCtrl = TextEditingController();
  final bankCtrl = TextEditingController();
  final ifscCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KYC Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: panCtrl, decoration: const InputDecoration(labelText: 'PAN')),
            TextField(controller: aadhaarCtrl, decoration: const InputDecoration(labelText: 'Aadhaar')),
            TextField(controller: bankCtrl, decoration: const InputDecoration(labelText: 'Bank Account')),
            TextField(controller: ifscCtrl, decoration: const InputDecoration(labelText: 'IFSC')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('partners')
                    .doc(partnerId)
                    .update({
                  'pan': panCtrl.text,
                  'aadhaar': aadhaarCtrl.text,
                  'bank': bankCtrl.text,
                  'ifsc': ifscCtrl.text,
                  'kycSubmitted': true,
                  'kycStatus': 'pending', // 🔥 MAIN FIX
                });

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(partnerId: partnerId),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Submit KYC'),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= HOME SCREEN ================= */

class HomeScreen extends StatelessWidget {
  final String partnerId;
  const HomeScreen({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AHRA Partner')),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('partners')
              .doc(partnerId)
              .snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) return const CircularProgressIndicator();

            final data = snap.data!.data() as Map<String, dynamic>;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'WELCOME PARTNER 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Status: ${data['kycStatus']}'),
              ],
            );
          },
        ),
      ),
    );
  }
}
