import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../language_provider.dart';

class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({super.key});

  static const languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'te', 'label': 'తెలుగు'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'kn', 'label': 'ಕನ್ನಡ'},
  ];

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...languages.map((lang) {
              return RadioListTile<String>(
                title: Text(lang['label']!),
                value: lang['code']!,
                groupValue: langProvider.lang,
                onChanged: (val) {
                  context.read<LanguageProvider>().changeLanguage(val!);
                  Navigator.pop(context); // ✅ CLOSE SHEET
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
