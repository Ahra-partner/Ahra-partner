import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';
import 'kyc_status_screen.dart';
import 'education_experience_screen.dart';

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

  /// 🔥 COMPRESS IMAGE TO MAX 150KB
  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    int quality = 85;
    File? result;

    do {
      final compressed = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
      );

      if (compressed == null) break;

      result = File(compressed.path);

      final sizeKB = result.lengthSync() / 1024;

      if (sizeKB <= 150 || quality <= 30) {
        break;
      }

      quality -= 10;
    } while (true);

    return result ?? file;
  }

  // 📸 PICK IMAGE + AUTO COMPRESS
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

    final XFile? picked = await _picker.pickImage(
      source: source,
    );

    if (picked == null) return;

    File imageFile = File(picked.path);

    // 🔥 AUTO COMPRESS
    imageFile = await _compressImage(imageFile);

    final finalSize = imageFile.lengthSync() / 1024;
    debugPrint("Final Image Size: ${finalSize.toStringAsFixed(2)} KB");

    onPicked(imageFile);
  }

  bool get _isValid =>
      aadhaarFront != null &&
      aadhaarBack != null &&
      panCard != null &&
      photo != null;

  Future<String> _uploadImage(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

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
      final aadhaarFrontUrl = await _uploadImage(
        aadhaarFront!,
        'kyc/${widget.partnerId}/aadhaar_front.jpg',
      );

      final aadhaarBackUrl = await _uploadImage(
        aadhaarBack!,
        'kyc/${widget.partnerId}/aadhaar_back.jpg',
      );

      final panCardUrl = await _uploadImage(
        panCard!,
        'kyc/${widget.partnerId}/pan_card.jpg',
      );

      final photoUrl = await _uploadImage(
        photo!,
        'kyc/${widget.partnerId}/photo.jpg',
      );

      await FirebaseFirestore.instance
          .collection('partners')
          .doc(widget.partnerId)
          .set({
        'aadhaarFrontUrl': aadhaarFrontUrl,
        'aadhaarBackUrl': aadhaarBackUrl,
        'panCardUrl': panCardUrl,
        'photoUrl': photoUrl,
        'kycSubmitted': true,
        'kycStatus': 'under_review',
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final s = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.kycUpload),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => EducationExperienceScreen(
                    partnerId: widget.partnerId,
                  ),
                ),
              );
            }
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
            subtitle: "Upload image (≤ 150 KB)",
            file: aadhaarFront,
            onTap: () =>
                _pickImage((f) => setState(() => aadhaarFront = f)),
          ),
          _uploadTile(
            title: s.aadhaarBack,
            subtitle: "Upload image (≤ 150 KB)",
            file: aadhaarBack,
            onTap: () =>
                _pickImage((f) => setState(() => aadhaarBack = f)),
          ),
          _uploadTile(
            title: s.panCard,
            subtitle: "Upload image (≤ 150 KB)",
            file: panCard,
            onTap: () =>
                _pickImage((f) => setState(() => panCard = f)),
          ),
          _uploadTile(
            title: s.passportPhoto,
            subtitle: "Upload image (≤ 150 KB)",
            file: photo,
            onTap: () =>
                _pickImage((f) => setState(() => photo = f)),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: _loading ? null : _submitKyc,
            child: _loading
                ? const CircularProgressIndicator(
                    color: Colors.white)
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