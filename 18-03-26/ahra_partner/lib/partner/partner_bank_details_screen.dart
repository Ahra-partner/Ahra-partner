import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerBankDetailsScreen extends StatefulWidget {
  final String partnerId;

  const PartnerBankDetailsScreen({
    super.key,
    required this.partnerId,
  });

  @override
  State<PartnerBankDetailsScreen> createState() =>
      _PartnerBankDetailsScreenState();
}

class _PartnerBankDetailsScreenState
    extends State<PartnerBankDetailsScreen> {
  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final bankNameController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    accountHolderController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    bankNameController.dispose();
    super.dispose();
  }

  // ================= SAVE BANK DETAILS =================

  Future<void> saveBankDetails() async {
    if (accountHolderController.text.trim().isEmpty ||
        accountNumberController.text.trim().isEmpty ||
        ifscController.text.trim().isEmpty ||
        bankNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .update({
      'bankDetails': {
        'accountHolderName': accountHolderController.text.trim(),
        'accountNumber': accountNumberController.text.trim(),
        'ifsc': ifscController.text.trim(),
        'bankName': bankNameController.text.trim(),
        'addedAt': FieldValue.serverTimestamp(),
      },
    });

    if (!mounted) return;

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bank details saved successfully')),
    );

    Navigator.pop(context); // 🔙 Back to dashboard
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add your bank details to withdraw money',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: accountHolderController,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: accountNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Account Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: ifscController,
              decoration: const InputDecoration(
                labelText: 'IFSC Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: bankNameController,
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            loading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: saveBankDetails,
                      child: const Text('Save Bank Details'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
