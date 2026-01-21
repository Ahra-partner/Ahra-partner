import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'app_strings.dart';

class UpdateKycScreen extends StatefulWidget {
  final String partnerId;

  const UpdateKycScreen({
    super.key,
    required this.partnerId,
  });

  @override
  State<UpdateKycScreen> createState() => _UpdateKycScreenState();
}

class _UpdateKycScreenState extends State<UpdateKycScreen> {
  final nameController = TextEditingController();
  final panController = TextEditingController();
  final aadhaarController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    panController.dispose();
    aadhaarController.dispose();
    super.dispose();
  }

  Future<void> submitKyc() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .update({
      'name': nameController.text.trim(),
      'pan': panController.text.trim(),
      'aadhaar': aadhaarController.text.trim(),
      'kycStatus': 'pending',          // 🔁 back to pending
      'rejectionReason': '',
      'kycSubmittedAt': FieldValue.serverTimestamp(),
    });

    setState(() => loading = false);

    // 🔙 Back to Home → Pending screen automatically
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final s = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('update_kyc')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: panController,
              decoration: const InputDecoration(
                labelText: 'PAN Number',
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: aadhaarController,
              decoration: const InputDecoration(
                labelText: 'Aadhaar Number',
              ),
            ),
            const SizedBox(height: 30),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: submitKyc,
                    child: Text(s.get('update_kyc')),
                  ),
          ],
        ),
      ),
    );
  }
}
