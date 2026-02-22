import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'language_provider.dart';

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

        // ✅ Change app language
        await provider.changeLanguage(code);

        // 🔥 Update Firestore flag
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('partners')
              .doc(user.uid)
              .update({
            "languageSelected": true,
          });
        }

        // ✅ Close this screen
        Navigator.pop(context);
      },
    );
  }
}