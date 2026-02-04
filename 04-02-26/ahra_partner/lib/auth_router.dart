import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'admin_home_screen.dart';
import 'home_screen.dart';

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
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

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data =
                userSnap.data!.data() as Map<String, dynamic>;
            final role = data['role'];

            // 🧑‍💼 ADMIN
            if (role == 'admin') {
              return const AdminHomeScreen();
            }

            // 👷 PARTNER
            if (role == 'partner') {
              // ❌ DO NOT pass partnerId here
              return const HomeScreen();
            }

            return const Scaffold(
              body: Center(child: Text('Access denied')),
            );
          },
        );
      },
    );
  }
}
