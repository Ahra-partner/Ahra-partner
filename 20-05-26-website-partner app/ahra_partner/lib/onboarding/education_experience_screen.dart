import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';
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

        // ✅ FLOW FLAG
        'educationCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      // ✅ NEXT SCREEN → KYC UPLOAD (push ONLY)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KycUploadScreen(
            partnerId: widget.partnerId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌐 Language rebuild
    final lang = context.watch<LanguageProvider>().lang;
    final s = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.educationExperience),
        centerTitle: true,

        // ✅ EXPLICIT BACK BUTTON (SAFE)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // ⬅️ Back to Basic Details
          },
        ),

        // 🌐 LANGUAGE BUTTON
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) =>
                    const LanguageScreen(fromSettings: true),
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
              s.stepOf(2, 5),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 🔹 QUALIFICATION
            DropdownButtonFormField<String>(
              value: qualification,
              decoration: InputDecoration(
                labelText: s.highestQualification,
                border: const OutlineInputBorder(),
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
                  v == null ? s.get('required') : null,
            ),

            const SizedBox(height: 20),

            // 🔹 EXPERIENCE
            Text(
              s.agriExperience,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            RadioListTile<String>(
              title: Text(s.yes),
              value: 'Yes',
              groupValue: hasExperience,
              onChanged: (v) => setState(() => hasExperience = v),
            ),
            RadioListTile<String>(
              title: Text(s.no),
              value: 'No',
              groupValue: hasExperience,
              onChanged: (v) => setState(() => hasExperience = v),
            ),

            if (hasExperience == 'Yes') ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: experienceYears,
                decoration: InputDecoration(
                  labelText: s.experienceYears,
                  border: const OutlineInputBorder(),
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
                    return s.get('required');
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _loading ? null : _saveAndContinue,
              child: _loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(s.saveAndContinue),
            ),
          ],
        ),
      ),
    );
  }
}
