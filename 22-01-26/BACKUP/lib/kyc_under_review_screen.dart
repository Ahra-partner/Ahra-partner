import 'package:flutter/material.dart';

class KycUnderReviewScreen extends StatelessWidget {
  const KycUnderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Under Review'),
        centerTitle: true,
        automaticallyImplyLeading: false, // ⛔ back button ledu
      ),
      body: Center(
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
                'Your KYC is under review',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Our team is verifying your documents.\n'
                'This usually takes 24–48 hours.\n\n'
                'You will be notified once approved.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
