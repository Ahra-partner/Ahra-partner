import 'package:flutter/material.dart';

import 'language_helper.dart';
import 'app_strings.dart';

class RejectedKycScreen extends StatelessWidget {
  final String reason;

  const RejectedKycScreen({
    super.key,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppStrings>(
      future: loadStrings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final s = snapshot.data!;

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cancel,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    s.get('kyc_rejected'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    reason.isNotEmpty
                        ? reason
                        : s.get('kyc_rejected_desc'),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // back to KYC update
                    },
                    child: Text(s.get('update_kyc')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
