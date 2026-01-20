import 'package:flutter/material.dart';

import 'language_helper.dart';
import 'app_strings.dart';

class PendingKycScreen extends StatelessWidget {
  const PendingKycScreen({super.key});

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
                    Icons.hourglass_top,
                    size: 60,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    s.get('kyc_pending'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    s.get('kyc_pending_desc'),
                    textAlign: TextAlign.center,
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
