import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'app_strings.dart';
import 'language_screen.dart';

class PartnerDashboard extends StatelessWidget {
  final String partnerId;
  final String partnerName;

  const PartnerDashboard({
    super.key,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final s = AppStrings(lang);

    // 🔥 TEMP STATIC VALUES (Firebase verified)
    const int todayEarnings = 400;
    const int weekEarnings = 400;
    const int walletBalance = 700;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(s.get('dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LanguageScreen(fromSettings: true),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${s.get('welcome')}, $partnerName 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _card(s.get('today_earnings'), todayEarnings),
            _card(s.get('week_earnings'), weekEarnings),
            _card(s.get('wallet_balance'), walletBalance),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, int value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.currency_rupee),
        title: Text(title),
        trailing: Text(
          '₹ $value',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
