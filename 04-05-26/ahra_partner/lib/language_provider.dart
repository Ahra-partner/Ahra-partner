import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _lang = 'en';

  String get lang => _lang;

  LanguageProvider() {
    loadLanguage();
  }

  // 🔹 LOAD SAVED LANGUAGE
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('app_language') ?? 'en';
    notifyListeners();
  }

  // 🔹 MAIN METHOD (used internally)
  Future<void> changeLanguage(String newLang) async {
    if (_lang == newLang) return;

    _lang = newLang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', newLang);
    notifyListeners(); // 🔥 real-time UI update
  }

  // 🔥 IMPORTANT FIX
  // Alias method so old code like setLang() works
  void setLang(String newLang) {
    changeLanguage(newLang);
  }
}
