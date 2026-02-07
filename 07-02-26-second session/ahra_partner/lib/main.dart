import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'login_screen.dart';
import 'admin_home_screen.dart';
import 'auth_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 THIS IS THE FIX
    final lang = context.watch<LanguageProvider>().lang;

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 VERY IMPORTANT – THIS TRIGGERS FULL REBUILD
      locale: Locale(lang),

      // 🔥 SINGLE ENTRY (unchanged)
      home: const AuthRouter(),

      // 🔥 ADMIN ROUTES (unchanged)
      routes: {
        '/login': (_) => const LoginScreen(),
        '/admin': (_) => const AdminHomeScreen(),
      },
    );
  }
}
