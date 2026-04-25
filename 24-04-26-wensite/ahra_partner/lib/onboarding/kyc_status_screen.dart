import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';
import '../partner/partner_dashboard_v2.dart';
import 'kyc_upload_screen.dart';

class KycStatusScreen extends StatelessWidget {
  final String partnerId;

  const KycStatusScreen({
    super.key,
    required this.partnerId,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final s = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('kyc_status')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) =>
                    const LanguageScreen(fromSettings: true),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      /// 🔥 REALTIME LISTENER
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .doc(partnerId)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          final String status =
              data['kycStatus'] ?? 'under_review';

          final String? rejectionReason =
              data['rejectionReason'];

          /// 🔥 APPROVED → Navigate & Clear Stack
          if (status == 'approved') {

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => PartnerDashboardV2(
                    partnerName:
                        data['name'] ?? 'Partner',
                  ),
                ),
                (route) => false,
              );
            });

            return const SizedBox();
          }

          return Center(
            child: _buildContent(
              context,
              s,
              status,
              rejectionReason,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppStrings s,
    String status,
    String? rejectionReason,
  ) {

    // ⏳ UNDER REVIEW
    if (status == 'under_review') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_top,
              size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            s.get('kyc_under_review'),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait for admin approval',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    // ❌ REJECTED
    if (status == 'rejected') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cancel,
              size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            s.get('kyc_rejected'),
            style: const TextStyle(fontSize: 18),
          ),
          if (rejectionReason != null) ...[
            const SizedBox(height: 8),
            Text('${s.get('reason')}: $rejectionReason'),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      KycUploadScreen(partnerId: partnerId),
                ),
              );
            },
            child: Text(s.get('reupload_kyc')),
          ),
        ],
      );
    }

    return Text(s.get('invalid_status'));
  }
}