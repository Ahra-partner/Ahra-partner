import 'package:flutter/material.dart';

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
    // ⏳ UNDER REVIEW / PENDING
    if (status == 'pending' || status == 'review') {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                '⏳ Your KYC is under review',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Please wait for admin approval',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // ❌ REJECTED
    if (status == 'rejected') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '❌ KYC Rejected',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (rejectionReason != null && rejectionReason!.isNotEmpty)
                Text(
                  'Reason: $rejectionReason',
                  textAlign: TextAlign.center,
                ),
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
          ),
        ),
      );
    }

    // ✅ APPROVED
    if (status == 'approved') {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                '✅ KYC Approved',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Dashboard will be activated shortly',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // ❓ INVALID STATE
    return const Scaffold(
      body: Center(
        child: Text('Invalid KYC status'),
      ),
    );
  }
}
