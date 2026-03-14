import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../language_provider.dart';
import '../../language_screen.dart';
import '../../app_strings.dart';

import 'add_exporter_subscription_screen.dart';
import 'exporter_subscription_details_screen.dart';

class ExporterSubscriptionHistoryScreen extends StatelessWidget {
  final String exporterId;
  final String exporterName;

  const ExporterSubscriptionHistoryScreen({
    super.key,
    required this.exporterId,
    required this.exporterName,
  });

  // 🔥 AUTO SYNC TOTAL PAID
  Future<void> _syncTotalPaid() async {
    final subSnap = await FirebaseFirestore.instance
        .collection('exporters')
        .doc(exporterId)
        .collection('subscriptions')
        .where('status', isEqualTo: 'paid')
        .get();

    int total = 0;

    for (var doc in subSnap.docs) {
      total += (doc['amount'] ?? 0) as int;
    }

    await FirebaseFirestore.instance
        .collection('exporters')
        .doc(exporterId)
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
        title:
            const Text('Exporter Subscription History'),
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
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExporterSubscriptionScreen(
                exporterId: exporterId,
                exporterName: exporterName,
              ),
            ),
          );
        },
      ),

      body: Column(
        children: [

          // ================= EXPORTER BASIC DETAILS =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  exporterName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t.mobileNumber}: $exporterId',
                  style: const TextStyle(
                      color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ================= SUBSCRIPTION HISTORY =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('exporters')
                  .doc(exporterId)
                  .collection('subscriptions')
                  .orderBy('createdAt',
                      descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                          color: Colors.red),
                    ),
                  );
                }

                final docs =
                    snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No subscriptions yet',
                      style: TextStyle(
                          color: Colors.grey),
                    ),
                  );
                }

                // 🔥 Sync total every load
                _syncTotalPaid();

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {

                    final doc = docs[i];
                    final data =
                        doc.data()
                            as Map<String, dynamic>;

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(
                            Icons.calendar_month),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExporterSubscriptionDetailsScreen(
                                exporterId:
                                    exporterId,
                                subscriptionId:
                                    doc.id,
                              ),
                            ),
                          );
                        },

                        title: Text(
                          data['month'] ?? '-',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          'Amount: ₹ ${data['amount'] ?? 0}',
                        ),

                        trailing: Text(
                          data['status'] ??
                              'pending',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            color:
                                data['status'] ==
                                        'paid'
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
