import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
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
  bool _profileLoading = false;
  String name = '';
  String empId = '';
  String email = '';
  String mobile = '';
  String location = '';
  String pincode = '';
  String designation = 'Relationship Manager';
  String photoUrl = '';

  File? selectedImage;
  Uint8List? webImage;

  Widget buildProfileImage() {

    if (webImage != null) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(60),
        child: Image.memory(
          webImage!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    if (selectedImage != null) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(60),
        child: Image.file(
          selectedImage!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    if (photoUrl.trim().isNotEmpty) {

      print(
        "PROFILE PHOTO = ${photoUrl.trim()}",
      );

      return ClipRRect(
        borderRadius:
            BorderRadius.circular(60),

        child: Image.network(
          photoUrl.trim(),

          width: 120,
          height: 120,
          fit: BoxFit.cover,

          key: UniqueKey(),

          frameBuilder: (
            context,
            child,
            frame,
            wasSynchronouslyLoaded,
          ) {

            print(
              "FRAME = $frame",
            );

            return child;
          },

          loadingBuilder:
              (
            context,
            child,
            progress,
          ) {

            print(
              "LOADING = $progress",
            );

            return child;
          },

          errorBuilder:
              (_, error, __) {

            print(error);

            return const Icon(
              Icons.person,
              size: 60,
            );
          },
        ),
      );
    }

    return const Icon(
      Icons.person,
      size: 60,
    );
  }

  Future<void> pickImage() async {

    final picked =
        await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) return;

    if (kIsWeb) {
      webImage =
          await picked.readAsBytes();
    } else {
      selectedImage =
          File(picked.path);
    }

    setState(() {});
  }

  @override
  void initState() {

    super.initState();

    _loadProfile();

    FirebaseAuth.instance
        .authStateChanges()
        .listen((user) {

      if (user != null) {
        _loadProfile();
      }
    });
  }

  Future<String>
      _generateEmployeeId() async {

    final year =
        DateTime.now().year;

    final counterRef =
        FirebaseFirestore.instance
            .collection(
                'counters')
            .doc(
                'partnerCounter_$year');

    return FirebaseFirestore
        .instance
        .runTransaction(
            (transaction) async {

      final snapshot =
          await transaction.get(
              counterRef);

      int currentNumber = 0;

      if (!snapshot.exists) {

        transaction.set(
            counterRef,
            {
              'currentNumber':
                  1
            });

        currentNumber = 1;

      } else {

        currentNumber =
            snapshot[
                    'currentNumber'] ??
                0;

        currentNumber++;

        transaction.update(
          counterRef,
          {
            'currentNumber':
                currentNumber,
          },
        );
      }

      final formatted =
          currentNumber
              .toString()
              .padLeft(
                  4, '0');

      return "AHRA-$year-$formatted";
    });
  }

Future<void> _loadProfile() async {

  if (_profileLoading) return;

  _profileLoading = true;

  try {

    final user =
        FirebaseAuth
            .instance
            .currentUser;

    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance
            .collection('partners')
            .doc(user.uid);

    final doc =
        await docRef.get();

    Map<String, dynamic> data = {};

    if (!doc.exists) {

      final newEmpId =
          await _generateEmployeeId();

      await docRef.set({

        'name': '',
        'email': user.email ?? '',
        'mobile':
            user.phoneNumber ?? '',
        'empId': newEmpId,
        'pincode': '',
        'location': '',
        'designation':
            'Relationship Manager',
        'photoUrl': '',
        'createdAt':
            FieldValue.serverTimestamp(),

      });

      setState(() {
        empId = newEmpId;
      });

      return;
    }

    data =
        doc.data()
            as Map<String, dynamic>;

    String currentEmpId =
        data['empId'] ?? '';

    if (currentEmpId.isEmpty) {

      currentEmpId =
          await _generateEmployeeId();

      await docRef.set(
        {
          'empId': currentEmpId
        },
        SetOptions(
          merge: true,
        ),
      );
    }

    setState(() {
      empId = currentEmpId;
    });

  } catch (e) {

    print(
      "Profile load error: $e",
    );

  } finally {

    _profileLoading = false;
  }
}

  Future<void>
      _saveProfile() async {

    final user =
        FirebaseAuth
            .instance
            .currentUser!;

    String updatedPhotoUrl =
        photoUrl;

    if (selectedImage != null ||
        webImage != null) {

      final ref =
          FirebaseStorage
              .instance
              .ref()
              .child(
                  'partner_photos')
              .child(
                  '${user.uid}.jpg');

      if (kIsWeb &&
          webImage !=
              null) {

        await ref.putData(
          webImage!,
          SettableMetadata(
            contentType:
                'image/jpeg',
          ),
        );

      } else {

        await ref.putFile(
          selectedImage!,
        );
      }

      updatedPhotoUrl =
          await ref
              .getDownloadURL();
    }

    await FirebaseFirestore
        .instance
        .collection(
            'partners')
        .doc(user.uid)
        .set({

      'name': name,
      'mobile': mobile,
      'email': email,
      'pincode': pincode,
      'location':
          location,
      'designation':
          designation,
      'photoUrl':
          updatedPhotoUrl,

      'updatedAt':
          FieldValue
              .serverTimestamp()

    }, SetOptions(
        merge: true));

    setState(() {

      photoUrl =
          updatedPhotoUrl;

      isEditing =
          false;
    });

    ScaffoldMessenger.of(
            context)
        .showSnackBar(

      const SnackBar(
        content: Text(
            'Profile updated'),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    final user =
        FirebaseAuth
            .instance
            .currentUser;

    return Scaffold(

      appBar: AppBar(

        title:
            const Text(
                "My Profile"),

        centerTitle:
            true,

        actions: [

          IconButton(

            icon: Icon(
              isEditing
                  ? Icons.save
                  : Icons.edit,
            ),

            onPressed: () {

              if (isEditing) {

                _saveProfile();

              } else {

                setState(() {

                  isEditing =
                      true;

                });
              }
            },
          )
        ],
      ),

      body:
          StreamBuilder<
              DocumentSnapshot>(

        stream:
            FirebaseFirestore
                .instance
                .collection(
                    'partners')
                .doc(
                    user!.uid)
                .snapshots(),

        builder: (
          context,
          snapshot,
        ) {

          if (!snapshot
              .hasData) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!
                      .data()
                  as Map<String,
                      dynamic>;

          if (name.isEmpty) {
            name =
                data['name'] ??
                    '';
          }

          if (empId.isEmpty) {
            empId =
                data['empId'] ??
                    '';
          }

          if (email.isEmpty) {
            email =
                data['email'] ??
                    '';
          }

          if (mobile.isEmpty) {
            mobile =
                data['mobile'] ??
                    '';
          }

          if (pincode
              .isEmpty) {
            pincode =
                data['pincode'] ??
                    '';
          }


          designation =
              data['designation'] ??
                  'Relationship Manager';

          final firestorePhotoUrl =
              data['photoUrl'] ??
                  '';

          if (photoUrl !=
                  firestorePhotoUrl &&
              firestorePhotoUrl
                  .isNotEmpty) {

            WidgetsBinding
                .instance
                .addPostFrameCallback(
                    (_) {

              if (mounted) {

                setState(() {

                  photoUrl =
                      firestorePhotoUrl;

                });
              }
            });
          }

          location =
              "${data['village'] ?? ''}, ${data['mandal'] ?? ''}, ${data['district'] ?? ''}";

          return SingleChildScrollView(

            padding:
                const EdgeInsets
                    .all(16),

            child: Form(

              key: _formKey,

              child: Column(

                children: [

Container(
  width: 120,
  height: 120,
  clipBehavior: Clip.hardEdge,
  decoration: const BoxDecoration(
    shape: BoxShape.circle,
  ),
  child: Image.network(
    data['photoUrl'] ?? '',
    fit: BoxFit.cover,
    errorBuilder: (
      context,
      error,
      stack,
    ) {
      print("ERROR: $error");

      return const Icon(
        Icons.person,
        size: 60,
      );
    },
  ),
),

                  const SizedBox(
                      height:
                          10),

                  SelectableText(
                    photoUrl,
                    style:
                        const TextStyle(
                      fontSize:
                          10,
                      color:
                          Colors.blue,
                    ),
                  ),

                  const SizedBox(
                      height:
                          25),

                  _buildEditableField(
                      "Name",
                      name,
                      (val) =>
                          name =
                              val),

                  _buildReadOnlyField(
                      "Employee ID",
                      empId),

                  _buildReadOnlyField(
                      "Email",
                      email),

                  _buildEditableField(
                      "Mobile",
                      mobile,
                      (val) =>
                          mobile =
                              val),

                  _buildEditableField(
                      "Location",
                      location,
                      (val) =>
                          location =
                              val),

                  _buildEditableField(
                      "Pincode",
                      pincode,
                      (val) =>
                          pincode =
                              val),

                  _buildReadOnlyField(
                      "Designation",
                      designation),
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
      Function(String)
          onChanged) {

    return Padding(
      padding:
          const EdgeInsets.only(
              bottom: 16),

      child:
          TextFormField(

        initialValue:
            value,

        enabled:
            isEditing,

        decoration:
            InputDecoration(

          labelText:
              label,

          border:
              const OutlineInputBorder(),
        ),

        onChanged:
            onChanged,
      ),
    );
  }

  Widget _buildReadOnlyField(
      String label,
      String value) {

    return Padding(
      padding:
          const EdgeInsets.only(
              bottom: 16),

      child:
          TextFormField(

        initialValue:
            value,

        enabled:
            false,

        decoration:
            InputDecoration(

          labelText:
              label,

          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }
}