import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
    final lang = context.watch<LanguageProvider>().lang;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(lang),

      supportedLocales: const [
        Locale('en'),
        Locale('te'),
        Locale('hi'),
        Locale('kn'),
        Locale('ta'),
      ],

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const AuthRouter(),

      routes: {
        '/login': (_) => const LoginScreen(),
        '/admin': (_) => const AdminHomeScreen(),
      },
    );
  }
}
