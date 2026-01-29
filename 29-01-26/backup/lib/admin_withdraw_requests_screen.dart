import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminWithdrawRequestsScreen extends StatelessWidget {
  const AdminWithdrawRequestsScreen({super.key});

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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No pending withdraw requests'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String partnerId = data['partnerId'];
              final int amount = data['amount'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('Partner ID: $partnerId'),
                  subtitle: Text('Amount: ₹ $amount'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ❌ REJECT
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('withdraw_requests')
                              .doc(doc.id)
                              .update({
                            'status': 'rejected',
                            'rejectedAt': FieldValue.serverTimestamp(),
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Withdraw request rejected'),
                            ),
                          );
                        },
                      ),

                      // ✅ APPROVE
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await _approveWithdraw(
                            partnerId: partnerId,
                            amount: amount,
                            requestId: doc.id,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Withdraw approved successfully'),
                            ),
                          );
                        },
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

  // ================= FINAL APPROVE WITH WALLET + UNLOCK + LEDGER =================
  static Future<void> _approveWithdraw({
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

    await firestore.runTransaction((transaction) async {
      final partnerSnap = await transaction.get(partnerRef);

      if (!partnerSnap.exists) {
        throw Exception('Partner not found');
      }

      final int currentWallet =
          partnerSnap['walletBalance'] ?? 0;

      // 🔒 Safety check
      if (currentWallet < amount) {
        throw Exception('Insufficient wallet balance');
      }

      // 1️⃣ Deduct wallet + unlock withdraw
      transaction.update(partnerRef, {
        'walletBalance': currentWallet - amount,
        'withdrawLocked': false, // 🔓 unlock for next cycle
      });

      // 2️⃣ Mark request approved
      transaction.update(requestRef, {
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // 3️⃣ Ledger entry (partner payout)
      transaction.set(ledgerRef, {
        'partnerId': partnerId,
        'type': 'withdraw',
        'direction': 'debit',
        'amount': amount,
        'description': 'Withdraw approved by admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
