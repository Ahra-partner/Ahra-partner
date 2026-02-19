import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin/admin_kyc_tabs_screen.dart';
import 'admin/admin_payout_summary_screen.dart';
import 'admin/admin_withdraw_requests_screen.dart';
import 'admin/admin_revenue_dashboard_screen.dart';
import 'admin/admin_partner_revenue_screen.dart';
import 'admin/admin_location_summary_screen.dart';
import 'admin/admin_partner_overview_screen.dart';
import 'admin/admin_qr_scan_screen.dart';
import 'admin/admin_support_panel_screen.dart'; // ✅ NEW

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

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

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 30),

              // 🔵 LOGO
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.deepPurple,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/ahra_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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

              // QR SCAN
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Partner QR'),
                style: _adminButtonStyle(const Color(0xFF0EA5E9)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminQrScanScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // PARTNER OVERVIEW
              ElevatedButton.icon(
                icon: const Icon(Icons.dashboard_customize),
                label: const Text('Partner Overview'),
                style: _adminButtonStyle(const Color(0xFF2563EB)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminPartnerOverviewScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // KYC
              ElevatedButton.icon(
                icon: const Icon(Icons.verified_user),
                label: const Text('KYC Requests'),
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

              // WITHDRAW
              ElevatedButton.icon(
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('Withdraw Requests'),
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

              // PAYOUT
              ElevatedButton.icon(
                icon: const Icon(Icons.bar_chart),
                label: const Text('Payout Summary'),
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

              // REVENUE DASHBOARD
              ElevatedButton.icon(
                icon: const Icon(Icons.trending_up),
                label: const Text('Revenue Dashboard'),
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

              // PARTNER REVENUE
              ElevatedButton.icon(
                icon: const Icon(Icons.group),
                label: const Text('Partner Revenue'),
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

              // LOCATION SUMMARY
              ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text('Location Summary'),
                style: _adminButtonStyle(const Color(0xFF0D9488)),
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

              const SizedBox(height: 16),

              // 🆕 SUPPORT PANEL BUTTON
              ElevatedButton.icon(
                icon: const Icon(Icons.support_agent),
                label: const Text('Support Tickets'),
                style: _adminButtonStyle(const Color(0xFFE11D48)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminSupportPanelScreen(),
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
