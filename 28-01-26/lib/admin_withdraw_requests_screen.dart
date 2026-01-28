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

              final partnerId = data['partnerId'];
              final amount = data['amount'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('Partner: $partnerId'),
                  subtitle: Text('Amount: ₹ $amount'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ❌ REJECT
                      IconButton(
                        icon:
                            const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('withdraw_requests')
                              .doc(doc.id)
                              .update({
                            'status': 'rejected',
                            'rejectedAt':
                                FieldValue.serverTimestamp(),
                          });
                        },
                      ),

                      // ✅ APPROVE
                      IconButton(
                        icon: const Icon(Icons.check,
                            color: Colors.green),
                        onPressed: () async {
                          await _approveWithdraw(
                            partnerId: partnerId,
                            amount: amount,
                            requestId: doc.id,
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

  // ================= APPROVE LOGIC =================
  static Future<void> _approveWithdraw({
    required String partnerId,
    required int amount,
    required String requestId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final partnerRef =
        firestore.collection('partners').doc(partnerId);

    await firestore.runTransaction((transaction) async {
      final partnerSnap = await transaction.get(partnerRef);

      final currentWallet =
          partnerSnap['walletBalance'] ?? 0;

      // Safety check
      if (currentWallet < amount) {
        throw Exception('Insufficient wallet balance');
      }

      // 1️⃣ Wallet ZERO (or deduct)
      transaction.update(partnerRef, {
        'walletBalance': currentWallet - amount,
      });

      // 2️⃣ Mark request approved
      transaction.update(
        firestore.collection('withdraw_requests').doc(requestId),
        {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        },
      );
    });
  }
}
