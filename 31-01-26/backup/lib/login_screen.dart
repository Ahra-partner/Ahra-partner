import 'package:flutter/material.dart';

import 'admin_login.dart';
import 'partner_login_dummy.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 24),

            const Text(
              'Select Login Type',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            // ================= ADMIN LOGIN =================
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminLoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
              ),
              child: const Text(
                'Admin Login',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            // ================= PARTNER LOGIN =================
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PartnerLoginDummyScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Partner Login',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              '⚠ Dummy login for development only',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
