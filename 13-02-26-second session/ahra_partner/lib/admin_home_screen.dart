import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin/admin_kyc_tabs_screen.dart';
import 'admin/admin_payout_summary_screen.dart';
import 'admin/admin_withdraw_requests_screen.dart';
import 'admin/admin_revenue_dashboard_screen.dart'; // ✅ NEW IMPORT

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,

        // 🔴 LOGOUT BUTTON (TOP RIGHT)
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // AuthRouter will redirect to Login
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
              'Welcome Admin 👋',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // ✅ KYC REQUESTS
            ElevatedButton.icon(
              icon: const Icon(Icons.verified_user),
              label: const Text(
                'KYC Requests',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminKycTabsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ WITHDRAW REQUESTS
            ElevatedButton.icon(
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text(
                'Withdraw Requests',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AdminWithdrawRequestsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.orange,
              ),
            ),

            const SizedBox(height: 16),

            // ✅ PAYOUT SUMMARY
            ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text(
                'Payout Summary',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AdminPayoutSummaryScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green,
              ),
            ),

            const SizedBox(height: 16),

            // ✅ NEW: REVENUE DASHBOARD
            ElevatedButton.icon(
              icon: const Icon(Icons.trending_up),
              label: const Text(
                'Revenue Dashboard',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AdminRevenueDashboardScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
