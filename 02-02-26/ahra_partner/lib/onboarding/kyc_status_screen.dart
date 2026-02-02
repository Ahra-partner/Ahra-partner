import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'partner/partner_dashboard.dart';
import 'partner_kyc_upload_screen.dart';

class PartnerKycStatusScreen extends StatelessWidget {
  final String partnerId;

  const PartnerKycStatusScreen({
    super.key,
    required this.partnerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Status'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .doc(partnerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(
              child: Text('Partner data not found'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['kycStatus'] ?? 'pending';
          final name = data['name'] ?? 'Partner';

          // ================= APPROVED =================
          if (status == 'approved') {
            return PartnerDashboard(
              partnerId: partnerId,
              partnerName: name,
            );
          }

          // ================= REJECTED =================
          if (status == 'rejected') {
            return _RejectedView(
              reason: data['rejectionReason'] ?? 'KYC rejected',
              onReupload: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PartnerKycUploadScreen(partnerId: partnerId),
                  ),
                );
              },
            );
          }

          // ================= PENDING (DEFAULT) =================
          return const _PendingView();
        },
      ),
    );
  }
}

/// =======================
/// 🔵 PENDING VIEW
/// =======================
class _PendingView extends StatelessWidget {
  const _PendingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.hourglass_top,
              size: 80,
              color: Colors.orange,
            ),
            SizedBox(height: 20),
            Text(
              'KYC Under Review',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Your documents are being reviewed by admin.\nPlease wait for approval.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================
/// 🔴 REJECTED VIEW
/// =======================
class _RejectedView extends StatelessWidget {
  final String reason;
  final VoidCallback onReupload;

  const _RejectedView({
    required this.reason,
    required this.onReupload,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cancel,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'KYC Rejected',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Re-upload KYC'),
              onPressed: onReupload,
            ),
          ],
        ),
      ),
    );
  }
}
