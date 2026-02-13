import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';

class AddFarmerScreen extends StatefulWidget {
  final String partnerId;

  const AddFarmerScreen({super.key, required this.partnerId});

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

  final _quantity = TextEditingController();
  final _txnNo = TextEditingController();
  final _amount = TextEditingController();

  // 🔥 manual product
  final _manualProduct = TextEditingController();

  String? category;
  String? product;

  final Map<String, List<String>> products = {
    'Food Grains': [
      'Rice',
      'Wheat',
      'Maize',
      'Sorghum',
      'Bajra',
      'Ragi',
      'Pulses',
      'Other',
    ],
    'Cash Crops': [
      'Cotton',
      'Sugarcane',
      'Tobacco',
      'Jute',
      'Other',
    ],
    'Oilseeds': [
      'Groundnut',
      'Mustard',
      'Soybean',
      'Sunflower',
      'Other',
    ],
    'Fruits & Vegetables': [
      'Mango',
      'Banana',
      'Orange',
      'Grapes',
      'Potato',
      'Tomato',
      'Onion',
      'Other',
    ],
    'Plantation Crops': [
      'Tea',
      'Coffee',
      'Rubber',
      'Coconut',
      'Other',
    ],
    'Spices': [
      'Pepper',
      'Cardamom',
      'Cloves',
      'Other',
    ],
  };

  @override
  void initState() {
    super.initState();
    _pincode.addListener(_onPincodeChange);
  }

  // 🔥 PINCODE → AUTO FILL
  Future<void> _onPincodeChange() async {
    if (_pincode.text.length != 6) return;

    final url =
        'https://api.postalpincode.in/pincode/${_pincode.text}';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data[0]['Status'] == 'Success') {
        final po = data[0]['PostOffice'][0];
        setState(() {
          _postOffice.text = po['Name'] ?? '';
          _mandal.text = po['Block'] ?? po['Taluk'] ?? '';
          _district.text = po['District'] ?? '';
          _state.text = po['State'] ?? '';
        });
      }
    } catch (_) {}
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
                    const LanguageScreen(fromSettings: true),
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
              _field(_mobile, t.mobile, number: true),
              _field(_village, t.village),

              // 🔥 PINCODE FIRST
              _field(_pincode, t.pincode, number: true),
              _readOnly(_postOffice, t.postOffice),
              _readOnly(_mandal, t.mandal),
              _readOnly(_district, t.district),
              _readOnly(_state, t.state),

              const SizedBox(height: 12),

              // CATEGORY
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: t.category,
                  border: const OutlineInputBorder(),
                ),
                value: category,
                items: products.keys
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    category = v;
                    product = null;
                    _manualProduct.clear();
                  });
                },
                validator: (v) =>
                    v == null ? t.selectCategory : null,
              ),

              const SizedBox(height: 12),

              // PRODUCT
              if (category != null)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: t.product,
                    border: const OutlineInputBorder(),
                  ),
                  value: product,
                  items: products[category]!
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      product = v;
                      if (v != 'Other') {
                        _manualProduct.clear();
                      }
                    });
                  },
                  validator: (v) =>
                      v == null ? t.selectProduct : null,
                ),

              // 🔥 MANUAL PRODUCT
              if (product == 'Other')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextFormField(
                    controller: _manualProduct,
                    validator: (v) =>
                        v == null || v.isEmpty
                            ? t.enterProductName
                            : null,
                    decoration: InputDecoration(
                      labelText: t.enterProductName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              _field(_quantity, t.quantity),
              _field(_txnNo, t.transactionNumber),
              _field(_amount, t.paidAmount, number: true),

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

  Widget _field(TextEditingController c, String label,
      {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType:
            number ? TextInputType.number : TextInputType.text,
        validator: (v) =>
            v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _readOnly(TextEditingController c, String label) {
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance.collection('farmers').add({
      'partnerId': widget.partnerId,
      'farmerName': _name.text,
      'mobile': _mobile.text,
      'village': _village.text,
      'pincode': _pincode.text,
      'postOffice': _postOffice.text,
      'mandal': _mandal.text,
      'district': _district.text,
      'state': _state.text,
      'category': category,
      'product':
          product == 'Other' ? _manualProduct.text : product,
      'quantity': int.parse(_quantity.text),
      'transactionNo': _txnNo.text,
      'paidAmount': int.parse(_amount.text),
      'createdAt': Timestamp.now(),
      'status': 'submitted',
    });

    Navigator.pop(context);
  }
}
