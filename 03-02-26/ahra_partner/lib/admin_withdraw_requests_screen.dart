import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminWithdrawRequestsScreen extends StatelessWidget {
  const AdminWithdrawRequestsScreen({super.key});

  // ================= APPROVE WITH TRANSACTION =================
  Future<void> _approveWithdraw({
    required BuildContext context,
    required String partnerId,
    required int amount,
    required String requestId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final partnerRef =
        firestore.collection('partners').doc(partnerId);
    final requestRef =
        firestore.collection('withdraw_requests').doc(requestId);
    final ledgerRef =
        firestore.collection('wallet_ledger').doc();

    try {
      await firestore.runTransaction((transaction) async {
        final partnerSnap = await transaction.get(partnerRef);

        if (!partnerSnap.exists) {
          throw Exception('Partner not found');
        }

        final int currentWallet =
            (partnerSnap.data()?['walletBalance'] ?? 0) as int;

        if (currentWallet < amount) {
          throw Exception('Insufficient wallet balance');
        }

        // 1️⃣ Wallet deduct
        transaction.update(partnerRef, {
          'walletBalance': currentWallet - amount,
          'withdrawLocked': false,
        });

        // 2️⃣ Approve request
        transaction.update(requestRef, {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });

        // 3️⃣ Ledger entry
        transaction.set(ledgerRef, {
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
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  // ================= REJECT =================
  Future<void> _rejectWithdraw(
    BuildContext context,
    String requestId,
  ) async {
    await FirebaseFirestore.instance
        .collection('withdraw_requests')
        .doc(requestId)
        .update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Withdraw request rejected'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🔥 AdminWithdrawRequestsScreen OPENED');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Requests'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdraw_requests')
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // ✅ FIX 1: Proper loading handling
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ✅ FIX 2: Empty / no data handling
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
              final int amount = data['amount'];
              final Timestamp? ts = data['createdAt'];
              final date = ts?.toDate();

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
                            _rejectWithdraw(context, doc.id),
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
