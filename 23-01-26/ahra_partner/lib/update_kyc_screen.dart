import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'app_strings.dart';
import 'kyc/image_picker_helper.dart';

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
  final panController = TextEditingController();
  final aadhaarController = TextEditingController();

  File? selfie;
  File? aadhaarFront;
  File? aadhaarBack;
  File? panCard;

  bool loading = false;

  @override
  void dispose() {
    panController.dispose();
    aadhaarController.dispose();
    super.dispose();
  }

  /* ================= IMAGE PICKER ================= */

  void _showPicker({required Function(File) onPicked}) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Upload from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final file =
                    await ImagePickerHelper.pickDocumentFromGallery();
                if (file != null) onPicked(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Capture with Camera'),
              onTap: () async {
                Navigator.pop(context);
                final file =
                    await ImagePickerHelper.pickDocumentFromCamera();
                if (file != null) onPicked(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  /* ================= SUBMIT KYC (FINAL – STORAGE + FIRESTORE) ================= */

  Future<void> submitKyc() async {
    if (selfie == null ||
        aadhaarFront == null ||
        aadhaarBack == null ||
        panCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all KYC images')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final storageRef =
          FirebaseStorage.instance.ref('kyc/${widget.partnerId}');

      // Upload files
      final selfieRef = storageRef.child('selfie.jpg');
      final aadhaarFrontRef = storageRef.child('aadhaar_front.jpg');
      final aadhaarBackRef = storageRef.child('aadhaar_back.jpg');
      final panRef = storageRef.child('pan.jpg');

      await selfieRef.putFile(selfie!);
      await aadhaarFrontRef.putFile(aadhaarFront!);
      await aadhaarBackRef.putFile(aadhaarBack!);
      await panRef.putFile(panCard!);

      // Get URLs
      final selfieUrl = await selfieRef.getDownloadURL();
      final aadhaarFrontUrl = await aadhaarFrontRef.getDownloadURL();
      final aadhaarBackUrl = await aadhaarBackRef.getDownloadURL();
      final panUrl = await panRef.getDownloadURL();

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('partners')
          .doc(widget.partnerId)
          .update({
        'pan': panController.text.trim(),
        'aadhaar': aadhaarController.text.trim(),

        'selfieUrl': selfieUrl,
        'aadhaarFrontUrl': aadhaarFrontUrl,
        'aadhaarBackUrl': aadhaarBackUrl,
        'panCardUrl': panUrl,

        'kycStatus': 'pending',
        'kycSubmitted': true,
        'kycSubmittedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KYC submitted. Under review'),
        ),
      );
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final s = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('update_kyc')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: panController,
              decoration: const InputDecoration(labelText: 'PAN Number'),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: aadhaarController,
              decoration: const InputDecoration(labelText: 'Aadhaar Number'),
            ),
            const SizedBox(height: 30),

            _title('Passport Size Photo (Selfie)'),
            _button(
              'Capture Selfie',
              () async {
                final file =
                    await ImagePickerHelper.pickSelfieCamera();
                if (file != null) setState(() => selfie = file);
              },
            ),
            _preview(selfie),

            _title('Aadhaar Front'),
            _button(
              'Upload Aadhaar Front',
              () => _showPicker(
                onPicked: (f) => setState(() => aadhaarFront = f),
              ),
            ),
            _preview(aadhaarFront),

            _title('Aadhaar Back'),
            _button(
              'Upload Aadhaar Back',
              () => _showPicker(
                onPicked: (f) => setState(() => aadhaarBack = f),
              ),
            ),
            _preview(aadhaarBack),

            _title('PAN Card'),
            _button(
              'Upload PAN Card',
              () => _showPicker(
                onPicked: (f) => setState(() => panCard = f),
              ),
            ),
            _preview(panCard),

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

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );

  Widget _button(String label, VoidCallback onTap) => SizedBox(
        width: double.infinity,
        child: OutlinedButton(onPressed: onTap, child: Text(label)),
      );

  Widget _preview(File? file) {
    if (file == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Image.file(file, height: 120, fit: BoxFit.cover),
    );
  }
}
