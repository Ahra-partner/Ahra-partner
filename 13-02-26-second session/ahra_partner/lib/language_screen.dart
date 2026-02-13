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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        centerTitle: true,
        automaticallyImplyLeading: fromSettings,
      ),

      body: ListView(
        children: [
          _langTile(context, 'English', 'en', provider),
          _langTile(context, 'తెలుగు', 'te', provider),
          _langTile(context, 'हिंदी', 'hi', provider),
          _langTile(context, 'ಕನ್ನಡ', 'kn', provider),
          _langTile(context, 'தமிழ்', 'ta', provider),
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
      title: Text(title),
      trailing: provider.lang == code
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () async {
        await provider.changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }
}
