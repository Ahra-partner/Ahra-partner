import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPartnerOverviewScreen extends StatelessWidget {
  const AdminPartnerOverviewScreen({super.key});

  // 🔥 Build Partner Stats
  Future<Map<String, dynamic>> _buildStats(String partnerId) async {
    final farmers = await FirebaseFirestore.instance
        .collection('farmers')
        .where('partnerId', isEqualTo: partnerId)
        .get();

    final retailers = await FirebaseFirestore.instance
        .collection('retailers')
        .where('partnerId', isEqualTo: partnerId)
        .get();

    final ledger = await FirebaseFirestore.instance
        .collection('wallet_ledger')
        .where('partnerId', isEqualTo: partnerId)
        .get();

    int totalRevenue = 0;
    int commissionPaid = 0;

    for (var doc in ledger.docs) {
      final data = doc.data();

      final direction = data['direction'] ?? '';
      final type = data['type'] ?? '';
      final amount = (data['amount'] ?? 0) as int;

      if (direction == 'credit') {
        totalRevenue += amount;
      }

      if (direction == 'debit' && type == 'withdraw') {
        commissionPaid += amount;
      }
    }

    return {
      "farmers": farmers.docs.length,
      "retailers": retailers.docs.length,
      "revenue": totalRevenue,
      "commission": commissionPaid,
      "company": totalRevenue - commissionPaid,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Partner Business Overview"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ Removed role filter
        stream: FirebaseFirestore.instance
            .collection('partners')
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final partners = snapshot.data!.docs;

          if (partners.isEmpty) {
            return const Center(
              child: Text("No partners found"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: partners.length,
            itemBuilder: (context, index) {

              final partnerDoc = partners[index];
              final partnerId = partnerDoc.id;
              final data =
                  partnerDoc.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'No Name';
              final mobile = data['mobile'] ?? '';

              // ❌ Skip Admin Entry
              if (name.toLowerCase() == 'admin') {
                return const SizedBox();
              }

              return FutureBuilder(
                future: _buildStats(partnerId),
                builder: (context, statsSnapshot) {

                  if (!statsSnapshot.hasData) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  final stats =
                      statsSnapshot.data as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          // 🔷 Header
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (mobile.isNotEmpty)
                            Text(
                              mobile,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                          const Divider(height: 20),

                          // 🔢 COUNT VALUES (NO ₹)
                          _countRow("Total Farmers",
                              stats['farmers'], Colors.green),

                          _countRow("Total Retailers",
                              stats['retailers'], Colors.orange),

                          const SizedBox(height: 6),

                          // 💰 MONEY VALUES (WITH ₹)
                          _moneyRow("Total Revenue (100%)",
                              stats['revenue'], Colors.blue),

                          _moneyRow("Commission Paid",
                              stats['commission'], Colors.red),

                          _moneyRow("Company Share",
                              stats['company'], Colors.deepPurple),
                        ],
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

  // 🔢 Count Row (No ₹)
  Widget _countRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            "$value",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 💰 Money Row (With ₹)
  Widget _moneyRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            "₹ $value",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
