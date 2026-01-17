import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AhraApp());
}

class AhraApp extends StatelessWidget {
  const AhraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppRouter(
        userId: 'dummy_partner_001', // later → FirebaseAuth UID
      ),
    );
  }
}
