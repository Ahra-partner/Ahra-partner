import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  File? passportPhoto;

  bool submitting = false;

  // ================= IMAGE PICKER =================
  Future<File?> _pickImage(ImageSource source) async {
    final XFile? picked =
        await _picker.pickImage(source: source, imageQuality: 60);

    if (picked == null) return null;

    final file = File(picked.path);
    final sizeKB = file.lengthSync() / 1024;

    if (sizeKB > 70) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image must be below 70 KB'),
        ),
      );
      return null;
    }
    return file;
  }

  // ================= BOTTOM SHEET =================
  void _showPickOptions(Function(File) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo (Selfie)'),
                onTap: () async {
                  Navigator.pop(context);
                  final file =
                      await _pickImage(ImageSource.camera);
                  if (file != null) onSelected(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final file =
                      await _pickImage(ImageSource.gallery);
                  if (file != null) onSelected(file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= FIREBASE UPLOAD =================
  Future<String> _uploadFile(File file, String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // ================= SUBMIT KYC =================
  Future<void> _submitKyc() async {
    if (aadhaarFront == null ||
        aadhaarBack == null ||
        panCard == null ||
        passportPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all documents')),
      );
      return;
    }

    setState(() => submitting = true);

    final basePath = 'kyc/${widget.partnerId}';

    final aadhaarFrontUrl =
        await _uploadFile(aadhaarFront!, '$basePath/aadhaar_front.jpg');
    final aadhaarBackUrl =
        await _uploadFile(aadhaarBack!, '$basePath/aadhaar_back.jpg');
    final panUrl =
        await _uploadFile(panCard!, '$basePath/pan.jpg');
    final photoUrl =
        await _uploadFile(passportPhoto!, '$basePath/photo.jpg');

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .set({
      'kyc': {
        'aadhaarFront': aadhaarFrontUrl,
        'aadhaarBack': aadhaarBackUrl,
        'pan': panUrl,
        'photo': photoUrl,
      },
      'kycStatus': 'under_review',
      'step3Completed': true,
      'onboardingStep': 3,
      'kycSubmittedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/kyc-status');
  }

  // ================= UI TILE =================
  Widget _docTile(String title, File? file, Function(File) onSelected) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: const Text('Max 70 KB'),
        trailing: Icon(
          file == null ? Icons.upload : Icons.check_circle,
          color: file == null ? Colors.grey : Colors.green,
        ),
        onTap: () => _showPickOptions(onSelected),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Upload'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Step 3 of 5 – KYC Documents',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            _docTile(
              'Aadhaar Card – Front',
              aadhaarFront,
              (f) => setState(() => aadhaarFront = f),
            ),
            _docTile(
              'Aadhaar Card – Back',
              aadhaarBack,
              (f) => setState(() => aadhaarBack = f),
            ),
            _docTile(
              'PAN Card',
              panCard,
              (f) => setState(() => panCard = f),
            ),
            _docTile(
              'Passport Size Photo',
              passportPhoto,
              (f) => setState(() => passportPhoto = f),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: submitting ? null : _submitKyc,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: submitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit KYC'),
            ),
          ],
        ),
      ),
    );
  }
}
