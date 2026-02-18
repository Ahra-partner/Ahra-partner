import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../language_provider.dart';
import '../../language_screen.dart';
import '../../app_strings.dart';

import 'add_retailer_subscription_screen.dart';
import 'retailer_subscription_details_screen.dart';

class RetailerSubscriptionHistoryScreen extends StatelessWidget {
  final String retailerId;
  final String retailerName;

  const RetailerSubscriptionHistoryScreen({
    super.key,
    required this.retailerId,
    required this.retailerName,
  });

  // 🔥 AUTO SYNC TOTAL PAID
  Future<void> _syncTotalPaid() async {
    final subSnap = await FirebaseFirestore.instance
        .collection('retailers')
        .doc(retailerId)
        .collection('subscriptions')
        .where('status', isEqualTo: 'paid')
        .get();

    int total = 0;

    for (var doc in subSnap.docs) {
      total += (doc['amount'] ?? 0) as int;
    }

    await FirebaseFirestore.instance
        .collection('retailers')
        .doc(retailerId)
        .update({
      'totalPaid': total,
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final t = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retailer Subscription History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) =>
                    const LanguageScreen(fromSettings: true),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddRetailerSubscriptionScreen(
                retailerId: retailerId,
                retailerName: retailerName,
              ),
            ),
          );
        },
      ),

      body: Column(
        children: [

          // ================= RETAILER BASIC DETAILS =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  retailerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t.mobileNumber}: $retailerId',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ================= SUBSCRIPTION HISTORY =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('retailers')
                  .doc(retailerId)
                  .collection('subscriptions')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style:
                          const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No subscriptions yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // 🔥 Every time list loads → sync total
                _syncTotalPaid();

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {

                    final doc = docs[i];
                    final data =
                        doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading:
                            const Icon(Icons.calendar_month),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RetailerSubscriptionDetailsScreen(
                                retailerId: retailerId,
                                subscriptionId: doc.id,
                              ),
                            ),
                          );
                        },

                        title: Text(
                          data['month'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          'Amount: ₹ ${data['amount'] ?? 0}',
                        ),

                        trailing: Text(
                          data['status'] ?? 'pending',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: data['status'] == 'paid'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
