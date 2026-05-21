import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../language_provider.dart';
import '../../language_screen.dart';
import '../../app_strings.dart';

class AddFarmerScreen extends StatefulWidget {
  const AddFarmerScreen({super.key});

  @override
  State<AddFarmerScreen> createState() => _AddFarmerScreenState();
}

class _AddFarmerScreenState extends State<AddFarmerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _village = TextEditingController();
  final _pincode = TextEditingController();
  final _postOffice = TextEditingController();
  final _mandal = TextEditingController();
  final _district = TextEditingController();
  final _state = TextEditingController();
  final _amount = TextEditingController();
  final _referenceNo = TextEditingController();

  bool _isLoadingPincode = false;
  List<Map<String, dynamic>> selectedProducts = [];

  File? screenshotFile;
  Uint8List? screenshotBytes;
  final List<String> productOptions = [
    "Rice","Wheat","Maize","Vegetables","Fruits",
    "Pulses","Oil Seeds","Spices","Millets",
    "Groundnut","Other",
  ];

  final List<String> units = ["Kg", "Quintal", "Ton", "Bags"];

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= IMAGE =================

Future<void> pickAndCompressImage() async {
  final picked = await ImagePicker().pickImage(
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

  // ================= PINCODE =================

  Future<void> _fetchPincodeDetails(String pincode) async {
    if (pincode.length != 6) return;

    setState(() => _isLoadingPincode = true);

    try {
      final response = await http.get(
        Uri.parse('https://api.postalpincode.in/pincode/$pincode'),
      );

      final data = json.decode(response.body);

      if (data[0]['Status'] == 'Success') {
        final postOffice = data[0]['PostOffice'][0];

        setState(() {
          _postOffice.text = postOffice['Name'] ?? '';
          _mandal.text =
              postOffice['Block'] ?? postOffice['Taluk'] ?? '';
          _district.text = postOffice['District'] ?? '';
          _state.text = postOffice['State'] ?? '';
        });
      }
    } catch (_) {}

    setState(() => _isLoadingPincode = false);
  }

  void _addProductField() {
    setState(() {
      selectedProducts.add({
        "name": null,
        "customName": "",
        "quantity": "",
        "unit": "Kg",
      });
    });
  }

  void _removeProduct(int index) {
    setState(() {
      selectedProducts.removeAt(index);
    });
  }

  // ================= SUBMIT =================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedProducts.isEmpty) {
      _showMsg("Please add at least one product");
      return;
    }

    if (screenshotFile == null &&
    screenshotBytes == null) {
      _showMsg("Please upload payment screenshot");
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;
      final mobile = _mobile.text.trim();

      if (mobile.length != 10) {
        _showMsg("Mobile number must be 10 digits");
        return;
      }

      final int amount =
          int.tryParse(_amount.text.trim()) ?? 0;

      final now = DateTime.now();
      final monthId =
          "${now.year}-${now.month.toString().padLeft(2, '0')}";

      final farmerRef =
          FirebaseFirestore.instance.collection('farmers').doc(mobile);

      List<Map<String, dynamic>> finalProducts =
          selectedProducts.map((p) {
        return {
          "name": p["name"] == "Other"
              ? p["customName"]
              : p["name"],
          "quantity": int.tryParse(p["quantity"]) ?? 0,
          "unit": p["unit"],
        };
      }).toList();

final screenshotUrl =
    await uploadScreenshot();

      // ================= ADMIN REQUEST =================
      await FirebaseFirestore.instance
          .collection('admin_requests')
          .add({
        'farmerId': mobile,
        'partnerId': uid,
        'amount': amount,
        'transactionNo': _referenceNo.text.trim(),
        'screenshot': screenshotUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ================= FARMER =================
      await farmerRef.set({
        'partnerId': uid,
        'farmerName': _name.text.trim(),
        'mobile': mobile,
        'village': _village.text.trim(),
        'pincode': _pincode.text.trim(),
        'postOffice': _postOffice.text.trim(),
        'mandal': _mandal.text.trim(),
        'district': _district.text.trim(),
        'state': _state.text.trim(),
        'category': 'farmer',
        'products': finalProducts,
        'status': 'active',
        'subscriptionAmount': amount,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ================= SUBSCRIPTION =================
      await farmerRef
          .collection('subscriptions')
          .doc(monthId)
          .set({
        'partnerId': uid,
        'month': monthId,
        'amount': amount,
        'transactionNo': _referenceNo.text.trim(),
        'products': finalProducts,
        'screenshot': screenshotUrl,
        'status': 'pending_verification',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showMsg("Farmer Saved Successfully");
      Navigator.pop(context);

    } catch (e) {
      _showMsg("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final t = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.addFarmer),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) =>
                    LanguageScreen(fromSettings: true),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              _field(_name, t.farmerName),
              _field(_mobile, t.mobileNumber, number: true),
              _field(_village, t.village),
              _pincodeField(t),
              _readOnlyField(_postOffice, t.postOffice),
              _readOnlyField(_mandal, t.mandal),
              _readOnlyField(_district, t.district),
              _readOnlyField(_state, t.state),

              const SizedBox(height: 20),

              ...selectedProducts.asMap().entries.map((entry) {
                int index = entry.key;
                var product = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [

                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () =>
                                _removeProduct(index),
                          ),
                        ),

                        DropdownButtonFormField(
                          value: product["name"],
                          items: productOptions
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedProducts[index]["name"] = val;
                            });
                          },
                          decoration: InputDecoration(labelText: t.product),
                        ),

                        TextFormField(
                          decoration: InputDecoration(labelText: t.quantity),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            selectedProducts[index]["quantity"] = val;
                          },
                        ),

                        DropdownButtonFormField(
                          value: product["unit"],
                          items: units
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedProducts[index]["unit"] = val;
                            });
                          },
                          decoration:
                              InputDecoration(labelText: t.quantityUnit),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              ElevatedButton(
                onPressed: _addProductField,
                child: Text(t.addProduct),
              ),

              const SizedBox(height: 20),

              _field(_amount, t.platformAmount, number: true),
              _field(_referenceNo, t.referenceNumber),

              const SizedBox(height: 10),

ElevatedButton(
  onPressed: () async {
    await pickAndCompressImage();
  },
                child: const Text("Upload Payment Screenshot"),
              ),

if (kIsWeb && screenshotBytes != null) ...[
  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Image.memory(
      screenshotBytes!,
      height: 120,
    ),
  ),
] else if (screenshotFile != null) ...[
  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Image.file(
      screenshotFile!,
      height: 120,
    ),
  ),
],

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submit,
                child: Text(t.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pincodeField(AppStrings t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _pincode,
        keyboardType: TextInputType.number,
        maxLength: 6,
        onChanged: (value) {
          if (value.length == 6) {
            _fetchPincodeDetails(value);
          }
        },
        decoration: InputDecoration(
          labelText: t.pincode,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType:
            number ? TextInputType.number : TextInputType.text,
        validator: (v) =>
            v == null || v.trim().isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _readOnlyField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}