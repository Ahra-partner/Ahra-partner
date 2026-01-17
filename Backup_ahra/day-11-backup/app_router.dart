import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_home_screen.dart';
import 'home_screen.dart';

class AppRouter extends StatelessWidget {
  final String userId; // dummy_partner_001 / admin_001

  const AppRouter({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partners')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = data['role'];

        // 🔐 ADMIN
        if (role == 'admin') {
          return const AdminHomeScreen();
        }

        // 👤 PARTNER
        return HomeScreen(
          partnerId: userId,
        );
      },
    );
  }
}
