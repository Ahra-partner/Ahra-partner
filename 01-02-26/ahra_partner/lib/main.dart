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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        // ✅ SINGLE ENTRY POINT (VERY IMPORTANT)
        home: const AuthRouter(),

        // ✅ FIX FOR ADMIN LOGIN ERROR
        routes: {
          '/admin': (_) => const AdminHomeScreen(),

          // Dummy partner route (safe backup)
          '/partner': (_) => const PartnerDashboard(
                partnerId: 'dummy_partner_001',
                partnerName: 'Dummy Partner',
              ),
        },
      ),
    );
  }
}
