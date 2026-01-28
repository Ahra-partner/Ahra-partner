import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPayoutSummaryScreen extends StatelessWidget {
  const AdminPayoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payout Summary'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdraw_requests')
            .orderBy('requestedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          int totalRequested = 0;
          int totalApproved = 0;
          int totalRejected = 0;
          int pendingCount = 0;

          for (var d in docs) {
            final data = d.data() as Map<String, dynamic>;
            final amount = data['amount'] ?? 0;
            final status = data['status'];

            totalRequested += amount;

            if (status == 'approved') {
              totalApproved += amount;
            } else if (status == 'rejected') {
              totalRejected += amount;
            } else {
              pendingCount++;
            }
          }

          return Column(
            children: [
              // ================= SUMMARY CARDS =================
              Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _summaryCard(
                      title: 'Total Requested',
                      value: '₹ $totalRequested',
                      color: Colors.blue,
                    ),
                    _summaryCard(
                      title: 'Approved Payout',
                      value: '₹ $totalApproved',
                      color: Colors.green,
                    ),
                    _summaryCard(
                      title: 'Rejected Amount',
                      value: '₹ $totalRejected',
                      color: Colors.red,
                    ),
                    _summaryCard(
                      title: 'Pending Requests',
                      value: '$pendingCount',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              const Divider(),

              // ================= REQUEST LIST =================
              Expanded(
                child: docs.isEmpty
                    ? const Center(
                        child: Text('No withdraw requests'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;

                          final partnerId =
                              data['partnerId'] ?? '-';
                          final amount = data['amount'] ?? 0;
                          final status = data['status'] ?? 'pending';

                          final Timestamp ts = data['requestedAt'];
                          final date = DateFormat(
                                  'dd MMM yyyy, hh:mm a')
                              .format(ts.toDate());

                          Color statusColor;
                          switch (status) {
                            case 'approved':
                              statusColor = Colors.green;
                              break;
                            case 'rejected':
                              statusColor = Colors.red;
                              break;
                            default:
                              statusColor = Colors.orange;
                          }

                          return Card(
                            margin:
                                const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(
                                '₹ $amount',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Partner: $partnerId'),
                                  Text('Date: $date'),
                                ],
                              ),
                              trailing: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
