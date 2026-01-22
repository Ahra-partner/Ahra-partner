import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_home_screen.dart';
import 'home_screen.dart';
import 'update_kyc_screen.dart';
import 'kyc_under_review_screen.dart';

class AppRouter extends StatelessWidget {
  final String userId;

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
        final role = data['role'];
        final kycStatus = data['kycStatus'];

        // 🔐 ADMIN
        if (role == 'admin') {
          return const AdminHomeScreen();
        }

        // 👤 PARTNER FLOW
        if (kycStatus == 'pending') {
          return KycUnderReviewScreen(); // ✅ FIXED
        }

        if (kycStatus == 'rejected') {
          return UpdateKycScreen(partnerId: userId);
        }

        if (kycStatus == 'approved') {
          return HomeScreen(partnerId: userId);
        }

        // Default (first time / no KYC yet)
        return UpdateKycScreen(partnerId: userId);
      },
    );
  }
}
