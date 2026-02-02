import 'package:flutter/material.dart';
import 'partner/partner_dashboard.dart';

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
                  partnerId: 'dummy_partner_001',
                  partnerName: 'Dummy Partner',
                ),
              ),
            );
          },
          child: const Text('Login as Dummy Partner'),
        ),
      ),
    );
  }
}
