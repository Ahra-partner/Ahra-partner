import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBankDetailsScreen extends StatefulWidget {
  final String partnerId;

  const AddBankDetailsScreen({super.key, required this.partnerId});

  @override
  State<AddBankDetailsScreen> createState() => _AddBankDetailsScreenState();
}

class _AddBankDetailsScreenState extends State<AddBankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _holder = TextEditingController();
  final _account = TextEditingController();
  final _ifsc = TextEditingController();
  final _bank = TextEditingController();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection('bank_details')
        .doc(widget.partnerId)
        .set({
      'accountHolder': _holder.text,
      'accountNo': _account.text,
      'ifsc': _ifsc.text,
      'bankName': _bank.text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context); // go back to router
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bank Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _holder,
                decoration:
                    const InputDecoration(labelText: 'Account Holder Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _account,
                decoration:
                    const InputDecoration(labelText: 'Account Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _ifsc,
                decoration: const InputDecoration(labelText: 'IFSC Code'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _bank,
                decoration: const InputDecoration(labelText: 'Bank Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save Bank Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
