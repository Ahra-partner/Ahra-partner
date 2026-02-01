import 'package:flutter/material.dart';
import 'partner_dashboard.dart';

class PartnerLoginDummyScreen extends StatelessWidget {
  const PartnerLoginDummyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dummy Partner Login'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const PartnerDashboard(
                  partnerName: 'Dummy Partner',
                  partnerId: 'dummy_partner_001',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 14,
            ),
            backgroundColor: Colors.green,
          ),
          child: const Text(
            'Login as Dummy Partner',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
