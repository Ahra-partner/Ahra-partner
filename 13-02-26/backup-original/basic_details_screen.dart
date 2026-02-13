import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';
import 'education_experience_screen.dart';

class BasicDetailsScreen extends StatefulWidget {
  final String partnerId;

  const BasicDetailsScreen({
    super.key,
    required this.partnerId,
  });

  @override
  State<BasicDetailsScreen> createState() => _BasicDetailsScreenState();
}

class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');
  final _stateCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _mandalCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _postOfficeCtrl = TextEditingController();

  bool _loading = false;
  bool _pinLoading = false;

  // 🔹 PINCODE → AUTO FILL
  Future<void> _fetchFromPincode(String pin) async {
    if (pin.length != 6) return;

    setState(() => _pinLoading = true);

    try {
      final res = await http.get(
        Uri.parse('https://api.postalpincode.in/pincode/$pin'),
      );

      final data = json.decode(res.body);

      if (data[0]['Status'] == 'Success') {
        final po = data[0]['PostOffice'][0];
        _stateCtrl.text = po['State'] ?? '';
        _districtCtrl.text = po['District'] ?? '';
        _mandalCtrl.text =
            po['Block'] ?? po['Division'] ?? '';
        _postOfficeCtrl.text = po['Name'] ?? '';
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _pinLoading = false);
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('partners')
          .doc(widget.partnerId)
          .set({
        'name': _nameCtrl.text.trim(),
        'mobile': _mobileCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'district': _districtCtrl.text.trim(),
        'mandal': _mandalCtrl.text.trim(),
        'postOffice': _postOfficeCtrl.text.trim(),
        'pincode': _pincodeCtrl.text.trim(),

        'basicCompleted': true,
        'educationCompleted': false,
        'kycSubmitted': false,
        'kycStatus': 'not_started',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BasicDetailsScreen(partnerId: widget.partnerId),
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
        title: Text(s.basicDetails),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LanguageScreen(fromSettings: true),
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              s.stepOf(1, 5),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            _field(_nameCtrl, s.fullName, Icons.person),
            _field(_mobileCtrl, s.mobile, Icons.phone,
                keyboard: TextInputType.phone),
            _field(_emailCtrl, s.email, Icons.email,
                keyboard: TextInputType.emailAddress),
            _field(_countryCtrl, s.country, Icons.public),

            _field(
              _pincodeCtrl,
              s.pincode,
              Icons.pin,
              keyboard: TextInputType.number,
              onChanged: _fetchFromPincode,
              suffix: _pinLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),

            _field(_postOfficeCtrl, s.postOffice,
                Icons.local_post_office),
            _field(_stateCtrl, s.state, Icons.map),
            _field(_districtCtrl, s.district,
                Icons.location_city),
            _field(_mandalCtrl, s.mandal,
                Icons.account_tree),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _loading ? null : _saveAndContinue,
              child: _loading
                  ? const CircularProgressIndicator(
                      color: Colors.white)
                  : Text(s.saveAndContinue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    void Function(String)? onChanged,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        onChanged: onChanged,
        validator: (v) =>
            v == null || v.isEmpty ? 'Required field' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
