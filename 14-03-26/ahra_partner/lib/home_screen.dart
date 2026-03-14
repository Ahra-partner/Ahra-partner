import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'onboarding/basic_details_screen.dart';
import 'onboarding/education_experience_screen.dart';
import 'partner/partner_dashboard_v2.dart';

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

        // ❌ No partner document → New user
        if (!snap.hasData || !snap.data!.exists) {
          return BasicDetailsScreen(partnerId: uid);
        }

        final data = snap.data!.data() as Map<String, dynamic>;

        final basicDone = data['basicCompleted'] == true;
        final educationDone = data['educationCompleted'] == true;

        // 🔹 Step 1: Basic not completed
        if (!basicDone) {
          return BasicDetailsScreen(partnerId: uid);
        }

        // 🔹 Step 2: Education not completed
        if (!educationDone) {
          return EducationExperienceScreen(
            partnerId: uid,
          );
        }

        // ✅ Fully completed partner → Dashboard
        return PartnerDashboardV2(
          partnerName: data['name'] ?? 'Partner',
        );
      },
    );
  }
}
