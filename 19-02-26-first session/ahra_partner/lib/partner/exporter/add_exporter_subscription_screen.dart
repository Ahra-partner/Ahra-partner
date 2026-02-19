import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddExporterSubscriptionScreen extends StatefulWidget {
  final String exporterId;   // 🔥 exporter document ID
  final String exporterName;

  const AddExporterSubscriptionScreen({
    super.key,
    required this.exporterId,
    required this.exporterName,
  });

  @override
  State<AddExporterSubscriptionScreen> createState() =>
      _AddExporterSubscriptionScreenState();
}

class _AddExporterSubscriptionScreenState
    extends State<AddExporterSubscriptionScreen> {

  final _formKey = GlobalKey<FormState>();

  final _monthController = TextEditingController();
  final _txnNoController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _monthController.dispose();
    _txnNoController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ✅ FINAL SUBMIT METHOD (NO WALLET CREDIT HERE)
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final exporterRef = FirebaseFirestore.instance
          .collection('exporters')
          .doc(widget.exporterId);

      final int amount =
          int.parse(_amountController.text.trim());

      // 1️⃣ ADD SUBSCRIPTION (ALWAYS PENDING)
      await exporterRef.collection('subscriptions').add({
        'partnerId': uid,
        'month': _monthController.text.trim(),
        'transactionNo': _txnNoController.text.trim(),
        'amount': amount,

        // 🔥 IMPORTANT
        'status': 'pending', // ✅ not paid

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Exporter subscription added (Pending payment)'),
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Add Exporter Subscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // 🔹 Exporter Name
              Text(
                widget.exporterName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Month
              TextFormField(
                controller: _monthController,
                decoration: const InputDecoration(
                  labelText:
                      'Month (Eg: June 2026)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Required'
                        : null,
              ),

              const SizedBox(height: 12),

              // 🔹 Transaction Number
              TextFormField(
                controller: _txnNoController,
                decoration: const InputDecoration(
                  labelText:
                      'Transaction Number',
                  hintText: 'Eg: TXN12345',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Required'
                        : null,
              ),

              const SizedBox(height: 12),

              // 🔹 Amount
              TextFormField(
                controller: _amountController,
                keyboardType:
                    TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Required'
                        : null,
              ),

              const SizedBox(height: 20),

              // 🔹 SUBMIT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text(
                      'Add Subscription'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
