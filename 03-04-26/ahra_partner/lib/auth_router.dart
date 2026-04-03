import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'admin_home_screen.dart';

// 🧩 PARTNER FLOW SCREENS
import 'language_screen.dart';
import 'onboarding/basic_details_screen.dart';
import 'onboarding/education_experience_screen.dart';
import 'onboarding/kyc_upload_screen.dart';
import 'onboarding/kyc_status_screen.dart';
import 'partner/partner_dashboard_v2.dart';

// 🔥 ADD THIS (VERY IMPORTANT)
const bool isPartnerApp = bool.fromEnvironment('PARTNER_APP');

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  // 🔥 EMPLOYEE ID GENERATOR
  Future<String> _generateEmployeeId() async {

    final year = DateTime.now().year;

    final counterRef = FirebaseFirestore.instance
        .collection('counters')
        .doc('partnerCounter_$year');

    return FirebaseFirestore.instance
        .runTransaction((transaction) async {

      final snapshot = await transaction.get(counterRef);

      int currentNumber = 0;

      if (!snapshot.exists) {
        transaction.set(counterRef, {'currentNumber': 1});
        currentNumber = 1;
      } else {
        currentNumber = snapshot['currentNumber'] ?? 0;
        currentNumber++;
        transaction.update(counterRef, {
          'currentNumber': currentNumber
        });
      }

      final formatted =
          currentNumber.toString().padLeft(4, '0');

      return "AHRA-$year-$formatted";
    });
  }

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

        if (!authSnap.hasData) {
          return const LoginScreen();
        }

        final uid = authSnap.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('admins')
              .doc(uid)
              .get(),
          builder: (context, adminSnap) {

            if (adminSnap.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // 🧑‍💼 ADMIN FLOW (🔥 FIX HERE)
            if (!isPartnerApp &&
                adminSnap.hasData &&
                adminSnap.data!.exists) {

              final adminData =
                  adminSnap.data!.data() as Map<String, dynamic>;

              final String role =
                  adminData['role'] ?? 'sub_admin';

              final Map<String, dynamic> permissions =
                  adminData['permissions'] ?? {};

              return AdminHomeScreen(
                role: role,
                permissions: permissions,
              );
            }

            // 👷 PARTNER FLOW
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('partners')
                  .doc(uid)
                  .snapshots(),
              builder: (context, partnerSnap) {

                if (partnerSnap.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                        child: CircularProgressIndicator()),
                  );
                }

                // 🔥 NEW PARTNER DOCUMENT CREATE
                if (!partnerSnap.hasData ||
                    !partnerSnap.data!.exists) {

                  _generateEmployeeId().then((empId) async {

                    await FirebaseFirestore.instance
                        .collection('partners')
                        .doc(uid)
                        .set({
                      "empId": empId,
                      "designation": "Relationship Manager",
                      "languageSelected": false,
                      "basicCompleted": false,
                      "educationCompleted": false,
                      "kycSubmitted": false,
                      "kycStatus": "not_started",
                      "createdAt":
                          FieldValue.serverTimestamp(),
                    });
                  });

                  return const LanguageScreen();
                }

                final data =
                    partnerSnap.data!.data()
                        as Map<String, dynamic>;

                final bool languageSelected =
                    data['languageSelected'] == true;

                final bool basicCompleted =
                    data['basicCompleted'] == true;

                final bool educationCompleted =
                    data['educationCompleted'] == true;

                final bool kycSubmitted =
                    data['kycSubmitted'] == true;

                final String kycStatus =
                    data['kycStatus'] ?? 'not_started';

                // 🌍 LANGUAGE FIRST
                if (!languageSelected) {
                  return const LanguageScreen();
                }

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

                // 🔥 APPROVED FIRST
                if (kycStatus == 'approved') {
                  return PartnerDashboardV2(
                    partnerName:
                        data['name'] ?? 'Partner',
                  );
                }

                // UNDER REVIEW / REJECTED
                if (kycStatus == 'under_review' ||
                    kycStatus == 'rejected') {
                  return KycStatusScreen(
                    partnerId: uid,
                  );
                }

                // KYC UPLOAD
                if (!kycSubmitted) {
                  return KycUploadScreen(
                      partnerId: uid);
                }

                return KycStatusScreen(
                  partnerId: uid,
                );
              },
            );
          },
        );
      },
    );
  }
}