import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'app_strings.dart';
import 'language_screen.dart';
import 'update_kyc_screen.dart';

class RejectedKycScreen extends StatelessWidget {
  final String reason;

  const RejectedKycScreen({
    super.key,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final s = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('kyc_rejected')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LanguageScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cancel,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),

            Text(
              s.get('kyc_rejected'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              reason.isNotEmpty
                  ? reason
                  : s.get('kyc_rejected_desc'),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // ✅ UPDATE KYC BUTTON (FIXED)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UpdateKycScreen(
                      partnerId: 'dummy_partner_001',
                    ),
                  ),
                );
              },
              child: Text(s.get('update_kyc')),
            ),
          ],
        ),
      ),
    );
  }
}
