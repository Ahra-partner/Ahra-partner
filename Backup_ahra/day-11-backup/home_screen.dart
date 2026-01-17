import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'partner_dashboard.dart';
import 'kyc_pending_screen.dart';

class HomeScreen extends StatelessWidget {
  final String partnerId;

  const HomeScreen({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partners')
          .doc(partnerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final status = data['kycStatus'];
        final name = data['name'] ?? 'Partner';

        if (status == 'approved') {
          return PartnerDashboard(partnerName: name);
        } else {
          return KYCPendingScreen(status: status);
        }
      },
    );
  }
}
