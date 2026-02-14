import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_partner_ledger_screen.dart';
import 'admin_partner_farmers_screen.dart';

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

      if (direction == 'credit') {
        stats[partnerId]!['revenue'] =
            stats[partnerId]!['revenue']! + amount;
      }

      if (direction == 'debit' && type == 'withdraw') {
        stats[partnerId]!['paid'] =
            stats[partnerId]!['paid']! + amount;
      }
    }

    return stats;
  }

  // ================= OPTIONS BOTTOM SHEET =================
  void _showOptions(BuildContext context, String partnerId) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('View Ledger'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminPartnerLedgerScreen(
                        partnerId: partnerId,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.agriculture),
                title: const Text('View Farmers'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminPartnerFarmersScreen(
                        partnerId: partnerId,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
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

          final partnerStats =
              _buildPartnerStats(snapshot.data!.docs);

          final partnerIds =
              partnerStats.keys.toList();

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

              return GestureDetector(
                onTap: () =>
                    _showOptions(context, partnerId),
                child: Card(
                  margin:
                      const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        // 🔥 PARTNER NAME + MOBILE + STATUS
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [

                            // NAME + MOBILE
                            Expanded(
                              child: StreamBuilder<
                                  DocumentSnapshot>(
                                stream: FirebaseFirestore
                                    .instance
                                    .collection(
                                        'partners')
                                    .doc(partnerId)
                                    .snapshots(),
                                builder:
                                    (context, snapshot) {
                                  if (!snapshot
                                          .hasData ||
                                      !snapshot
                                          .data!
                                          .exists) {
                                    return Text(
                                      partnerId,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    );
                                  }

                                  final partnerData =
                                      snapshot.data!
                                              .data()
                                          as Map<
                                              String,
                                              dynamic>;

                                  final String name =
                                      partnerData[
                                              'name'] ??
                                          'No Name';

                                  final String mobile =
                                      partnerData[
                                              'mobile'] ??
                                          '';

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        name,
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (mobile
                                          .isNotEmpty)
                                        Text(
                                          mobile,
                                          style:
                                              const TextStyle(
                                            fontSize: 13,
                                            color: Colors
                                                .grey,
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 8),

                            // STATUS SWITCH
                            StreamBuilder<
                                DocumentSnapshot>(
                              stream: FirebaseFirestore
                                  .instance
                                  .collection(
                                      'partners')
                                  .doc(partnerId)
                                  .snapshots(),
                              builder:
                                  (context, snapshot) {
                                if (!snapshot
                                        .hasData ||
                                    !snapshot
                                        .data!
                                        .exists) {
                                  return const SizedBox();
                                }

                                final data =
                                    snapshot.data!
                                            .data()
                                        as Map<
                                            String,
                                            dynamic>?;

                                final String status =
                                    data?['status'] ??
                                        'active';

                                final bool isActive =
                                    status ==
                                        'active';

                                return Switch(
                                  value: isActive,
                                  activeColor:
                                      Colors.green,
                                  onChanged:
                                      (value) async {
                                    await FirebaseFirestore
                                        .instance
                                        .collection(
                                            'partners')
                                        .doc(partnerId)
                                        .update({
                                      'status': value
                                          ? 'active'
                                          : 'inactive',
                                    });
                                  },
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

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
  Widget _row(
      String label, int amount, Color color) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
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
