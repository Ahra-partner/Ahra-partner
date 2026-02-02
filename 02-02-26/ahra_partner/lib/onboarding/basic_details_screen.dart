import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  bool _loading = false;

  Future<void> _saveAndNext() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .set({
      'fullName': _nameCtrl.text.trim(),
      'mobile': _mobileCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'country': _countryCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'district': _districtCtrl.text.trim(),

      // FLOW CONTROL
      'onboardingStep': 1,
      'step1Completed': true,
      'kycStatus': 'not_started',

      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    // 👉 NEXT STEP (we will build next)
    Navigator.pushReplacementNamed(context, '/step2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Step 1 of 5',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              _field(
                controller: _nameCtrl,
                label: 'Full Name',
                icon: Icons.person,
              ),
              _field(
                controller: _mobileCtrl,
                label: 'Mobile Number',
                icon: Icons.phone,
                keyboard: TextInputType.phone,
              ),
              _field(
                controller: _emailCtrl,
                label: 'Email ID',
                icon: Icons.email,
                keyboard: TextInputType.emailAddress,
              ),
              _field(
                controller: _countryCtrl,
                label: 'Country',
                icon: Icons.public,
              ),
              _field(
                controller: _stateCtrl,
                label: 'State',
                icon: Icons.map,
              ),
              _field(
                controller: _districtCtrl,
                label: 'District',
                icon: Icons.location_city,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _loading ? null : _saveAndNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Save & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) =>
            v == null || v.isEmpty ? 'Required field' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
