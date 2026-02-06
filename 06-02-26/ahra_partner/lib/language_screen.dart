import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';

class LanguageScreen extends StatelessWidget {
  final bool fromSettings;

  const LanguageScreen({
    super.key,
    this.fromSettings = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LanguageProvider>();
    final currentLang = provider.lang;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),

          const Text(
            'Select Language',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _langTile(context, 'English', 'en', currentLang),
          _langTile(context, 'తెలుగు', 'te', currentLang),
          _langTile(context, 'हिन्दी', 'hi', currentLang),
          _langTile(context, 'ಕನ್ನಡ', 'kn', currentLang),
          _langTile(context, 'தமிழ்', 'ta', currentLang),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _langTile(
    BuildContext context,
    String title,
    String code,
    String currentLang,
  ) {
    return ListTile(
      title: Text(title),
      trailing: currentLang == code
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        // 🔥 ONLY THIS LINE IS IMPORTANT
        context.read<LanguageProvider>().setLang(code);

        // 🔥 JUST CLOSE BOTTOM SHEET
        Navigator.pop(context);
      },
    );
  }
}
