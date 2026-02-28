import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PartnerWithdrawHistoryScreen extends StatelessWidget {
  const PartnerWithdrawHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String partnerId =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw History'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdraw_requests')
            .where('partnerId', isEqualTo: partnerId)
            .orderBy('requestedAt', descending: true) // ✅ IMPORTANT FIX
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No withdrawal history yet',
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

              final int amount = data['amount'] ?? 0;
              final String status =
                  data['status'] ?? 'pending';
              final String? rejectReason =
                  data['rejectReason'];

              final Timestamp? ts = data['requestedAt'];
              final String date = ts == null
                  ? 'Just now'
                  : DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(ts.toDate());

              Color statusColor;
              IconData statusIcon;
              String statusText;

              switch (status) {
                case 'approved':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  statusText = 'Approved';
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  statusText = 'Rejected';
                  break;
                default:
                  statusColor = Colors.orange;
                  statusIcon = Icons.hourglass_top;
                  statusText = 'Pending';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        'Requested on: $date',
                        style:
                            const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              statusColor.withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      if (status == 'approved')
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 6),
                          child: Text(
                            'Amount will be sent within 4 hours',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      if (status == 'rejected' &&
                          rejectReason != null &&
                          rejectReason.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8),
                          child: Text(
                            'Reason: $rejectReason',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
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