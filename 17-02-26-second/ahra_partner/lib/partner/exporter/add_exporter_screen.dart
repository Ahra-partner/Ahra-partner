import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AddExporterScreen extends StatefulWidget {
  const AddExporterScreen({super.key});

  @override
  State<AddExporterScreen> createState() =>
      _AddExporterScreenState();
}

class _AddExporterScreenState
    extends State<AddExporterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _companyName = TextEditingController();
  final _gstNumber = TextEditingController();
  final _pincode = TextEditingController();
  final _postOffice = TextEditingController();
  final _mandal = TextEditingController();
  final _district = TextEditingController();
  final _state = TextEditingController();
  final _amount = TextEditingController();
  final _referenceNo = TextEditingController();

  bool _isLoadingPincode = false;

  List<Map<String, dynamic>> selectedProducts = [];

  final List<String> productOptions = [
    "Rice Export",
    "Wheat Export",
    "Maize Export",
    "Vegetables Export",
    "Fruits Export",
    "Pulses Export",
    "Oil Seeds Export",
    "Spices Export",
    "Millets Export",
    "Groundnut Export",
    "Other",
  ];

  final List<String> units = ["Kg", "Quintal", "Ton", "Containers"];

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _fetchPincodeDetails(String pincode) async {
    if (pincode.length != 6) return;

    setState(() => _isLoadingPincode = true);

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.postalpincode.in/pincode/$pincode'),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedProducts.isEmpty) {
      _showMsg("Please add at least one product");
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

      final exporterRef =
          FirebaseFirestore.instance
              .collection('exporters')
              .doc(mobile);

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

      // 🔥 SAVE EXPORTER
      await exporterRef.set({
        'partnerId': uid,
        'name': _name.text.trim(),
        'mobile': mobile,
        'companyName': _companyName.text.trim(),
        'gstNumber': _gstNumber.text.trim(),
        'pincode': _pincode.text.trim(),
        'village': _postOffice.text.trim(),
        'postOffice': _postOffice.text.trim(),
        'mandal': _mandal.text.trim(),
        'district': _district.text.trim(),
        'state': _state.text.trim(),
        'category': 'exporter',
        'productsExported': finalProducts,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 🔥 SAVE SUBSCRIPTION
      await exporterRef
          .collection('subscriptions')
          .doc(monthId)
          .set({
        'partnerId': uid,
        'month': monthId,
        'amount': amount,
        'referenceNumber': _referenceNo.text.trim(),
        'products': finalProducts,
        'status': 'submitted',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showMsg("Exporter Saved Successfully");
      Navigator.pop(context);
    } catch (e) {
      _showMsg("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Add Exporter")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              _field(_name, "Exporter Name"),
              _field(_mobile, "Mobile Number",
                  number: true),
              _field(_companyName, "Company Name"),
              _field(_gstNumber,
                  "GST Number (Optional)"),
              _pincodeField(),
              _readOnlyField(
                  _postOffice, "Post Office"),
              _readOnlyField(_mandal, "Mandal"),
              _readOnlyField(
                  _district, "District"),
              _readOnlyField(_state, "State"),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Products for Export",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),

              const SizedBox(height: 10),

              ...selectedProducts
                  .asMap()
                  .entries
                  .map((entry) {
                int index = entry.key;
                var product = entry.value;

                return Card(
                  margin:
                      const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Align(
                          alignment:
                              Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(
                                Icons.delete,
                                color: Colors.red),
                            onPressed: () =>
                                _removeProduct(index),
                          ),
                        ),

                        DropdownButtonFormField(
                          value: product["name"],
                          items: productOptions
                              .map((e) =>
                                  DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedProducts[index]
                                      ["name"] =
                                  val;
                            });
                          },
                          decoration:
                              const InputDecoration(
                                  labelText:
                                      "Product"),
                        ),

                        if (product["name"] == "Other")
                          TextFormField(
                            decoration:
                                const InputDecoration(
                                    labelText:
                                        "Enter Product Name"),
                            onChanged: (val) {
                              selectedProducts[index]
                                      ["customName"] =
                                  val;
                            },
                          ),

                        TextFormField(
                          decoration:
                              const InputDecoration(
                                  labelText:
                                      "Quantity"),
                          keyboardType:
                              TextInputType.number,
                          onChanged: (val) {
                            selectedProducts[index]
                                    ["quantity"] =
                                val;
                          },
                        ),

                        DropdownButtonFormField(
                          value: product["unit"],
                          items: units
                              .map((e) =>
                                  DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedProducts[index]
                                      ["unit"] =
                                  val;
                            });
                          },
                          decoration:
                              const InputDecoration(
                                  labelText:
                                      "Unit"),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              ElevatedButton(
                onPressed: _addProductField,
                child: const Text("Add Product"),
              ),

              const SizedBox(height: 20),

              _field(_amount,
                  "Subscription Amount",
                  number: true),
              _field(_referenceNo,
                  "Reference Number"),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submit,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pincodeField() {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _pincode,
        keyboardType:
            TextInputType.number,
        maxLength: 6,
        onChanged: (value) {
          if (value.length == 6) {
            _fetchPincodeDetails(value);
          }
        },
        decoration:
            const InputDecoration(
          labelText: "Pincode",
          border:
              OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController c,
      String label,
      {bool number = false}) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: number
            ? TextInputType.number
            : TextInputType.text,
        validator: (v) =>
            v == null || v.trim().isEmpty
                ? "Required"
                : null,
        decoration: InputDecoration(
          labelText: label,
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _readOnlyField(
      TextEditingController c,
      String label) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }
}
