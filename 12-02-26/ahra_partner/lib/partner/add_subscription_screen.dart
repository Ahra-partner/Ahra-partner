import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final String farmerId; // 🔥 farmer document ID
  final String farmerName;

  const AddSubscriptionScreen({
    super.key,
    required this.farmerId,
    required this.farmerName,
  });

  @override
  State<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _monthController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _monthController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ✅ FINAL SUBMIT METHOD
  // ➜ Adds subscription
  // ➜ Updates farmer subscriptionAmount (FIXES ₹0 ISSUE)
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final farmerRef = FirebaseFirestore.instance
          .collection('farmers')
          .doc(widget.farmerId); // 🔥 farmer doc id

      final int amount =
          int.parse(_amountController.text.trim());

      // 1️⃣ ADD SUBSCRIPTION (HISTORY)
      await farmerRef
          .collection('subscriptions')
          .add({
        'partnerId': uid, // 🔥 MUST (rules)
        'month': _monthController.text.trim(),
        'amount': amount,
        'status': 'paid',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2️⃣ 🔥 UPDATE FARMER SUMMARY (ACCUMULATE AMOUNT)
      await farmerRef.update({
        'subscriptionAmount': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription added successfully'),
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
        title: const Text('Add Monthly Subscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Farmer Name
              Text(
                widget.farmerName,
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
                  labelText: 'Month (Eg: June 2026)',
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
                keyboardType: TextInputType.number,
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

              // 🔹 SUBMIT BUTTON
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Subscription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
