import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../language_screen.dart';
import 'kyc_status_screen.dart';

class KycUploadScreen extends StatefulWidget {
  final String partnerId;

  const KycUploadScreen({
    super.key,
    required this.partnerId,
  });

  @override
  State<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends State<KycUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  File? aadhaarFront;
  File? aadhaarBack;
  File? panCard;
  File? photo;

  bool _loading = false;

  /// 🔹 PICK IMAGE (Camera / Gallery)
  Future<void> _pickImage(
    Function(File) onPicked,
  ) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // 🔥 reduce size
    );

    if (file == null) return;

    final imageFile = File(file.path);
    final sizeKB = imageFile.lengthSync() / 1024;

    if (sizeKB > 70) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image must be below 70 KB'),
        ),
      );
      return;
    }

    onPicked(imageFile);
  }

  bool get _isValid =>
      aadhaarFront != null &&
      aadhaarBack != null &&
      panCard != null &&
      photo != null;

  Future<void> _submitKyc() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('partners')
          .doc(widget.partnerId)
          .set({
        'kycSubmitted': true,
        'kycStatus': 'under_review', // 🔥 ADMIN will review
        'kycSubmittedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => KycStatusScreen(
            partnerId: widget.partnerId,
            status: 'under_review',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Upload'),
        centerTitle: true,

        // 🌐 LANGUAGE BUTTON
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) =>
                    const LanguageScreen(fromSettings: true),
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Step 3 of 5',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          _uploadTile(
            title: 'Aadhaar Front',
            file: aadhaarFront,
            onTap: () => _pickImage(
              (f) => setState(() => aadhaarFront = f),
            ),
          ),
          _uploadTile(
            title: 'Aadhaar Back',
            file: aadhaarBack,
            onTap: () => _pickImage(
              (f) => setState(() => aadhaarBack = f),
            ),
          ),
          _uploadTile(
            title: 'PAN Card',
            file: panCard,
            onTap: () => _pickImage(
              (f) => setState(() => panCard = f),
            ),
          ),
          _uploadTile(
            title: 'Passport Size Photo',
            file: photo,
            onTap: () => _pickImage(
              (f) => setState(() => photo = f),
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: _loading ? null : _submitKyc,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _loading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Text('Submit KYC'),
          ),
        ],
      ),
    );
  }

  Widget _uploadTile({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          file == null ? Icons.upload_file : Icons.check_circle,
          color: file == null ? Colors.grey : Colors.green,
        ),
        title: Text(title),
        subtitle: Text(
          file == null ? 'Upload image (≤ 70 KB)' : 'Uploaded',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
