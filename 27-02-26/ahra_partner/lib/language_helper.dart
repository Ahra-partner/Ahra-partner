import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

Future<AppStrings> loadStrings() async {
  final prefs = await SharedPreferences.getInstance();
  final lang = prefs.getString('app_language') ?? 'en';
  return AppStrings(lang);
}
