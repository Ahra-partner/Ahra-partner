import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'app_router.dart';
import 'app_start_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const AhraApp(),
    ),
  );
}

class AhraApp extends StatelessWidget {
  const AhraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppStartScreen(), // 🔥 THIS IS THE FIX
    );
  }
}
