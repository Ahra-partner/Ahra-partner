import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'onboarding/basic_details_screen.dart';
import 'onboarding/education_experience_screen.dart';
import 'onboarding/kyc_upload_screen.dart';
import 'onboarding/kyc_status_screen.dart';
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

        // ❌ Partner doc not created yet → Step 1
        if (!snap.hasData || !snap.data!.exists) {
          return BasicDetailsScreen(partnerId: uid);
        }

        final data = snap.data!.data() as Map<String, dynamic>;

        // 🔹 STEP 1: BASIC DETAILS
        if (data['basicCompleted'] != true) {
          return BasicDetailsScreen(partnerId: uid);
        }

        // 🔹 STEP 2: EDUCATION
        if (data['educationCompleted'] != true) {
          return EducationExperienceScreen(partnerId: uid);
        }

        // 🔹 STEP 3: KYC UPLOAD
        if (data['kycSubmitted'] != true) {
          return KycUploadScreen(partnerId: uid);
        }

        // 🔹 STEP 4: KYC STATUS
        final String status = data['kycStatus'] ?? 'pending';

        if (status == 'pending' || status == 'rejected') {
          return KycStatusScreen(
            partnerId: uid,
            status: status,
            rejectionReason: data['rejectionReason'],
          );
        }

        // ✅ STEP 5: APPROVED → DASHBOARD
        return PartnerDashboard(
          partnerId: uid,
          partnerName: data['fullName'] ?? 'Partner',
        );
      },
    );
  }
}
