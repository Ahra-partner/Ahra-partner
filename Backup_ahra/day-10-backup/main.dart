import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'decide_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AhraPartnerApp());
}

class AhraPartnerApp extends StatelessWidget {
  const AhraPartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DecideScreen(), // 🔥 ADMIN MODE
    );
  }
}
