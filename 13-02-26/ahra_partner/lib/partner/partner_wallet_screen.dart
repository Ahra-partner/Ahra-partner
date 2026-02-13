import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'partner_wallet_ledger_screen.dart';

class PartnerWalletScreen extends StatelessWidget {
  const PartnerWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        centerTitle: true,
      ),

      // 🔥 AUTH-AWARE WALLET
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!authSnapshot.hasData) {
            return const Center(
              child: Text('User not logged in'),
            );
          }

          final String partnerId = authSnapshot.data!.uid;

          debugPrint('🔥 AUTH READY UID (Wallet): $partnerId');

          return StreamBuilder<DocumentSnapshot>(
            // ✅ GUARANTEED FIX — FORCE REBUILD
            key: const ValueKey('partner-wallet-stream'),

            stream: FirebaseFirestore.instance
                .collection('partners')
                .doc(partnerId)
                .snapshots(),

            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text('Wallet data not found'),
                );
              }

              final data =
                  snapshot.data!.data() as Map<String, dynamic>;

              final int walletBalance =
                  data['walletBalance'] ?? 0;
              final int today =
                  data['todayEarnings'] ?? 0;
              final int week =
                  data['weekEarnings'] ?? 0;
              final int month =
                  data['monthEarnings'] ?? 0;

              return _walletUI(
                context,
                partnerId,
                walletBalance,
                today,
                week,
                month,
              );
            },
          );
        },
      ),
    );
  }

  // ================= WALLET UI =================

  Widget _walletUI(
    BuildContext context,
    String partnerId,
    int wallet,
    int today,
    int week,
    int month,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ================= WALLET BALANCE =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹ $wallet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: wallet == 0
                      ? null
                      : () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Withdraw coming soon',
                              ),
                            ),
                          );
                        },
                  child: const Text('Withdraw'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= FILTER TABS =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _Tab(text: 'Daily'),
              _Tab(text: 'Weekly'),
              _Tab(text: 'Monthly'),
            ],
          ),

          const SizedBox(height: 16),

          // ================= EARNINGS =================
          _earningCard(
            title: "Today's Earnings",
            amount: today,
          ),
          _earningCard(
            title: "This Week's Earnings",
            amount: week,
          ),
          _earningCard(
            title: "This Month's Earnings",
            amount: month,
          ),

          const SizedBox(height: 24),

          // ================= LEDGER =================
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('View Wallet Ledger'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PartnerWalletLedgerScreen(
                      partnerId: partnerId,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _earningCard({
    required String title,
    required int amount,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.currency_rupee),
        title: Text(title),
        trailing: Text(
          '₹ $amount',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String text;

  const _Tab({required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(text));
  }
}
