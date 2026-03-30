import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 NEW IMPORTS
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProcessorSubscriptionScreen extends StatefulWidget {
  final String processorId;
  final String processorName;

  const AddProcessorSubscriptionScreen({
    super.key,
    required this.processorId,
    required this.processorName,
  });

  @override
  State<AddProcessorSubscriptionScreen> createState() =>
      _AddProcessorSubscriptionScreenState();
}

class _AddProcessorSubscriptionScreenState
    extends State<AddProcessorSubscriptionScreen> {

  final _formKey = GlobalKey<FormState>();

  final _monthController = TextEditingController();
  final _txnNoController = TextEditingController();
  final _amountController = TextEditingController();

  // 🔥 NEW screenshot
  File? screenshotFile;

  @override
  void dispose() {
    _monthController.dispose();
    _txnNoController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // =====================================================
  // 🔒 DUPLICATE TRANSACTION CHECK
  // =====================================================
  Future<bool> isDuplicateTxn(String txn) async {

    final query = await FirebaseFirestore.instance
        .collectionGroup('subscriptions')
        .where('transactionNo', isEqualTo: txn)
        .get();

    return query.docs.isNotEmpty;
  }

  // =====================================================
  // 📷 PICK + COMPRESS IMAGE
  // =====================================================
  Future<File?> pickAndCompressImage() async {

    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) return null;

    final compressed =
        await FlutterImageCompress.compressAndGetFile(
      picked.path,
      "${picked.path}_compressed.jpg",
      quality: 30,
    );

    return File(compressed!.path);
  }

  // =====================================================
  // ☁️ UPLOAD SCREENSHOT
  // =====================================================
  Future<String> uploadScreenshot(File image) async {

    final ref = FirebaseStorage.instance
        .ref()
        .child('payment_screenshots')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  // =====================================================
  // 🚀 FINAL SUBMIT METHOD
  // =====================================================
  Future<void> _submit() async {

    if (!_formKey.currentState!.validate()) return;

    if (screenshotFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload payment screenshot"),
        ),
      );
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final processorRef = FirebaseFirestore.instance
          .collection('processors')
          .doc(widget.processorId);

      final int amount =
          int.parse(_amountController.text.trim());

      final txn = _txnNoController.text.trim();

      // 🔒 DUPLICATE CHECK
      if (await isDuplicateTxn(txn)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaction already used"),
          ),
        );
        return;
      }

      // 📷 upload screenshot
      final screenshotUrl =
          await uploadScreenshot(screenshotFile!);

      final now = DateTime.now();

      final endDate = DateTime(
        now.year,
        now.month + 1,
        now.day,
      );

      // ✅ ADD SUBSCRIPTION
      await processorRef.collection('subscriptions').add({

        'partnerId': uid,
        'month': _monthController.text.trim(),
        'transactionNo': txn,
        'amount': amount,

        // 🔥 SCREENSHOT
        'screenshot': screenshotUrl,

        // 🔥 ADMIN FLOW
        'status': 'pending_verification',

        // DATE
        'subscriptionStartDate': Timestamp.fromDate(now),
        'subscriptionEndDate': Timestamp.fromDate(endDate),

        'createdAt': FieldValue.serverTimestamp(),

      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Processor subscription added (Waiting admin approval)'),
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
        title: const Text('Add Processor Subscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // 🔹 Processor Name
              Text(
                widget.processorName,
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

              // 🔹 Transaction
              TextFormField(
                controller: _txnNoController,
                decoration: const InputDecoration(
                  labelText: 'Transaction Number',
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

              const SizedBox(height: 16),

              // 📷 Screenshot
              ElevatedButton(
                onPressed: () async {
                  final img = await pickAndCompressImage();
                  if (img != null) {
                    setState(() {
                      screenshotFile = img;
                    });
                  }
                },
                child: const Text("Upload Screenshot"),
              ),

              const SizedBox(height: 10),

              if (screenshotFile != null)
                Image.file(
                  screenshotFile!,
                  height: 120,
                ),

              const SizedBox(height: 20),

              // 🔹 Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Add Subscription'),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}