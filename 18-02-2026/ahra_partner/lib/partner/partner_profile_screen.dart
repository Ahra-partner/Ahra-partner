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

  // ================= UPDATED EMPLOYEE ID GENERATOR =================

  Future<String> _generateEmployeeId() async {

    final year = DateTime.now().year;

    // 🔥 Year wise counter document
    final counterRef = FirebaseFirestore.instance
        .collection('counters')
        .doc('partnerCounter_$year');

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

      // 🔥 4 digit format
      final formatted =
          currentNumber.toString().padLeft(4, '0');

      return "AHRA-$year-$formatted";
    });
  }

  // ================= LOAD PROFILE =================

  Future<void> _loadProfile() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {

      final doc = await FirebaseFirestore.instance
          .collection('partners')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        setState(() => isLoading = false);
        return;
      }

      final data =
          doc.data() as Map<String, dynamic>;

      String currentEmpId =
          data['empId'] ?? '';

      // 🔥 Generate if empty
      if (currentEmpId.isEmpty) {

        currentEmpId = await _generateEmployeeId();

        await FirebaseFirestore.instance
            .collection('partners')
            .doc(user.uid)
            .update({
          'empId': currentEmpId,
        });
      }

      setState(() {
        name = data['name'] ?? '';
        empId = currentEmpId;
        email = user.email ?? '';
        mobile = data['mobile'] ?? '';

        location =
            "${data['village'] ?? ''}, ${data['state'] ?? ''}";

        pincode =
            data['pincode']?.toString() ?? '';

        designation =
            data['designation'] ??
                'Relationship Manager';

        photoUrl = data['photoUrl'] ?? '';
        isLoading = false;
      });

    } catch (e) {
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
      'name': name,
      'mobile': mobile,
      'pincode': pincode,
      'location': location,
      'photoUrl': updatedPhotoUrl,
    });

    if (email != user.email) {
      await user.updateEmail(email);
    }

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
        actions: [
          IconButton(
            icon: Icon(
                isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              selectedImage != null
                                  ? FileImage(selectedImage!)
                                  : photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : null,
                          child: photoUrl.isEmpty &&
                                  selectedImage == null
                              ? const Icon(Icons.person,
                                  size: 60)
                              : null,
                        ),
                        if (isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor:
                                  Colors.green,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (_) => Column(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading:
                                              const Icon(Icons.camera),
                                          title:
                                              const Text('Camera'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickImage(ImageSource.camera);
                                          },
                                        ),
                                        ListTile(
                                          leading:
                                              const Icon(Icons.photo),
                                          title:
                                              const Text('Gallery'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickImage(ImageSource.gallery);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                      ],
                    ),

                    const SizedBox(height: 25),

                    _buildEditableField("Name", name,
                        (val) => name = val),

                    _buildReadOnlyField(
                        "Employee ID", empId),

                    _buildEditableField("Email", email,
                        (val) => email = val),

                    _buildEditableField("Mobile", mobile,
                        (val) => mobile = val),

                    _buildEditableField("Location", location,
                        (val) => location = val),

                    _buildEditableField("Pincode", pincode,
                        (val) => pincode = val),

                    _buildReadOnlyField(
                        "Designation", designation),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEditableField(
      String label,
      String value,
      Function(String) onChanged) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        enabled: isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: (val) =>
            val!.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildReadOnlyField(
      String label,
      String value) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
