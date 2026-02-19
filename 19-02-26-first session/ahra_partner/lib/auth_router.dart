import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'admin_home_screen.dart';

// 🧩 PARTNER FLOW SCREENS
import 'onboarding/basic_details_screen.dart';
import 'onboarding/education_experience_screen.dart';
import 'onboarding/kyc_upload_screen.dart';
import 'onboarding/kyc_status_screen.dart';
import 'partner/partner_dashboard_v2.dart';

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
            if (userSnap.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnap.hasData || !userSnap.data!.exists) {
              return const LoginScreen();
            }

            final userData =
                userSnap.data!.data() as Map<String, dynamic>;
            final role = userData['role'];

            // 🧑‍💼 ADMIN FLOW
            if (role == 'admin') {
              return const AdminHomeScreen();
            }

            // 👷 PARTNER FLOW
            if (role == 'partner') {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('partners')
                    .doc(uid)
                    .get(),
                builder: (context, partnerSnap) {
                  if (partnerSnap.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                          child: CircularProgressIndicator()),
                    );
                  }

                  // 🧱 FIRST TIME PARTNER
                  if (!partnerSnap.hasData ||
                      !partnerSnap.data!.exists) {
                    return BasicDetailsScreen(partnerId: uid);
                  }

                  final data = partnerSnap.data!.data()
                      as Map<String, dynamic>;

                  final bool basicCompleted =
                      data['basicCompleted'] == true;
                  final bool educationCompleted =
                      data['educationCompleted'] == true;
                  final bool kycSubmitted =
                      data['kycSubmitted'] == true;
                  final String kycStatus =
                      data['kycStatus'] ?? 'not_started';

                  // 1️⃣ BASIC DETAILS
                  if (!basicCompleted) {
                    return BasicDetailsScreen(
                        partnerId: uid);
                  }

                  // 2️⃣ EDUCATION
                  if (!educationCompleted) {
                    return EducationExperienceScreen(
                        partnerId: uid);
                  }

                  // 3️⃣ KYC UPLOAD
                  if (!kycSubmitted) {
                    return KycUploadScreen(
                        partnerId: uid);
                  }

                  // 4️⃣ KYC STATUS
                  if (kycStatus == 'under_review' ||
                      kycStatus == 'rejected') {
                    return KycStatusScreen(
                      partnerId: uid,
                      status: kycStatus,
                      rejectionReason:
                          data['rejectionReason'],
                    );
                  }

                  // 5️⃣ ✅ KYC APPROVED → DASHBOARD
                  if (kycStatus == 'approved') {
                    return PartnerDashboardV2(
                      partnerName:
                          data['name'] ?? 'Partner',
                    );
                  }

                  // fallback
                  return KycStatusScreen(
                    partnerId: uid,
                    status: kycStatus,
                  );
                },
              );
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
