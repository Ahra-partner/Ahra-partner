import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';
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
    // 🌐 LANGUAGE SUPPORT
    final lang = context.watch<LanguageProvider>().lang;
    final s = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('kyc_status') ?? 'KYC Status'),
        centerTitle: true,

        // ⬅️ BACK BUTTON (SAFE)
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,

        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) =>
                    const LanguageScreen(fromSettings: true),
              );
            },
          ),
        ],
      ),

      body: Center(
        child: _buildContent(context, s),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppStrings s) {
    // ⏳ UNDER REVIEW
    if (status == 'under_review') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_top,
              size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            s.get('kyc_under_review') ??
                'Your KYC is under review',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            s.get('kyc_wait_admin') ??
                'Please wait for admin approval',
            style: const TextStyle(color: Colors.grey),
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
            s.get('kyc_rejected') ?? 'KYC Rejected',
            style: const TextStyle(fontSize: 18),
          ),
          if (rejectionReason != null) ...[
            const SizedBox(height: 8),
            Text(
              '${s.get('reason') ?? 'Reason'}: $rejectionReason',
            ),
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
            child: Text(
              s.get('reupload_kyc') ?? 'Re-upload KYC',
            ),
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

    return Text(
      s.get('invalid_status') ?? 'Invalid KYC status',
    );
  }
}
