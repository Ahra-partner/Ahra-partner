import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'language_provider.dart';
import 'login_screen.dart';
import 'auth_router.dart';

// 🔥 ADD THIS (VERY IMPORTANT)
const bool isPartnerApp = bool.fromEnvironment('PARTNER_APP');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ✅ Notification Permission (Android 13+)
  await FirebaseMessaging.instance.requestPermission();

  // 🔔 FCM setup (ADDED)
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String? token = await messaging.getToken();
  print("🔥 FCM Token: $token");

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    // 🔔 Foreground Notification Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Notification received");

      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.notification?.body ?? "",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    // 🔥 App open via notification click (ADDED)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("👉 Notification clicked");

      Navigator.pushNamed(context, '/login');
    });

    // 🔥 Subscribe to admin topic (ADDED)
    FirebaseMessaging.instance.subscribeToTopic("admin");
  }

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

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 🔥 NO CHANGE HERE (AuthRouter handles logic)
      home: const AuthRouter(),

      routes: {
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}