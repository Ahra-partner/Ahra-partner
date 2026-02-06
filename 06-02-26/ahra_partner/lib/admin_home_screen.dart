import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'admin_payout_summary_screen.dart';
import 'admin_withdraw_requests_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,

        // 🔴 LOGOUT BUTTON
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Colors.orange,
            ),

            const SizedBox(height: 20),

            const Text(
              'Welcome Admin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // ✅ PENDING KYC (TEMP DUMMY SCREEN)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _PendingKycDummyScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Pending KYC Requests',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ WITHDRAW REQUESTS
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminWithdrawRequestsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                'Withdraw Requests',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ PAYOUT SUMMARY
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminPayoutSummaryScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Payout Summary',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 TEMPORARY DUMMY SCREEN
/// (Later real Pending KYC list replace cheddam)
class _PendingKycDummyScreen extends StatelessWidget {
  const _PendingKycDummyScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending KYC'),
      ),
      body: const Center(
        child: Text(
          'No Pending KYC Requests (Dummy Screen)',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
