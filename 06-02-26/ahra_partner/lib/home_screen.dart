import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'onboarding/basic_details_screen.dart';
import 'onboarding/education_experience_screen.dart';
import 'partner/partner_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partners')
          .doc(uid)
          .snapshots(),
      builder: (context, snap) {
        // 🔄 Loading
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ No partner doc → STEP 1
        if (!snap.hasData || !snap.data!.exists) {
          return BasicDetailsScreen(partnerId: uid);
        }

        final data = snap.data!.data() as Map<String, dynamic>;

        // 🔹 STEP 1: BASIC DETAILS ONLY
        if (data['basicCompleted'] != true) {
          return BasicDetailsScreen(partnerId: uid);
        }

        // 🔹 STEP 2+: HAND OVER TO NAVIGATOR FLOW
        // 🔥 IMPORTANT: Do NOT decide Education / KYC here
        return EducationExperienceScreen(
          partnerId: uid,
        );
      },
    );
  }
}
