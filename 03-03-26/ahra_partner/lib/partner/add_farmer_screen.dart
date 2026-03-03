import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';

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

  final _quantity = TextEditingController();
  String _unit = 'Kg';

  final _txnNo = TextEditingController();
  final _amount = TextEditingController();
  final _manualProduct = TextEditingController();

  String? category;
  String? product;

  final Map<String, List<String>> products = {
    'Food Grains': ['Rice', 'Wheat', 'Maize', 'Other'],
    'Cash Crops': ['Cotton', 'Sugarcane', 'Other'],
    'Oilseeds': ['Groundnut', 'Mustard', 'Other'],
    'Fruits & Vegetables': ['Mango', 'Banana', 'Other'],
    'Plantation Crops': ['Tea', 'Coffee', 'Other'],
    'Spices': ['Pepper', 'Cardamom', 'Other'],
  };

  @override
  void initState() {
    super.initState();
    _pincode.addListener(_onPincodeChange);
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _village.dispose();
    _pincode.dispose();
    _postOffice.dispose();
    _mandal.dispose();
    _district.dispose();
    _state.dispose();
    _quantity.dispose();
    _txnNo.dispose();
    _amount.dispose();
    _manualProduct.dispose();
    super.dispose();
  }

  Future<void> _onPincodeChange() async {
    if (_pincode.text.length != 6) return;

    try {
      final res = await http.get(
        Uri.parse('https://api.postalpincode.in/pincode/${_pincode.text}'),
      );
      final data = json.decode(res.body);

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

  // ================= FINAL SUBMIT =================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final mobile = _mobile.text.trim();
      final amount = int.parse(_amount.text.trim());
      final qty = int.parse(_quantity.text.trim());

      final now = DateTime.now();
      final monthId =
          "${now.year}-${now.month.toString().padLeft(2, '0')}";

      final farmerRef =
          FirebaseFirestore.instance.collection('farmers').doc(mobile);

      // 1️⃣ FARMER MASTER (SUMMARY)
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

        // 🔥 IMPORTANT FIELDS
        'category': category,
        'product':
            product == 'Other' ? _manualProduct.text.trim() : product,
        'quantity': qty,
        'unit': _unit,

        'subscriptionAmount': amount,
        'status': 'submitted',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2️⃣ MONTHLY SUBSCRIPTION (HISTORY)
      await farmerRef
          .collection('subscriptions')
          .doc(monthId)
          .set({
        'partnerId': uid,
        'month': monthId,
        'category': category,
        'product':
            product == 'Other' ? _manualProduct.text.trim() : product,
        'quantity': qty,
        'unit': _unit,
        'amount': amount,
        'transactionNo': _txnNo.text.trim(),
        'status': 'submitted',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer & subscription saved')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
              _field(_mobile, t.mobileNumber,
                  number: true, phone: true),
              _field(_village, t.village),

              _field(_pincode, t.pincode, number: true),
              _readOnlyField(_postOffice, t.postOffice),
              _readOnlyField(_mandal, t.mandal),
              _readOnlyField(_district, t.district),
              _readOnlyField(_state, t.state),

              const SizedBox(height: 12),

              // CATEGORY
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: t.category,
                  border: const OutlineInputBorder(),
                ),
                items: products.keys
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    category = v;
                    product = null;
                  });
                },
                validator: (v) =>
                    v == null ? t.selectCategory : null,
              ),

              const SizedBox(height: 12),

              // PRODUCT
              if (category != null)
                DropdownButtonFormField<String>(
                  value: product,
                  decoration: InputDecoration(
                    labelText: t.product,
                    border: const OutlineInputBorder(),
                  ),
                  items: products[category]!
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => product = v),
                  validator: (v) =>
                      v == null ? t.selectProduct : null,
                ),

              if (product == 'Other')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child:
                      _field(_manualProduct, t.enterProductName),
                ),

              const SizedBox(height: 12),

              // QUANTITY + UNIT
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _field(
                        _quantity, t.quantity, number: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unit,
                      decoration: InputDecoration(
                        labelText: t.quantityUnit,
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Kg', child: Text('Kg')),
                        DropdownMenuItem(
                            value: 'Quintal',
                            child: Text('Quintal')),
                        DropdownMenuItem(
                            value: 'Ton', child: Text('Ton')),
                      ],
                      onChanged: (v) =>
                          setState(() => _unit = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _field(_txnNo, t.transactionNumber),
              _field(_amount, t.platformAmount, number: true),

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
      {bool number = false, bool phone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: phone
            ? TextInputType.phone
            : number
                ? TextInputType.number
                : TextInputType.text,
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Required' : null,
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
