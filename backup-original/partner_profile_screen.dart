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

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadProfile();
      }
    });
  }

  // ================= EMPLOYEE ID GENERATOR =================

  Future<String> _generateEmployeeId() async {
    final year = DateTime.now().year;

    final counterRef = FirebaseFirestore.instance
        .collection('counters')
        .doc('partnerCounter_$year');

    return FirebaseFirestore.instance
        .runTransaction((transaction) async {

      final snapshot = await transaction.get(counterRef);

      int currentNumber = 0;

      if (!snapshot.exists) {
        transaction.set(counterRef, {'currentNumber': 1});
        currentNumber = 1;
      } else {
        currentNumber = snapshot['currentNumber'] ?? 0;
        currentNumber++;
        transaction.update(counterRef, {
          'currentNumber': currentNumber,
        });
      }

      final formatted =
          currentNumber.toString().padLeft(4, '0');

      return "AHRA-$year-$formatted";
    });
  }

  // ================= LOAD PROFILE =================

  Future<void> _loadProfile() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {

      final docRef = FirebaseFirestore.instance
          .collection('partners')
          .doc(user.uid);

      final doc = await docRef.get();

      if (!doc.exists) {

        final newEmpId = await _generateEmployeeId();

        await docRef.set({
          'name': '',
          'email': user.email ?? '',
          'mobile': user.phoneNumber ?? '',
          'empId': newEmpId,
          'pincode': '',
          'location': '',
          'designation': 'Relationship Manager',
          'photoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        return;
      }

    } catch (e) {}
  }

  // ================= SAVE PROFILE =================

  Future<void> _saveProfile() async {

    final user = FirebaseAuth.instance.currentUser!;
    String updatedPhotoUrl = photoUrl;

    if (selectedImage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('partner_photos')
          .child('${user.uid}.jpg');

      await ref.putFile(selectedImage!);
      updatedPhotoUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(user.uid)
        .set({
      'name': name,
      'mobile': mobile,
      'email': email,
      'pincode': pincode,
      'location': location,
      'designation': designation,
      'photoUrl': updatedPhotoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() {
      photoUrl = updatedPhotoUrl;
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
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

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          name = data['name'] ?? '';
          empId = data['empId'] ?? '';
          email = data['email'] ?? '';
          mobile = data['mobile'] ?? '';
          pincode = data['pincode'] ?? '';
          designation =
              data['designation'] ?? 'Relationship Manager';
          photoUrl = data['photoUrl'] ?? '';

          location =
              "${data['village'] ?? ''}, ${data['mandal'] ?? ''}, ${data['district'] ?? ''}";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
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

                  const SizedBox(height: 25),

                  _buildEditableField("Name", name,
                      (val) => name = val),

                  _buildReadOnlyField(
                      "Employee ID", empId),

                  _buildReadOnlyField(
                      "Email", email),

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
          );
        },
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