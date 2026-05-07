import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin_home_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;

  Future<void> _login() async {
    setState(() => loading = true);

    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      final uid = cred.user!.uid;

      // 🔥 CHECK ADMINS COLLECTION
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(uid)
          .get();

      if (!adminDoc.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Not authorized as admin');
      }

      final role = adminDoc['role'];

      // 🔥 PASS ROLE + PERMISSIONS TO DASHBOARD
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminHomeScreen(
            role: role,
            permissions: adminDoc.data()?['permissions'] ?? {},
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _login,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}