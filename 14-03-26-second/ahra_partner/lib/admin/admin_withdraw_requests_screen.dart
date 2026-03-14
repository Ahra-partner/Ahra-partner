import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ ADDED
import 'package:intl/intl.dart';

class AdminWithdrawRequestsScreen extends StatelessWidget {
  const AdminWithdrawRequestsScreen({super.key});

  // ================= APPROVE =================
  Future<void> _approveWithdraw({
    required BuildContext context,
    required String partnerId,
    required int amount,
    required String requestId,
  }) async {

    // ✅ DEBUG PRINTS
    print("🔥 ADMIN UID: ${FirebaseAuth.instance.currentUser?.uid}");
    print("🔥 ADMIN EMAIL: ${FirebaseAuth.instance.currentUser?.email}");

    final firestore = FirebaseFirestore.instance;

    try {
      await firestore.runTransaction((tx) async {

        final withdrawRef =
            firestore.collection('withdraw_requests').doc(requestId);

        final partnerRef =
            firestore.collection('partners').doc(partnerId);

        final ledgerRef =
            firestore.collection('wallet_ledger').doc();

        final withdrawSnap = await tx.get(withdrawRef);
        final partnerSnap = await tx.get(partnerRef);

        if (!withdrawSnap.exists) {
          throw Exception("Withdraw request not found");
        }

        if (withdrawSnap['status'] != 'pending') {
          throw Exception("Already processed");
        }

        final currentWallet =
            (partnerSnap['walletBalance'] ?? 0).toInt();

        if (currentWallet < amount) {
          throw Exception("Insufficient wallet balance");
        }

        // ✅ 1. Update withdraw request
        tx.update(withdrawRef, {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });

        // ✅ 2. Deduct wallet balance
        tx.update(partnerRef, {
          'walletBalance': FieldValue.increment(-amount),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // ✅ 3. Add ledger entry
        tx.set(ledgerRef, {
          'partnerId': partnerId,
          'type': 'withdraw',
          'direction': 'debit',
          'amount': amount,
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
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ================= REJECT =================
  Future<void> _showRejectDialog(
      BuildContext context, String requestId) async {

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
                    content: Text('Withdraw request rejected'),
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

                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            _showRejectDialog(
                                context, doc.id),
                      ),

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