import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'app_start_screen.dart';

class LanguageScreen extends StatelessWidget {
  final bool fromSettings; // ✅ ADD THIS

  const LanguageScreen({
    super.key,
    this.fromSettings = false, // ✅ DEFAULT = false
  });

  // 🇮🇳 Supported languages
  static const List<Map<String, String>> languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'te', 'label': 'తెలుగు'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'kn', 'label': 'ಕನ್ನಡ'},
    {'code': 'ml', 'label': 'മലയാളം'},
    {'code': 'mr', 'label': 'मराठी'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
    {'code': 'bn', 'label': 'বাংলা'},
    {'code': 'pa', 'label': 'ਪੰਜਾਬੀ'},
  ];

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              ...languages.map(
                (lang) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {
                        // ✅ Update language (realtime)
                        langProvider.changeLanguage(lang['code']!);

                        // 🔁 NAVIGATION FIX
                        if (fromSettings) {
                          // Came from dashboard/settings
                          Navigator.pop(context);
                        } else {
                          // First-time app launch
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AppStartScreen(),
                            ),
                          );
                        }
                      },
                      child: Text(
                        lang['label']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
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
