import 'package:flutter/material.dart';

class KYCPendingScreen extends StatelessWidget {
  final String status;

  const KYCPendingScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final message = status == 'rejected'
        ? 'Your KYC was rejected ❌\nPlease update and resubmit'
        : 'Your KYC is under review ⏳';

    return Scaffold(
      appBar: AppBar(title: const Text('KYC Status')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              if (status == 'rejected')
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Update KYC')),
                    );
                  },
                  child: const Text('Update KYC'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
