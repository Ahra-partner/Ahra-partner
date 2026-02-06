import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../partner/partner_dashboard.dart';
import 'kyc_upload_screen.dart';

class KycStatusScreen extends StatelessWidget {
  final String partnerId;
  final String status;
  final String? rejectionReason;

  const KycStatusScreen({
    super.key,
    required this.partnerId,
    required this.status,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Status'),
        centerTitle: true,
        automaticallyImplyLeading: false, // ⛔ No back for pending
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => const LanguageScreen(
                  fromSettings: true,
                ),
              );
            },
          ),
        ],
      ),

      body: Center(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // ⏳ UNDER REVIEW
    if (status == 'under_review') {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Your KYC is under review',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
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
          const Icon(Icons.cancel, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'KYC Rejected',
            style: TextStyle(fontSize: 18),
          ),
          if (rejectionReason != null) ...[
            const SizedBox(height: 8),
            Text('Reason: $rejectionReason'),
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
            child: const Text('Re-upload KYC'),
          ),
        ],
      );
    }

    // ✅ APPROVED
    if (status == 'approved') {
      return PartnerDashboard(
        partnerId: partnerId,
        partnerName: 'Partner',
      );
    }

    return const Text('Invalid KYC status');
  }
}
