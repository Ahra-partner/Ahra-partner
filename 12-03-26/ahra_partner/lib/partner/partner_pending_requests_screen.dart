import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerPendingRequestsScreen extends StatelessWidget {
  final String partnerId;

  const PartnerPendingRequestsScreen({
    super.key,
    required this.partnerId,
  });

  @override
  Widget build(BuildContext context) {

    final query = FirebaseFirestore.instance
        .collectionGroup('subscriptions')
        .where('partnerId', isEqualTo: partnerId)
        .where('status', isEqualTo: 'pending_verification');
       // .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Payment Requests"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("No requests found"),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No payment requests"),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final doc = docs[index];
              final data =
                  doc.data() as Map<String, dynamic>;

              final status = data['status'] ?? "pending";
              final reason = data['rejectReason'] ?? "";
              final screenshot = data['screenshot'] ?? "";

              Color statusColor = Colors.orange;

              if (status == "approved") {
                statusColor = Colors.green;
              } else if (status == "rejected") {
                statusColor = Colors.red;
              }

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Transaction: ${data['transactionNo'] ?? ""}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text("Amount: ₹${data['amount'] ?? 0}"),

                      const SizedBox(height: 10),

                      if (screenshot.isNotEmpty)
                        Image.network(
                          screenshot,
                          height: 150,
                          fit: BoxFit.cover,
                        ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Text("Status: "),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      if (status == "pending")
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            "Waiting for admin approval",
                            style: TextStyle(
                              color: Colors.orange,
                            ),
                          ),
                        ),

                      if (status == "rejected")
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            const SizedBox(height: 6),

                            Text(
                              "Reject Reason: $reason",
                              style: const TextStyle(
                                  color: Colors.red),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              "Fix and resubmit within 12 hours",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
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