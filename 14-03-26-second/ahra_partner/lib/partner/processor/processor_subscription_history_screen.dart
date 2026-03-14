import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../language_provider.dart';
import '../../language_screen.dart';
import '../../app_strings.dart';

import 'add_processor_subscription_screen.dart';
import 'processor_subscription_details_screen.dart';

class ProcessorSubscriptionHistoryScreen extends StatelessWidget {
  final String processorId;
  final String processorName;

  const ProcessorSubscriptionHistoryScreen({
    super.key,
    required this.processorId,
    required this.processorName,
  });

  // 🔥 AUTO SYNC TOTAL PAID
  Future<void> _syncTotalPaid() async {
    final subSnap = await FirebaseFirestore.instance
        .collection('processors')
        .doc(processorId)
        .collection('subscriptions')
        .where('status', isEqualTo: 'paid')
        .get();

    int total = 0;

    for (var doc in subSnap.docs) {
      total += (doc['amount'] ?? 0) as int;
    }

    await FirebaseFirestore.instance
        .collection('processors')
        .doc(processorId)
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
            const Text('Processor Subscription History'),
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
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProcessorSubscriptionScreen(
                processorId: processorId,
                processorName: processorName,
              ),
            ),
          );
        },
      ),

      body: Column(
        children: [

          // ================= PROCESSOR BASIC DETAILS =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  processorName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t.mobileNumber}: $processorId',
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
                  .collection('processors')
                  .doc(processorId)
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
                                  ProcessorSubscriptionDetailsScreen(
                                processorId:
                                    processorId,
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
