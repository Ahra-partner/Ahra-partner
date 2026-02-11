import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawAmountScreen extends StatefulWidget {
  final String partnerId;
  final int walletAmount;

  const WithdrawAmountScreen({
    super.key,
    required this.partnerId,
    required this.walletAmount,
  });

  @override
  State<WithdrawAmountScreen> createState() =>
      _WithdrawAmountScreenState();
}

class _WithdrawAmountScreenState extends State<WithdrawAmountScreen> {
  final _amountCtrl = TextEditingController();

  Future<void> _submit() async {
    final amount = int.tryParse(_amountCtrl.text) ?? 0;

    if (amount <= 0 || amount > widget.walletAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('withdraw_requests')
        .add({
      'partnerId': widget.partnerId,
      'amount': amount,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Withdraw request sent to admin'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw Amount')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Balance: ₹${widget.walletAmount}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Enter amount'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit Withdraw Request'),
            ),
          ],
        ),
      ),
    );
  }
}
