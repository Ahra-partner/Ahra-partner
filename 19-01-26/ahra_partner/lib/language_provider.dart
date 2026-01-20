import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _lang = 'en';

  String get lang => _lang;

  LanguageProvider() {
    loadLanguage();
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('app_language') ?? 'en';
    notifyListeners();
  }

  Future<void> changeLanguage(String newLang) async {
    _lang = newLang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', newLang);
    notifyListeners(); // 🔥 REAL-TIME update
  }
}
