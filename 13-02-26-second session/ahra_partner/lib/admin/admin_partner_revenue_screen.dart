import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 👇 IMPORTANT: Partner ledger detail screen import
import 'admin_partner_ledger_screen.dart';

class AdminPartnerRevenueScreen extends StatelessWidget {
  const AdminPartnerRevenueScreen({super.key});

  // ================= CALCULATE PARTNER-WISE METRICS =================
  Map<String, Map<String, int>> _buildPartnerStats(
    List<QueryDocumentSnapshot> docs,
  ) {
    final Map<String, Map<String, int>> stats = {};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final String partnerId = data['partnerId'] ?? 'unknown';
      final String direction = data['direction'] ?? '';
      final String type = data['type'] ?? '';
      final int amount = (data['amount'] ?? 0) as int;

      stats.putIfAbsent(partnerId, () => {
            'revenue': 0,
            'paid': 0,
          });

      // ✅ CREDIT → revenue earned
      if (direction == 'credit') {
        stats[partnerId]!['revenue'] =
            stats[partnerId]!['revenue']! + amount;
      }

      // ✅ DEBIT (withdraw) → paid to partner
      if (direction == 'debit' && type == 'withdraw') {
        stats[partnerId]!['paid'] =
            stats[partnerId]!['paid']! + amount;
      }
    }

    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner-wise Revenue'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wallet_ledger')
            .snapshots(),
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No revenue data found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final partnerStats =
              _buildPartnerStats(snapshot.data!.docs);

          final partnerIds = partnerStats.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: partnerIds.length,
            itemBuilder: (context, index) {
              final partnerId = partnerIds[index];
              final revenue =
                  partnerStats[partnerId]!['revenue']!;
              final paid =
                  partnerStats[partnerId]!['paid']!;
              final company = revenue - paid;

              // ✅ TAP ENABLED CARD
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminPartnerLedgerScreen(
                        partnerId: partnerId,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🧑 Partner ID
                        Text(
                          'Partner: $partnerId',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _row(
                          'Total Revenue (100%)',
                          revenue,
                          Colors.green,
                        ),
                        _row(
                          'Partner Paid',
                          paid,
                          Colors.blue,
                        ),
                        _row(
                          'Company Share',
                          company,
                          Colors.deepPurple,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= ROW UI =================
  Widget _row(String label, int amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '₹ $amount',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
