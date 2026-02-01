import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_analytics.dart';      // 📊 Analytics screen
import 'admin_earnings_chart.dart'; // 📈 Earnings chart screen

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          int totalToday = 0;
          int totalWeek = 0;
          int totalMonth = 0;
          int totalWallet = 0;

          for (final d in snapshot.data!.docs) {
            final data = d.data() as Map<String, dynamic>;
            totalToday += (data['todayEarnings'] ?? 0) as int;
            totalWeek += (data['weekEarnings'] ?? 0) as int;
            totalMonth += (data['monthEarnings'] ?? 0) as int;
            totalWallet += (data['walletBalance'] ?? 0) as int;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔢 SUMMARY CARDS
                _card('Today Earnings', totalToday),
                _card('Week Earnings', totalWeek),
                _card('Month Earnings', totalMonth),
                _card('Total Wallet Balance', totalWallet),

                const SizedBox(height: 16),

                // 📊 ANALYTICS SCREEN
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text('Analytics'),
                    subtitle:
                        const Text('Business overview & totals'),
                    trailing:
                        const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AdminAnalyticsScreen(),
                        ),
                      );
                    },
                  ),
                ),

                // 📈 EARNINGS CHART SCREEN (NEW)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.show_chart),
                    title: const Text('Earnings Chart'),
                    subtitle:
                        const Text('Last 7 days trend'),
                    trailing:
                        const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AdminEarningsChart(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🔹 Reusable summary card
  Widget _card(String title, int amount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          '₹ $amount',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
