import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'admin_home_screen.dart';

// ✅ ONLY ENTRY SCREEN FOR PARTNER
import 'onboarding/basic_details_screen.dart';

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        // 🔄 Auth loading
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Not logged in
        if (!authSnap.hasData) {
          return const LoginScreen();
        }

        final uid = authSnap.data!.uid;

        // 🔍 CHECK ROLE
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data =
                userSnap.data!.data() as Map<String, dynamic>?;

            if (data == null) {
              return const LoginScreen();
            }

            final role = data['role'];

            // 🧑‍💼 ADMIN FLOW
            if (role == 'admin') {
              return const AdminHomeScreen();
            }

            // 👷 PARTNER FLOW
            if (role == 'partner') {
              // ✅ ALWAYS START FROM BASIC DETAILS
              return BasicDetailsScreen(partnerId: uid);
            }

            // ❌ UNKNOWN ROLE
            return const Scaffold(
              body: Center(child: Text('Access denied')),
            );
          },
        );
      },
    );
  }
}
