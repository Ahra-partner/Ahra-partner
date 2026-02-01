import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin_home_screen.dart';
import 'home_screen.dart'; // REAL partner dashboard

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snap.hasData || !snap.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        final role = data['role'];

        if (role == 'admin') {
          return const AdminHomeScreen();
        }

        if (role == 'partner') {
          return HomeScreen(
            partnerId: data['partnerId'],
          );
        }

        return const Scaffold(
          body: Center(child: Text('Access denied')),
        );
      },
    );
  }
}
