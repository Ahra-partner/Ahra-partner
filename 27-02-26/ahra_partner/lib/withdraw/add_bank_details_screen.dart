import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AddBankDetailsScreen extends StatefulWidget {
  const AddBankDetailsScreen({super.key});

  @override
  State<AddBankDetailsScreen> createState() =>
      _AddBankDetailsScreenState();
}

class _AddBankDetailsScreenState extends State<AddBankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _holderCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();
  final _phonePeCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _fetchBankDetails(String ifsc) async {
    if (ifsc.length < 4) return;

    try {
      final res = await http.get(
        Uri.parse('https://ifsc.razorpay.com/$ifsc'),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _bankCtrl.text = data['BANK'] ?? '';
          _branchCtrl.text = data['BRANCH'] ?? '';
        });
      }
    } catch (_) {
      // silent fail
    }
  }

  // ✅ FIXED SAVE METHOD
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _loading = true);

      final partnerId =
          FirebaseAuth.instance.currentUser!.uid;

      debugPrint('Saving bank details for $partnerId');

      await FirebaseFirestore.instance
          .collection('partners')
          .doc(partnerId)
          .collection('bank_details')   // ✅ FIXED HERE
          .doc('main')
          .set({
        'accountHolder': _holderCtrl.text.trim(),
        'accountNumber': _accountCtrl.text.trim(),
        'ifsc': _ifscCtrl.text.trim().toUpperCase(),
        'bankName': _bankCtrl.text.trim(),
        'branch': _branchCtrl.text.trim(),
        'phonePe': _phonePeCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Bank details saved successfully');

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('SAVE BANK ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save bank details'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bank Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _holderCtrl,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _accountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _ifscCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'IFSC Code',
                ),
                onChanged: _fetchBankDetails,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _bankCtrl,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _branchCtrl,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Branch',
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _phonePeCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'PhonePe / UPI Number (optional)',
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Save & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}