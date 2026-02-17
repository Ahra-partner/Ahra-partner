import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'admin_partner_ledger_screen.dart';
import 'admin_partner_farmers_screen.dart';
import 'admin_partner_retailers_screen.dart'; // ✅ NEW IMPORT

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
  void _showOptions(
    BuildContext context,
    String partnerId,
    String mobile,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // 📄 Ledger
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

              // 🌾 Farmers
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

              // 🏪 RETAILERS  ✅ NEW OPTION
              ListTile(
                leading: const Icon(Icons.store),
                title: const Text('View Retailers'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminPartnerRetailersScreen(
                        partnerId: partnerId,
                      ),
                    ),
                  );
                },
              ),

              // 📞 CALL PARTNER
              if (mobile.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Call Partner'),
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri uri = Uri.parse("tel:$mobile");
                    await launchUrl(uri);
                  },
                ),

              // 🟢 WHATSAPP PARTNER
              if (mobile.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('WhatsApp Partner'),
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri uri =
                        Uri.parse("https://wa.me/$mobile");
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
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

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('partners')
                    .doc(partnerId)
                    .snapshots(),
                builder: (context, partnerSnapshot) {

                  String name = partnerId;
                  String mobile = '';
                  bool isActive = true;

                  if (partnerSnapshot.hasData &&
                      partnerSnapshot.data!.exists) {

                    final partnerData =
                        partnerSnapshot.data!.data()
                            as Map<String, dynamic>;

                    name =
                        partnerData['name'] ?? 'No Name';

                    mobile =
                        partnerData['mobile'] ?? '';

                    final status =
                        partnerData['status'] ??
                            'active';

                    isActive = status == 'active';
                  }

                  return GestureDetector(
                    onTap: () => _showOptions(
                      context,
                      partnerId,
                      mobile,
                    ),
                    child: Card(
                      margin: const EdgeInsets.only(
                          bottom: 12),
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

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
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
                                  ),
                                ),

                                Switch(
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
          );
        },
      ),
    );
  }

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
