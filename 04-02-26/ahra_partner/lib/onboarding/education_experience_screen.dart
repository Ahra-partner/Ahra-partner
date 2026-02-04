import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../language_screen.dart';
import 'kyc_upload_screen.dart';

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
  String? hasExperience;
  String? experienceYears;

  bool _loading = false;

  final List<String> qualifications = [
    'Below 10th',
    '10th',
    '12th',
    'Graduate',
    'Post Graduate',
    'Other',
  ];

  final List<String> experienceOptions = [
    '1–2 years',
    '3–5 years',
    '5–10 years',
    '10+ years',
  ];

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('partners')
          .doc(widget.partnerId)
          .set({
        'qualification': qualification,
        'hasAgriExperience': hasExperience == 'Yes',
        'experienceYears':
            hasExperience == 'Yes' ? experienceYears : null,

        // ✅ FLOW FLAGS
        'educationCompleted': true,

        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      // 👉 NEXT SCREEN (KYC UPLOAD)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => KycUploadScreen(
            partnerId: widget.partnerId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ⬅️ BACK BUTTON automatic
      appBar: AppBar(
        title: const Text('Education & Experience'),
        centerTitle: true,

        // 🌐 LANGUAGE BUTTON
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const LanguageScreen(
                  fromSettings: true,
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
            const Text(
              'Step 2 of 5',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 🔹 QUALIFICATION
            DropdownButtonFormField<String>(
              value: qualification,
              decoration: const InputDecoration(
                labelText: 'Highest Qualification',
                border: OutlineInputBorder(),
              ),
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
                  v == null ? 'Please select qualification' : null,
            ),

            const SizedBox(height: 20),

            // 🔹 EXPERIENCE
            const Text(
              'Experience in Agriculture?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            RadioListTile<String>(
              title: const Text('Yes'),
              value: 'Yes',
              groupValue: hasExperience,
              onChanged: (v) => setState(() => hasExperience = v),
            ),
            RadioListTile<String>(
              title: const Text('No'),
              value: 'No',
              groupValue: hasExperience,
              onChanged: (v) => setState(() => hasExperience = v),
            ),

            if (hasExperience == 'Yes') ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: experienceYears,
                decoration: const InputDecoration(
                  labelText: 'Years of Experience',
                  border: OutlineInputBorder(),
                ),
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
                validator: (v) {
                  if (hasExperience == 'Yes' && v == null) {
                    return 'Please select experience';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _loading ? null : _saveAndContinue,
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
    );
  }
}
