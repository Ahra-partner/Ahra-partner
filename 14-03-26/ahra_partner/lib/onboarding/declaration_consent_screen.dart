import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeclarationConsentScreen extends StatefulWidget {
  final String partnerId;

  const DeclarationConsentScreen({
    super.key,
    required this.partnerId,
  });

  @override
  State<DeclarationConsentScreen> createState() =>
      _DeclarationConsentScreenState();
}

class _DeclarationConsentScreenState
    extends State<DeclarationConsentScreen> {
  bool confirmDetails = false;
  bool agreeTerms = false;
  bool consentKyc = false;

  bool submitting = false;

  bool get allChecked =>
      confirmDetails && agreeTerms && consentKyc;

  // ================= SUBMIT =================
  Future<void> _submitDeclaration() async {
    if (!allChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept all declarations'),
        ),
      );
      return;
    }

    setState(() => submitting = true);

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .set({
      'declaration': {
        'confirmDetails': true,
        'agreeTerms': true,
        'consentKyc': true,
      },
      'onboardingStep': 4,
      'kycStatus': 'under_review',
      'declarationSubmittedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    // 👉 NEXT: KYC STATUS SCREEN
    Navigator.pushReplacementNamed(context, '/kyc-status');
  }

  // ================= CHECKBOX TILE =================
  Widget _checkTile({
    required bool value,
    required Function(bool?) onChanged,
    required String text,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(text),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Declaration & Consent'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 4 of 5',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),

            const Text(
              'Please read and accept the following:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _checkTile(
              value: confirmDetails,
              onChanged: (v) =>
                  setState(() => confirmDetails = v ?? false),
              text:
                  'I confirm that all the information provided by me is true and correct.',
            ),

            _checkTile(
              value: agreeTerms,
              onChanged: (v) =>
                  setState(() => agreeTerms = v ?? false),
              text:
                  'I agree to the Terms & Conditions of AHRA.',
            ),

            _checkTile(
              value: consentKyc,
              onChanged: (v) =>
                  setState(() => consentKyc = v ?? false),
              text:
                  'I give my consent for KYC verification and data validation.',
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitting ? null : _submitDeclaration,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                child: submitting
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Submit & Complete Onboarding',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
