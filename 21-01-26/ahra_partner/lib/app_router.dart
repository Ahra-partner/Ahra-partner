import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_home_screen.dart';
import 'home_screen.dart';
import 'basic_details_screen.dart';
import 'education_experience_screen.dart';

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

        final role = data['role']; // admin / partner
        final currentStep = data['currentStep'] ?? 1;
        final onboardingCompleted =
            data['onboardingCompleted'] ?? false;

        // 🔐 ADMIN FLOW
        if (role == 'admin') {
          return const AdminHomeScreen();
        }

        // 👤 PARTNER ONBOARDING FLOW

        // 🟢 STEP-1: Basic Details
        if (currentStep == 1) {
          return BasicDetailsScreen(
            partnerId: userId,
          );
        }

        // 🟢 STEP-2: Education & Experience
        if (currentStep == 2) {
          return EducationExperienceScreen(
            partnerId: userId,
          );
        }

        // 🟢 ONBOARDING COMPLETED → NORMAL PARTNER FLOW
        if (onboardingCompleted == true) {
          return HomeScreen(
            partnerId: userId,
          );
        }

        // 🛡️ SAFETY FALLBACK
        return HomeScreen(
          partnerId: userId,
        );
      },
    );
  }
}
