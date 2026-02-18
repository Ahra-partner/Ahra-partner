import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminWithdrawRequestsScreen extends StatelessWidget {
  const AdminWithdrawRequestsScreen({super.key});

  // ================= APPROVE (NO WALLET UPDATE HERE) =================
  Future<void> _approveWithdraw({
    required BuildContext context,
    required String partnerId,
    required int amount, // partner visible amount (50%)
    required String requestId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final requestRef =
        firestore.collection('withdraw_requests').doc(requestId);
    final ledgerRef =
        firestore.collection('wallet_ledger').doc();

    try {
      await firestore.runTransaction((transaction) async {
        // 1️⃣ Update withdraw request ONLY
        transaction.update(requestRef, {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });

        // 2️⃣ Create ledger entry (RAW = amount × 2)
        transaction.set(ledgerRef, {
          'partnerId': partnerId,
          'type': 'withdraw',
          'direction': 'debit',
          'amount': amount * 2, // 🔥 RAW wallet value
          'description': 'Withdraw approved by admin',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdraw approved successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  // ================= REJECT WITH REASON DIALOG =================
  Future<void> _showRejectDialog(
    BuildContext context,
    String requestId,
  ) async {
    final TextEditingController reasonCtrl =
        TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reject Withdraw'),
          content: TextField(
            controller: reasonCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter reject reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                if (reasonCtrl.text.trim().isEmpty) return;

                await FirebaseFirestore.instance
                    .collection('withdraw_requests')
                    .doc(requestId)
                    .update({
                  'status': 'rejected',
                  'rejectReason': reasonCtrl.text.trim(),
                  'rejectedAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Withdraw request rejected'),
                  ),
                );
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Requests'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdraw_requests')
            .where('status', isEqualTo: 'pending')
            .orderBy('requestedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
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
                'No pending withdraw requests',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data =
                  doc.data() as Map<String, dynamic>;

              final String partnerId = data['partnerId'];
              final int amount = data['amount'] ?? 0;
              final Timestamp? ts = data['requestedAt'];
              final DateTime? date = ts?.toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    '₹ $amount',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Partner: $partnerId\n'
                    '${date == null ? '' : DateFormat.yMMMd().add_jm().format(date)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ❌ Reject
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            _showRejectDialog(
                                context, doc.id),
                      ),

                      // ✅ Approve
                      IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                        onPressed: () => _approveWithdraw(
                          context: context,
                          partnerId: partnerId,
                          amount: amount,
                          requestId: doc.id,
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
