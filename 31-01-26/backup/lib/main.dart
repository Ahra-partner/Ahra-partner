import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'auth_router.dart';

import 'admin_home_screen.dart';
import 'partner_dashboard.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 SINGLE ENTRY POINT (ADMIN / PARTNER DECISION)
      home: const AuthRouter(),

      // 🔁 NAMED ROUTES (FIXES ROUTE ERRORS)
      routes: {
        '/admin': (_) => const AdminHomeScreen(),
        '/partner': (_) => const PartnerDashboard(
              partnerName: 'Dummy Partner',
              partnerId: 'dummy_partner_001',
            ),
      },
    );
  }
}
