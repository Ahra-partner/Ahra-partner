import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  /// 🔹 Sum helper
  int _sumField(
    QuerySnapshot snap,
    String field,
  ) {
    return snap.docs.fold<int>(
      0,
      (sum, d) => sum + ((d[field] ?? 0) as int),
    );
  }

  @override
  Widget build(BuildContext context) {
    final partnersRef =
        FirebaseFirestore.instance.collection('partners');

    final withdrawRef = FirebaseFirestore.instance
        .collection('withdraw_requests')
        .where('status', isEqualTo: 'pending');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Analytics'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 PARTNERS AGGREGATES
            StreamBuilder<QuerySnapshot>(
              stream: partnersRef.snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snap.data!;
                final today =
                    _sumField(docs, 'todayEarnings');
                final week =
                    _sumField(docs, 'weekEarnings');
                final month =
                    _sumField(docs, 'monthEarnings');
                final partnersCount = docs.docs.length;

                return Column(
                  children: [
                    _metricCard(
                      'Today Earnings',
                      '₹ $today',
                      Icons.today,
                      Colors.green,
                    ),
                    _metricCard(
                      'This Week',
                      '₹ $week',
                      Icons.calendar_view_week,
                      Colors.blue,
                    ),
                    _metricCard(
                      'This Month',
                      '₹ $month',
                      Icons.calendar_month,
                      Colors.orange,
                    ),
                    _metricCard(
                      'Total Partners',
                      partnersCount.toString(),
                      Icons.people,
                      Colors.purple,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            /// 💸 PENDING WITHDRAWS
            StreamBuilder<QuerySnapshot>(
              stream: withdrawRef.snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) return const SizedBox();

                final totalPending = snap.data!.docs.fold<int>(
                  0,
                  (s, d) => s + ((d['amount'] ?? 0) as int),
                );

                return _metricCard(
                  'Pending Withdrawals',
                  '₹ $totalPending',
                  Icons.account_balance_wallet,
                  Colors.red,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Reusable card
  Widget _metricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
