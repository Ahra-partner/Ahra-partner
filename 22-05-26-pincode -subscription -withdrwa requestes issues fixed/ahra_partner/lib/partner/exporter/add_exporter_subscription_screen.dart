import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 NEW IMPORTS
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddExporterSubscriptionScreen extends StatefulWidget {
  final String exporterId;
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
  final _dateController = TextEditingController(
  text:
      "${DateTime.now().day.toString().padLeft(2, '0')}/"
      "${DateTime.now().month.toString().padLeft(2, '0')}/"
      "${DateTime.now().year}",
);
  // 🔥 NEW screenshot file
  File? screenshotFile;
  Uint8List? screenshotBytes;
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

  final exporterSubs = await FirebaseFirestore.instance
      .collection('exporters')
      .doc(widget.exporterId)
      .collection('subscriptions')
      .where('transactionNo', isEqualTo: txn)
      .get();

  return exporterSubs.docs.isNotEmpty;
}

  // =====================================================
  // 📷 PICK + COMPRESS IMAGE
  // =====================================================
Future<void> pickAndCompressImage() async {

  final picker = ImagePicker();

  final picked = await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (picked == null) return;

  if (kIsWeb) {

    final bytes = await picked.readAsBytes();

    setState(() {
      screenshotBytes = bytes;
    });

    return;
  }

  final compressed =
      await FlutterImageCompress.compressAndGetFile(
    picked.path,
    "${picked.path}_compressed.jpg",
    quality: 30,
  );

  if (compressed == null) return;

  setState(() {
    screenshotFile = File(compressed.path);
  });
}

  // =====================================================
  // ☁️ UPLOAD SCREENSHOT
  // =====================================================
Future<String> uploadScreenshot() async {

  final ref = FirebaseStorage.instance
      .ref()
      .child('payment_screenshots')
      .child(
          '${DateTime.now().millisecondsSinceEpoch}.jpg');

  UploadTask uploadTask;

  if (kIsWeb && screenshotBytes != null) {

    uploadTask = ref.putData(
      screenshotBytes!,
      SettableMetadata(
        contentType: 'image/jpeg',
      ),
    );

  } else {

    uploadTask = ref.putFile(
      screenshotFile!,
      SettableMetadata(
        contentType: 'image/jpeg',
      ),
    );
  }

  await uploadTask;

  return await ref.getDownloadURL();
}

  // =====================================================
  // 🚀 FINAL SUBMIT METHOD
  // =====================================================
  Future<void> _submit() async {

    if (!_formKey.currentState!.validate()) return;

    // 🔥 SCREENSHOT VALIDATION
    if (screenshotFile == null &&
    screenshotBytes == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload payment screenshot"),
        ),
      );

      return;
    }

    try {

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final exporterRef = FirebaseFirestore.instance
          .collection('exporters')
          .doc(widget.exporterId);

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

      // 📷 Upload screenshot
      final screenshotUrl =
          await uploadScreenshot();

      // DATE LOGIC
      final now = DateTime.now();

      final endDate = DateTime(
        now.year,
        now.month + 1,
        now.day,
      );

      // ✅ ADD SUBSCRIPTION
      await exporterRef.collection('subscriptions').add({

        'partnerId': uid,

        'month': _monthController.text.trim(),

        'transactionNo': txn,

        'amount': amount,
        'paymentDate': _dateController.text.trim(),
        // 🔥 SCREENSHOT
        'screenshot': screenshotUrl,

        // 🔥 ADMIN VERIFICATION
        'status': 'pending_verification',

        // DATE FIELDS
        'subscriptionStartDate': Timestamp.fromDate(now),
        'subscriptionEndDate': Timestamp.fromDate(endDate),

        'createdAt': FieldValue.serverTimestamp(),

      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Exporter subscription added (Waiting admin approval)'),
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
        title: const Text('Add Exporter Subscription'),
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
TextFormField(
  controller: _dateController,
  readOnly: true,
  decoration: const InputDecoration(
    labelText: 'Payment Date',
    border: OutlineInputBorder(),
  ),
),
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

              const SizedBox(height: 16),

              // 📷 SCREENSHOT BUTTON
              ElevatedButton(
  onPressed: () async {

    await pickAndCompressImage();

  },
  child: const Text("Upload Screenshot"),
),

              const SizedBox(height: 10),

              if (kIsWeb && screenshotBytes != null)
  Image.memory(
    screenshotBytes!,
    height: 120,
  ),

if (!kIsWeb && screenshotFile != null)
  Image.file(
    screenshotFile!,
    height: 120,
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