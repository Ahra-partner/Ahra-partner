import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'home_screen.dart'; // 👈 ADD THIS (Dashboard screen)

class LanguageScreen extends StatelessWidget {
  final bool fromSettings;

  const LanguageScreen({
    super.key,
    this.fromSettings = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        centerTitle: true,
        automaticallyImplyLeading: fromSettings,
      ),

      body: ListView(
        children: [

          _langTile(context, 'English', 'en', provider),
          _langTile(context, 'हिन्दी (Hindi)', 'hi', provider),
          _langTile(context, 'తెలుగు (Telugu)', 'te', provider),
          _langTile(context, 'தமிழ் (Tamil)', 'ta', provider),
          _langTile(context, 'ಕನ್ನಡ (Kannada)', 'kn', provider),
          _langTile(context, 'മലയാളം (Malayalam)', 'ml', provider),
          _langTile(context, 'বাংলা (Bengali)', 'bn', provider),
          _langTile(context, 'ગુજરાતી (Gujarati)', 'gu', provider),
          _langTile(context, 'ਪੰਜਾਬੀ (Punjabi)', 'pa', provider),
          _langTile(context, 'मराठी (Marathi)', 'mr', provider),
          _langTile(context, 'ଓଡ଼ିଆ (Odia)', 'or', provider),
          _langTile(context, 'संस्कृतम् (Sanskrit)', 'sa', provider),
        ],
      ),
    );
  }

  Widget _langTile(
    BuildContext context,
    String title,
    String code,
    LanguageProvider provider,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: provider.lang == code
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () async {

        await provider.changeLanguage(code);

        if (fromSettings) {
          // 👈 If opened from settings → just go back
          Navigator.pop(context);
        } else {
          // 👈 If first time selection → go to dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
        }
      },
    );
  }
}
