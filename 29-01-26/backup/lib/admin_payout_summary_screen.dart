import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPayoutSummaryScreen extends StatelessWidget {
  const AdminPayoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payout Summary'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdraw_requests')
            .where('status', isEqualTo: 'approved')
            .orderBy('approvedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          int totalPaid = 0;
          int todayPaid = 0;
          int monthPaid = 0;

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final int amount = data['amount'] ?? 0;

            final Timestamp ts = data['approvedAt'];
            final DateTime approvedDate = ts.toDate();

            totalPaid += amount;

            // Today total
            if (approvedDate.isAfter(today)) {
              todayPaid += amount;
            }

            // Month total
            if (approvedDate.month == now.month &&
                approvedDate.year == now.year) {
              monthPaid += amount;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ================= SUMMARY CARDS =================
                _summaryCard(
                  title: 'Total Paid',
                  amount: totalPaid,
                  color: Colors.green,
                  icon: Icons.account_balance_wallet,
                ),
                const SizedBox(height: 12),
                _summaryCard(
                  title: 'Paid Today',
                  amount: todayPaid,
                  color: Colors.blue,
                  icon: Icons.today,
                ),
                const SizedBox(height: 12),
                _summaryCard(
                  title: 'Paid This Month',
                  amount: monthPaid,
                  color: Colors.orange,
                  icon: Icons.calendar_month,
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 10),

                // ================= APPROVED LIST =================
                Expanded(
                  child: docs.isEmpty
                      ? const Center(
                          child: Text('No payouts approved yet'),
                        )
                      : ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data()
                                as Map<String, dynamic>;

                            final int amount = data['amount'] ?? 0;
                            final String partnerId =
                                data['partnerId'] ?? '-';

                            final Timestamp ts = data['approvedAt'];
                            final String date = DateFormat(
                              'dd MMM yyyy, hh:mm a',
                            ).format(ts.toDate());

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                title: Text(
                                  '₹ $amount',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Partner: $partnerId\n$date',
                                ),
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

  // ================= SUMMARY CARD UI =================
  Widget _summaryCard({
    required String title,
    required int amount,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹ $amount',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
