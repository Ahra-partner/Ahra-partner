import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// 🔽 CSV EXPORT SERVICE
import 'admin_export_service.dart';

class AdminRevenueDashboardScreen extends StatelessWidget {
  const AdminRevenueDashboardScreen({super.key});

  // ================= CALCULATE METRICS =================
  Map<String, int> _calculateMetrics(
    List<QueryDocumentSnapshot> docs,
  ) {
    int totalRevenue = 0;       // 100% money from customers
    int partnerCommission = 0;  // paid to partners (withdraw)

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final String direction = data['direction'] ?? '';
      final String type = data['type'] ?? '';
      final int amount = (data['amount'] ?? 0) as int;

      if (direction == 'credit') {
        totalRevenue += amount;
      }

      if (direction == 'debit' && type == 'withdraw') {
        partnerCommission += amount;
      }
    }

    final int companyShare =
        totalRevenue - partnerCommission;

    return {
      'revenue': totalRevenue,
      'commission': partnerCommission,
      'company': companyShare,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ================= APP BAR =================
      appBar: AppBar(
        title: const Text('AHRA Revenue Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () async {
              await AdminExportService.exportLedgerToCsv();
            },
          ),
        ],
      ),

      // ================= BODY =================
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wallet_ledger')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No revenue data found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;
          final metrics = _calculateMetrics(docs);

          return Column(
            children: [
              // ================= SUMMARY =================
              Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _summaryCard(
                      title: 'Total Revenue (100%)',
                      value: '₹ ${metrics['revenue']}',
                      color: Colors.green,
                      icon: Icons.account_balance,
                    ),
                    _summaryCard(
                      title: 'Partner Commission Paid',
                      value: '₹ ${metrics['commission']}',
                      color: Colors.blue,
                      icon: Icons.payments,
                    ),
                    _summaryCard(
                      title: 'Company Share (Net)',
                      value: '₹ ${metrics['company']}',
                      color: Colors.deepPurple,
                      icon: Icons.trending_up,
                    ),
                    _summaryCard(
                      title: 'Total Transactions',
                      value: '${docs.length}',
                      color: Colors.orange,
                      icon: Icons.receipt_long,
                    ),
                  ],
                ),
              ),

              const Divider(),

              // ================= LEDGER LIST =================
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data()
                            as Map<String, dynamic>;

                    final int amount =
                        (data['amount'] ?? 0) as int;
                    final String direction =
                        data['direction'] ?? '';
                    final String type =
                        data['type'] ?? '';
                    final String partnerId =
                        data['partnerId'] ?? '-';

                    final Timestamp? ts =
                        data['createdAt'];
                    final String date = ts == null
                        ? 'Just now'
                        : DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(ts.toDate());

                    final bool isCredit =
                        direction == 'credit';

                    return Card(
                      margin:
                          const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          isCredit
                              ? Icons.call_received
                              : Icons.call_made,
                          color: isCredit
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(
                          '₹ $amount',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Type: $type\nPartner: $partnerId\n$date',
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

  // ================= SUMMARY CARD (FIXED – NO OVERFLOW) =================
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
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
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