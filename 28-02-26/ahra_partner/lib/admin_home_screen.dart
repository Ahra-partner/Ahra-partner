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
import 'admin/admin_support_panel_screen.dart';
import 'admin/admin_inactive_subscriptions_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final String role;
  final Map<String, dynamic> permissions;

  const AdminHomeScreen({
    super.key,
    required this.role,
    required this.permissions,
  });

  // 🔐 Permission Check
  bool hasPermission(String key) {
    if (role == 'admin') return true;
    return permissions[key] == true;
  }

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

              // LOGO
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

              Text(
                role == 'admin'
                    ? 'Welcome Admin 👋'
                    : 'Welcome Sub Admin 👋',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // 🔵 QR SCAN
              if (hasPermission('scan_qr'))
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

              if (hasPermission('scan_qr'))
                const SizedBox(height: 16),

              // PARTNER OVERVIEW
              if (hasPermission('partner_overview'))
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

              if (hasPermission('partner_overview'))
                const SizedBox(height: 16),

              // KYC
              if (hasPermission('kyc'))
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

              if (hasPermission('kyc'))
                const SizedBox(height: 16),

              // WITHDRAW
              if (hasPermission('withdraw'))
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

              if (hasPermission('withdraw'))
                const SizedBox(height: 16),

              // PAYOUT
              if (hasPermission('payout'))
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

              if (hasPermission('payout'))
                const SizedBox(height: 16),

              // REVENUE DASHBOARD
              if (hasPermission('revenue'))
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

              if (hasPermission('revenue'))
                const SizedBox(height: 16),

              // PARTNER REVENUE
              if (hasPermission('partner_revenue'))
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

              if (hasPermission('partner_revenue'))
                const SizedBox(height: 16),

              // LOCATION SUMMARY
              if (hasPermission('location_summary'))
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

              if (hasPermission('location_summary'))
                const SizedBox(height: 16),

              // SUPPORT PANEL
              if (hasPermission('support'))
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

              if (hasPermission('support'))
                const SizedBox(height: 16),

              // INACTIVE SUBSCRIPTIONS
              if (hasPermission('inactive'))
                ElevatedButton.icon(
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text('Inactive Subscriptions'),
                  style: _adminButtonStyle(const Color(0xFFB91C1C)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AdminInactiveSubscriptionsScreen(),
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