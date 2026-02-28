import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PartnerWalletLedgerScreen extends StatelessWidget {
  final String partnerId;
  final DateTime? fromDate;
  final DateTime? toDate;

  const PartnerWalletLedgerScreen({
    super.key,
    required this.partnerId,
    this.fromDate,
    this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Ledger'),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {

          // ✅ Base Query
          Query query = FirebaseFirestore.instance
              .collection('wallet_ledger')
              .where('partnerId', isEqualTo: partnerId)
              .orderBy('createdAt', descending: true);

          // ✅ Apply Date Filter if available
          if (fromDate != null && toDate != null) {
            query = query
                .where(
                  'createdAt',
                  isGreaterThanOrEqualTo:
                      Timestamp.fromDate(fromDate!),
                )
                .where(
                  'createdAt',
                  isLessThanOrEqualTo:
                      Timestamp.fromDate(
                        toDate!.add(const Duration(days: 1)),
                      ),
                );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {

              // 🔥 Show error clearly
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

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
                    'No wallet activity found',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, index) {

                  final data =
                      docs[index].data() as Map<String, dynamic>;

                  final int amount =
                      (data['amount'] ?? 0);

                  final String direction =
                      data['direction'] ?? '';

                  final String description =
                      data['description'] ?? '';

                  String date = '';

                  if (data['createdAt'] != null) {
                    final Timestamp ts =
                        data['createdAt'];
                    date = DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(ts.toDate());
                  }

                  final bool isCredit =
                      direction == 'credit';

                  return Card(
                    margin:
                        const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCredit
                            ? Colors.green.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        child: Icon(
                          isCredit
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: isCredit
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      title: Text(
                        '${isCredit ? '+' : '-'} ₹ $amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCredit
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(description),
                          const SizedBox(height: 2),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
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
}
