import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditFarmerSubscriptionScreen extends StatefulWidget {
  final String farmerId;
  final String subscriptionId;

  const EditFarmerSubscriptionScreen({
    super.key,
    required this.farmerId,
    required this.subscriptionId,
  });

  @override
  State<EditFarmerSubscriptionScreen> createState() =>
      _EditFarmerSubscriptionScreenState();
}

class _EditFarmerSubscriptionScreenState
    extends State<EditFarmerSubscriptionScreen> {

  final _formKey = GlobalKey<FormState>();

  String month = '';
  int amount = 0;
  String transactionNo = '';
  String status = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection('farmers')
        .doc(widget.farmerId)
        .collection('subscriptions')
        .doc(widget.subscriptionId)
        .get();

    final data = doc.data()!;

    setState(() {
      month = data['month'] ?? '';
      amount = data['amount'] ?? 0;
      transactionNo = data['transactionNo'] ?? '';
      status = data['status'] ?? '';
      isLoading = false;
    });
  }

  Future<void> updateSubscription() async {

    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection('farmers')
        .doc(widget.farmerId)
        .collection('subscriptions')
        .doc(widget.subscriptionId)
        .set({

      // 🔒 Lock month & amount if paid
      if (status != 'paid') 'month': month,
      if (status != 'paid') 'amount': amount,

      'transactionNo': transactionNo,
      'updatedAt': FieldValue.serverTimestamp(),
      'isCorrected': true,

    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Subscription Updated Successfully"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    bool isPaid = status == 'paid';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Farmer Subscription"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                initialValue: month,
                enabled: !isPaid, // 🔒 lock if paid
                decoration: const InputDecoration(
                  labelText: "Month",
                ),
                onChanged: (v) => month = v,
                validator: (v) =>
                    v == null || v.isEmpty
                        ? "Month is required"
                        : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                initialValue: amount.toString(),
                enabled: !isPaid, // 🔒 lock if paid
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                ),
                onChanged: (v) =>
                    amount = int.tryParse(v) ?? 0,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Amount is required";
                  }
                  if ((int.tryParse(v) ?? 0) <= 0) {
                    return "Enter valid amount";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                initialValue: transactionNo,
                decoration: const InputDecoration(
                  labelText: "Transaction Number",
                ),
                onChanged: (v) => transactionNo = v,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateSubscription,
                  child: const Text(
                    "Update Subscription",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}