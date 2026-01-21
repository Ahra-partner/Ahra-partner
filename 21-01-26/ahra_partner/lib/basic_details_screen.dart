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

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final countryController = TextEditingController(text: 'India');
  final stateController = TextEditingController();
  final districtController = TextEditingController();
  final mandalController = TextEditingController();
  final villageController = TextEditingController();
  final pincodeController = TextEditingController();

  bool loading = false;

  Future<void> saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .set({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'country': countryController.text.trim(),
      'state': stateController.text.trim(),
      'district': districtController.text.trim(),
      'mandal': mandalController.text.trim(),
      'village': villageController.text.trim(),
      'pincode': pincodeController.text.trim(),
      'currentStep': 2,
    }, SetOptions(merge: true));

    setState(() => loading = false);

    Navigator.pop(context); 
    // AppRouter malli listen chesi STEP-2 screen open chestundi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(nameController, 'Full Name'),
              _field(emailController, 'Email ID'),
              _field(countryController, 'Country'),
              _field(stateController, 'State'),
              _field(districtController, 'District'),
              _field(mandalController, 'Mandal / Taluk'),
              _field(villageController, 'Village / Town'),
              _field(
                pincodeController,
                'Pincode',
                keyboard: TextInputType.number,
              ),

              const SizedBox(height: 30),

              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'Save & Continue',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) =>
            v == null || v.isEmpty ? 'Required field' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
