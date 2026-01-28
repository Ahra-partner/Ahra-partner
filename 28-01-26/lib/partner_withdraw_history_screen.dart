import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PartnerWithdrawHistoryScreen extends StatelessWidget {
  final String partnerId;

  const PartnerWithdrawHistoryScreen({
    super.key,
    required this.partnerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw History'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdraw_requests')
            .where('partnerId', isEqualTo: partnerId)
            .orderBy('requestedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No withdraw history found',
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

              final amount = data['amount'] ?? 0;
              final status = data['status'] ?? 'pending';

              final Timestamp ts = data['requestedAt'];
              final date = DateFormat('dd MMM yyyy, hh:mm a')
                  .format(ts.toDate());

              Color statusColor;
              IconData statusIcon;

              switch (status) {
                case 'approved':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  break;
                default:
                  statusColor = Colors.orange;
                  statusIcon = Icons.hourglass_top;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 32,
                  ),
                  title: Text(
                    '₹ $amount',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Requested on: $date'),
                      const SizedBox(height: 2),
                      Text(
                        'Status: ${status.toUpperCase()}',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
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
