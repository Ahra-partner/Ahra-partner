import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'admin_home_screen.dart';
import 'home_screen.dart'; // ✅ REAL PARTNER DASHBOARD

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        // ⏳ Firebase auth loading
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Not logged in → Login screen
        if (!authSnap.hasData) {
          return const LoginScreen();
        }

        final uid = authSnap.data!.uid;

        // 🔍 Fetch role from Firestore
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnap.hasData || !userSnap.data!.exists) {
              return const LoginScreen();
            }

            final data =
                userSnap.data!.data() as Map<String, dynamic>?;

            if (data == null || !data.containsKey('role')) {
              return const LoginScreen();
            }

            final role = data['role'];

            // 🧑‍💼 ADMIN
            if (role == 'admin') {
              return const AdminHomeScreen();
            }

            // 👷 PARTNER → REAL AHRA DASHBOARD
            if (role == 'partner') {
              return HomeScreen(
                partnerId: data['partnerId'],
              );
            }

            // 🚫 Unknown role
            return const Scaffold(
              body: Center(child: Text('Access denied')),
            );
          },
        );
      },
    );
  }
}
