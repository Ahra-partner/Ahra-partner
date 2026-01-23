import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_home_screen.dart';
import 'home_screen.dart';
import 'update_kyc_screen.dart';
import 'kyc_under_review_screen.dart';
import 'kyc_rejected_screen.dart';

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
        final kycStatus = data['kycStatus'] ?? 'not_started';
        final rejectionReason = data['rejectionReason'] ?? '';

        // 🔐 ADMIN FLOW
        if (role == 'admin') {
          return const AdminHomeScreen();
        }

        // 👤 PARTNER FLOW
        if (kycStatus == 'pending') {
          return const KycUnderReviewScreen();
        }

        if (kycStatus == 'rejected') {
          return RejectedKycScreen(
            partnerId: userId,
            reason: rejectionReason,
          );
        }

        if (kycStatus == 'approved') {
          return HomeScreen(partnerId: userId);
        }

        // not_started / first time
        return UpdateKycScreen(partnerId: userId);
      },
    );
  }
}
