import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PartnerDashboard extends StatelessWidget {
  final String partnerId;
  final String partnerName;
  final int todayEarnings;
  final int weekEarnings;
  final int walletBalance;

  const PartnerDashboard({
    super.key,
    required this.partnerId,
    required this.partnerName,
    required this.todayEarnings,
    required this.weekEarnings,
    required this.walletBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $partnerName 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _card('Today Earnings', todayEarnings),
            _card('Week Earnings', weekEarnings),
            _card('Wallet Balance', walletBalance),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, int value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          '₹ $value',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
