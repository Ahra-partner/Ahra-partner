import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin/admin_kyc_tabs_screen.dart';
import 'admin/admin_payout_summary_screen.dart';
import 'admin/admin_withdraw_requests_screen.dart';
import 'admin/admin_revenue_dashboard_screen.dart';
import 'admin/admin_partner_revenue_screen.dart';
import 'admin/admin_location_summary_screen.dart'; // ✅ NEW IMPORT

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  // 🔥 Common Button Style (Professional Look)
  ButtonStyle _adminButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      body: SingleChildScrollView( // ✅ scroll added (safe)
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.deepPurple,
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
                style: _adminButtonStyle(const Color(0xFF4F46E5)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminKycTabsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ✅ WITHDRAW REQUESTS
              ElevatedButton.icon(
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text(
                  'Withdraw Requests',
                  style: TextStyle(fontSize: 16),
                ),
                style: _adminButtonStyle(const Color(0xFFDC2626)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminWithdrawRequestsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ✅ PAYOUT SUMMARY
              ElevatedButton.icon(
                icon: const Icon(Icons.bar_chart),
                label: const Text(
                  'Payout Summary',
                  style: TextStyle(fontSize: 16),
                ),
                style: _adminButtonStyle(const Color(0xFF059669)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminPayoutSummaryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ✅ REVENUE DASHBOARD
              ElevatedButton.icon(
                icon: const Icon(Icons.trending_up),
                label: const Text(
                  'Revenue Dashboard',
                  style: TextStyle(fontSize: 16),
                ),
                style: _adminButtonStyle(const Color(0xFF7C3AED)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminRevenueDashboardScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ✅ PARTNER REVENUE
              ElevatedButton.icon(
                icon: const Icon(Icons.group),
                label: const Text(
                  'Partner Revenue',
                  style: TextStyle(fontSize: 16),
                ),
                style: _adminButtonStyle(const Color(0xFF1F2937)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminPartnerRevenueScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ✅ NEW: LOCATION SUMMARY
              ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text(
                  'Location Summary',
                  style: TextStyle(fontSize: 16),
                ),
                style: _adminButtonStyle(const Color(0xFF0D9488)), // Teal
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminLocationSummaryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
