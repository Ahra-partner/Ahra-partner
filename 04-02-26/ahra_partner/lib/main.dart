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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        // 🔥 SINGLE ENTRY
        home: const AuthRouter(),

        // 🔥 ADMIN ROUTES FIX
        routes: {
          '/login': (_) => const LoginScreen(),
          '/admin': (_) => const AdminHomeScreen(),
        },
      ),
    );
  }
}
