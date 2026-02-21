import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PartnerProfileScreen extends StatefulWidget {
  const PartnerProfileScreen({super.key});

  @override
  State<PartnerProfileScreen> createState() =>
      _PartnerProfileScreenState();
}

class _PartnerProfileScreenState
    extends State<PartnerProfileScreen> {

  final _formKey = GlobalKey<FormState>();

  bool isEditing = false;
  bool isLoading = true;

  String name = '';
  String empId = '';
  String email = '';
  String mobile = '';
  String location = '';
  String pincode = '';
  String designation = 'Relationship Manager';
  String photoUrl = '';

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ================= EMPLOYEE ID GENERATOR =================

  Future<String> _generateEmployeeId() async {

    final year = DateTime.now().year;

    final counterRef = FirebaseFirestore.instance
        .collection('counters')
        .doc('partnerCounter');

    return FirebaseFirestore.instance
        .runTransaction((transaction) async {

      final snapshot = await transaction.get(counterRef);

      int currentNumber = 0;

      if (!snapshot.exists) {
        transaction.set(counterRef, {
          'currentNumber': 1,
        });
        currentNumber = 1;
      } else {
        currentNumber = snapshot['currentNumber'] ?? 0;
        currentNumber++;
        transaction.update(counterRef, {
          'currentNumber': currentNumber,
        });
      }

      final formatted =
          currentNumber.toString().padLeft(6, '0');

      return "AHRA-$year-$formatted";
    });
  }

  // ================= LOAD PROFILE WITH FULL DEBUG =================

  Future<void> _loadProfile() async {

    print("🔥 Firebase App Name: ${FirebaseFirestore.instance.app.name}");
    print("🔥 Project ID: ${FirebaseFirestore.instance.app.options.projectId}");

    final user = FirebaseAuth.instance.currentUser;

    print("👤 Logged UID: ${user?.uid}");

    if (user == null) {
      print("❌ User is NULL");
      setState(() => isLoading = false);
      return;
    }

    try {

      final doc = await FirebaseFirestore.instance
          .collection('partners')
          .doc(user.uid)
          .get();

      print("📄 Document exists: ${doc.exists}");
      print("📄 Data: ${doc.data()}");

      if (!doc.exists) {
        print("❌ Partner document NOT found");
        setState(() => isLoading = false);
        return;
      }

      final data =
          doc.data() as Map<String, dynamic>;

      String currentEmpId =
          data['empId'] ?? '';

      // 🔥 Generate Employee ID if missing
      if (currentEmpId.isEmpty) {

        print("⚡ Generating Employee ID...");

        currentEmpId = await _generateEmployeeId();

        await FirebaseFirestore.instance
            .collection('partners')
            .doc(user.uid)
            .update({
          'empId': currentEmpId,
        });

        print("✅ Generated Employee ID: $currentEmpId");
      }

      setState(() {
        name = data['name'] ?? '';
        empId = currentEmpId;
        email = user.email ?? '';
        mobile = data['mobile'] ?? '';
        location = data['location'] ?? '';
        pincode = data['pincode'] ?? '';
        designation =
            data['designation'] ?? 'Relationship Manager';
        photoUrl = data['photoUrl'] ?? '';
        isLoading = false;
      });

      print("✅ Profile loaded successfully");

    } catch (e) {
      print("❌ Error loading profile: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= IMAGE PICK =================

  Future<void> _pickImage(ImageSource source) async {
    final picked =
        await ImagePicker().pickImage(source: source);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<String> _uploadImage(File file) async {

    final user = FirebaseAuth.instance.currentUser!;

    final ref = FirebaseStorage.instance
        .ref()
        .child('partner_photos')
        .child('${user.uid}.jpg');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // ================= SAVE PROFILE =================

  Future<void> _saveProfile() async {

    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser!;
    String updatedPhotoUrl = photoUrl;

    if (selectedImage != null) {
      updatedPhotoUrl =
          await _uploadImage(selectedImage!);
    }

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(user.uid)
        .update({
      'location': location,
      'pincode': pincode,
      'photoUrl': updatedPhotoUrl,
    });

    setState(() {
      photoUrl = updatedPhotoUrl;
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        selectedImage != null
                            ? FileImage(selectedImage!)
                            : photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                    as ImageProvider
                                : null,
                    child: photoUrl.isEmpty &&
                            selectedImage == null
                        ? const Icon(Icons.person,
                            size: 60)
                        : null,
                  ),

                  const SizedBox(height: 20),

                  _buildField("Name", name),
                  _buildField("Employee ID", empId),
                  _buildField("Email", email),
                  _buildField("Mobile", mobile),
                  _buildField("Location", location),
                  _buildField("Pincode", pincode),
                  _buildField("Designation", designation),
                ],
              ),
            ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
