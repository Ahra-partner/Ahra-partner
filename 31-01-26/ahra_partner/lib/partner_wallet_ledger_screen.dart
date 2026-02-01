import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PartnerWalletLedgerScreen extends StatelessWidget {
  final String partnerId;

  const PartnerWalletLedgerScreen({
    super.key,
    required this.partnerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Ledger'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wallet_ledger')
            .where('partnerId', isEqualTo: partnerId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No wallet activity found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data =
                  docs[index].data() as Map<String, dynamic>;

              final int amount = data['amount'] ?? 0;
              final String type = data['type'] ?? '';
              final String direction = data['direction'] ?? '';
              final String description =
                  data['description'] ?? '';

              final Timestamp ts = data['createdAt'];
              final String date = DateFormat(
                'dd MMM yyyy, hh:mm a',
              ).format(ts.toDate());

              final bool isCredit = direction == 'credit';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCredit
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    child: Icon(
                      isCredit
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color:
                          isCredit ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    '${isCredit ? '+' : '-'} ₹ $amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isCredit ? Colors.green : Colors.red,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }
}
