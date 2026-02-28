import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'admin_partner_ledger_screen.dart';
import 'admin_partner_farmers_screen.dart';
import 'admin_partner_retailers_screen.dart';
import 'admin_partner_wholesalers_screen.dart';
import 'admin_partner_processors_screen.dart';
import 'admin_partner_exporters_screen.dart';

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

              // 🏪 Retailers
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

              // 🏢 Wholesalers
              ListTile(
                leading: const Icon(Icons.warehouse),
                title: const Text('View Wholesalers'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminPartnerWholesalersScreen(
                        partnerId: partnerId,
                      ),
                    ),
                  );
                },
              ),

              // 🏭 Processors
              ListTile(
                leading: const Icon(Icons.factory),
                title: const Text('View Processors'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminPartnerProcessorsScreen(
                        partnerId: partnerId,
                      ),
                    ),
                  );
                },
              ),

              // 🌍 Exporters
              ListTile(
                leading: const Icon(Icons.public),
                title: const Text('View Exporters'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminPartnerExportersScreen(
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

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No revenue data found'),
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

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(partnerId),
                  subtitle: Text(
                      "Revenue: ₹$revenue | Paid: ₹$paid | Company: ₹$company"),
                  onTap: () =>
                      _showOptions(context, partnerId, ""),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
