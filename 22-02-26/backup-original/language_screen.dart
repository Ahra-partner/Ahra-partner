import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'home_screen.dart';

class LanguageScreen extends StatefulWidget {
  final bool fromSettings;

  const LanguageScreen({
    super.key,
    this.fromSettings = false,
  });

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? selectedLang;

  static const List<Map<String, String>> languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'te', 'label': 'తెలుగు'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'kn', 'label': 'ಕನ್ನಡ'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fromSettings
          ? AppBar(title: const Text('Select Language'))
          : null,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            ...languages.map(
              (lang) => RadioListTile<String>(
                title: Text(lang['label']!),
                value: lang['code']!,
                groupValue: selectedLang,
                onChanged: (v) {
                  setState(() => selectedLang = v);
                },
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: selectedLang == null
                  ? null
                  : () {
                      context
                          .read<LanguageProvider>()
                          .changeLanguage(selectedLang!);

                      if (widget.fromSettings) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                      }
                    },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
