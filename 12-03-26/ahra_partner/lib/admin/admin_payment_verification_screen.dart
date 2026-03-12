import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPaymentVerificationScreen extends StatelessWidget {
  const AdminPaymentVerificationScreen({super.key});

  Future<void> approvePayment(
      BuildContext context,
      DocumentReference subRef,
      Map<String, dynamic> subData) async {

    final int amount = subData['amount'] ?? 0;
    final String partnerId = subData['partnerId'] ?? "";

    if (partnerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Partner ID missing")),
      );
      return;
    }

    final int partnerShare = (amount / 2).round();

    final partnerRef =
        FirebaseFirestore.instance.collection('partners').doc(partnerId);

    final ledgerRef =
        FirebaseFirestore.instance.collection('wallet_ledger');

    await FirebaseFirestore.instance.runTransaction((tx) async {

      final subSnap = await tx.get(subRef);

      if (!subSnap.exists) return;

      final data = subSnap.data() as Map<String, dynamic>;

      // prevent double approval
      if (data['status'] != 'pending_verification' &&
          data['status'] != 'pending') return;

      // approve payment
      tx.update(subRef, {
        "status": "approved",
        "approvedAt": FieldValue.serverTimestamp(),
      });

      // credit partner wallet
      tx.set(
        partnerRef,
        {
          "walletBalance": FieldValue.increment(partnerShare),
          "todayEarnings": FieldValue.increment(partnerShare),
          "weekEarnings": FieldValue.increment(partnerShare),
          "monthEarnings": FieldValue.increment(partnerShare),
          "updatedAt": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // wallet ledger entry
      tx.set(ledgerRef.doc(), {
        "partnerId": partnerId,
        "amount": partnerShare,
        "direction": "credit",
        "type": "subscription_commission",
        "description": "Subscription commission approved",
        "createdAt": FieldValue.serverTimestamp(),
      });

    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Approved")),
    );
  }

  Future<void> rejectPayment(
      BuildContext context,
      DocumentReference subRef) async {

    final TextEditingController reasonController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Reject Payment"),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: "Reject Reason",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {

                final reason = reasonController.text.trim();

                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Enter reject reason")),
                  );
                  return;
                }

                await subRef.update({
                  "status": "rejected",
                  "rejectReason": reason,
                  "rejectedAt": FieldValue.serverTimestamp(),

                  "expiryTime": Timestamp.fromDate(
                    DateTime.now().add(
                      const Duration(hours: 12),
                    ),
                  ),
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment Rejected")),
                );
              },
              child: const Text("Reject"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final query = FirebaseFirestore.instance
        .collectionGroup('subscriptions')
        .where("status", isEqualTo: "pending_verification");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Verification"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {

          /// 🔴 HANDLE ERROR
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          /// 🔄 LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// 📦 SAFE DATA FETCH
          final docs = snapshot.data?.docs ?? [];

          /// ❌ EMPTY
          if (docs.isEmpty) {
            return const Center(
              child: Text("No pending payments"),
            );
          }

          /// ✅ DATA LIST
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final doc = docs[index];
              final data =
                  doc.data() as Map<String, dynamic>;

              final screenshot = data['screenshot'] ?? "";

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Transaction ID: ${data['transactionNo'] ?? ''}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 4),

                      Text("Amount: ₹${data['amount'] ?? 0}"),

                      const SizedBox(height: 10),

                      if (screenshot.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                child: Image.network(screenshot),
                              ),
                            );
                          },
                          child: Image.network(
                            screenshot,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),

                      const SizedBox(height: 10),

                      Row(
                        children: [

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.green),
                              onPressed: () {
                                approvePayment(
                                    context,
                                    doc.reference,
                                    data);
                              },
                              child: const Text("Approve"),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.red),
                              onPressed: () {
                                rejectPayment(
                                    context,
                                    doc.reference);
                              },
                              child: const Text("Reject"),
                            ),
                          ),

                        ],
                      )
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