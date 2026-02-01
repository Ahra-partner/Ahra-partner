import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_screen.dart';
import 'app_router.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  @override
  void initState() {
    super.initState();
    _checkLanguage();
  }

  Future<void> _checkLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language');

    if (lang == null) {
      // ❌ Language not selected
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LanguageScreen()),
      );
    } else {
      // ✅ Language already selected
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AppRouter(
            userId: 'dummy_partner_001',
           // userId: 'admin_001',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
