import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPartnerLedgerScreen extends StatelessWidget {
  final String partnerId;

  const AdminPartnerLedgerScreen({
    super.key,
    required this.partnerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Ledger'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wallet_ledger')
            .where('partnerId', isEqualTo: partnerId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No transactions found',
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

              final int amount = (data['amount'] ?? 0) as int;
              final String direction = data['direction'] ?? '';
              final String type = data['type'] ?? '';
              final String description =
                  data['description'] ?? '';

              final Timestamp? ts = data['createdAt'];
              final String date = ts == null
                  ? 'Just now'
                  : DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(ts.toDate());

              final bool isCredit = direction == 'credit';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    isCredit
                        ? Icons.call_received
                        : Icons.call_made,
                    color:
                        isCredit ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    '₹ $amount',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Type: $type\n$description\n$date',
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
