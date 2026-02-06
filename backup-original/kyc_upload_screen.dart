import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';
import 'education_experience_screen.dart'; // ✅ REQUIRED for back navigation
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

  // 📸 PICK IMAGE (Camera / Gallery)
  Future<void> _pickImage(Function(File) onPicked) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () =>
                  Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () =>
                  Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 70,
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
        'kycStatus': 'under_review',
        'kycSubmittedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      // ✅ FINAL STEP → KYC STATUS ONLY
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
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌐 Language rebuild
    context.watch<LanguageProvider>();
    final s = AppStrings(
      context.read<LanguageProvider>().lang,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(s.kycUpload),
        centerTitle: true,

        // 🔥 SAFE BACK BUTTON (NO BLACK SCREEN)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // ⬅️ EducationExperienceScreen
          },
        ),

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
          Text(
            s.stepOf(3, 5),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          _uploadTile(
            title: s.aadhaarFront,
            subtitle: s.uploadBelow70kb,
            file: aadhaarFront,
            onTap: () =>
                _pickImage((f) => setState(() => aadhaarFront = f)),
          ),
          _uploadTile(
            title: s.aadhaarBack,
            subtitle: s.uploadBelow70kb,
            file: aadhaarBack,
            onTap: () =>
                _pickImage((f) => setState(() => aadhaarBack = f)),
          ),
          _uploadTile(
            title: s.panCard,
            subtitle: s.uploadBelow70kb,
            file: panCard,
            onTap: () =>
                _pickImage((f) => setState(() => panCard = f)),
          ),
          _uploadTile(
            title: s.passportPhoto,
            subtitle: s.uploadBelow70kb,
            file: photo,
            onTap: () =>
                _pickImage((f) => setState(() => photo = f)),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: _loading ? null : _submitKyc,
            child: _loading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(s.submitKyc),
          ),
        ],
      ),
    );
  }

  Widget _uploadTile({
    required String title,
    required String subtitle,
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
        subtitle: Text(file == null ? subtitle : 'Uploaded'),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
