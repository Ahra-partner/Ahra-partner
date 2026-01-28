import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EducationExperienceScreen extends StatefulWidget {
  final String partnerId;

  const EducationExperienceScreen({
    super.key,
    required this.partnerId,
  });

  @override
  State<EducationExperienceScreen> createState() =>
      _EducationExperienceScreenState();
}

class _EducationExperienceScreenState
    extends State<EducationExperienceScreen> {
  final _formKey = GlobalKey<FormState>();

  String? qualification;
  bool hasExperience = false;
  String? experienceYears;

  bool loading = false;

  final qualifications = [
    'Below 10th',
    '10th',
    '12th',
    'Graduate',
    'Post Graduate',
    'Other',
  ];

  final experienceOptions = [
    '1–2 years',
    '3–5 years',
    '5–10 years',
    '10+ years',
  ];

  // 🔁 BACK → STEP-1
  Future<void> goBackToBasicDetails() async {
    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .update({
      'currentStep': 1,
    });
  }

  // ✅ SAVE → STEP-3 (KYC)
  Future<void> saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .set({
      'qualification': qualification,
      'agricultureExperience': hasExperience,
      'experienceYears': hasExperience ? experienceYears : '',
      'currentStep': 3,
    }, SetOptions(merge: true));

    setState(() => loading = false);

    // ❌ Navigator.pop() NOT needed
    // ✅ AppRouter will auto open STEP-3
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education & Experience'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBackToBasicDetails, // ✅ FIXED
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Qualification
              const Text(
                'Highest Qualification',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: qualification,
                items: qualifications
                    .map(
                      (q) => DropdownMenuItem(
                        value: q,
                        child: Text(q),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => qualification = v),
                validator: (v) =>
                    v == null ? 'Select qualification' : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // Experience yes/no
              const Text(
                'Experience in Agriculture?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: hasExperience,
                    onChanged: (_) =>
                        setState(() => hasExperience = true),
                  ),
                  const Text('Yes'),
                  Radio<bool>(
                    value: false,
                    groupValue: hasExperience,
                    onChanged: (_) {
                      setState(() {
                        hasExperience = false;
                        experienceYears = null;
                      });
                    },
                  ),
                  const Text('No'),
                ],
              ),

              // Experience years
              if (hasExperience) ...[
                const SizedBox(height: 10),
                const Text(
                  'Years of Experience',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: experienceYears,
                  items: experienceOptions
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => experienceYears = v),
                  validator: (v) =>
                      hasExperience && v == null
                          ? 'Select experience'
                          : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              Center(
                child: loading
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
