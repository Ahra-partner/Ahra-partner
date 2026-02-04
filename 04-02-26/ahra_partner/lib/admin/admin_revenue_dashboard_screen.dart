import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminRevenueDashboardScreen extends StatelessWidget {
  const AdminRevenueDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AHRA Revenue Dashboard'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wallet_ledger')
            .where('type', isEqualTo: 'customer_payment')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          int totalRevenue = 0;
          int todayRevenue = 0;
          int monthRevenue = 0;

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final int companyShare = data['companyShare'] ?? 0;

            final Timestamp ts = data['createdAt'];
            final DateTime date = ts.toDate();

            totalRevenue += companyShare;

            // Today
            if (date.isAfter(today)) {
              todayRevenue += companyShare;
            }

            // This Month
            if (date.month == now.month && date.year == now.year) {
              monthRevenue += companyShare;
            }
          }

          return Column(
            children: [
              // ================= SUMMARY =================
              Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _summaryCard(
                      title: 'Total Revenue',
                      value: '₹ $totalRevenue',
                      color: Colors.green,
                      icon: Icons.account_balance,
                    ),
                    _summaryCard(
                      title: 'Today',
                      value: '₹ $todayRevenue',
                      color: Colors.blue,
                      icon: Icons.today,
                    ),
                    _summaryCard(
                      title: 'This Month',
                      value: '₹ $monthRevenue',
                      color: Colors.orange,
                      icon: Icons.calendar_month,
                    ),
                    _summaryCard(
                      title: 'Transactions',
                      value: '${docs.length}',
                      color: Colors.purple,
                      icon: Icons.receipt_long,
                    ),
                  ],
                ),
              ),

              const Divider(),

              // ================= TRANSACTION LIST =================
              Expanded(
                child: docs.isEmpty
                    ? const Center(
                        child: Text('No revenue records found'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;

                          final int companyShare =
                              data['companyShare'] ?? 0;
                          final String partnerId =
                              data['partnerId'] ?? '-';

                          final Timestamp ts = data['createdAt'];
                          final String date = DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(ts.toDate());

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const Icon(
                                Icons.trending_up,
                                color: Colors.green,
                              ),
                              title: Text(
                                '₹ $companyShare',
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
          );
        },
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
