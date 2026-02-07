import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../app_strings.dart';
import '../language_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('dashboard')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) =>
                    const LanguageScreen(fromSettings: true),
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

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .doc(partnerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text('Partner data not found'));
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          final today = data['todayEarnings'] ?? 0;
          final week = data['weekEarnings'] ?? 0;
          final month = data['monthEarnings'] ?? 0;
          final wallet = data['walletBalance'] ?? 0;

          return Padding(
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

                _card(s.get('today_earnings'), today),
                _card(s.get('week_earnings'), week),
                _card(s.get('month_earnings'), month),
                _card(s.get('wallet_balance'), wallet),
              ],
            ),
          );
        },
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
