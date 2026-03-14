import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
import 'admin/admin_payment_verification_screen.dart'; // 🔥 NEW IMPORT

class AdminHomeScreen extends StatefulWidget {
  final String role;
  final Map<String, dynamic> permissions;

  const AdminHomeScreen({
    super.key,
    required this.role,
    required this.permissions,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  bool hasPermission(String key) {
    if (widget.role == 'admin') return true;
    return widget.permissions[key] == true;
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

  Future<void> generateMissingEmpIds() async {

    final partnersRef =
        FirebaseFirestore.instance.collection('partners');

    final partners = await partnersRef.get();

    for (var doc in partners.docs) {

      final data = doc.data();

      if (!data.containsKey('empId') ||
          (data['empId'] ?? '').toString().isEmpty) {

        final newEmpId = await generateEmployeeId();

        await partnersRef.doc(doc.id).update({
          'empId': newEmpId,
        });

      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Missing Employee IDs generated"),
      ),
    );
  }

  Future<String> generateEmployeeId() async {

    final year = DateTime.now().year;

    final counterRef = FirebaseFirestore.instance
        .collection('counters')
        .doc('partnerCounter_$year');

    return FirebaseFirestore.instance
        .runTransaction((transaction) async {

      final snapshot = await transaction.get(counterRef);

      int currentNumber = 0;

      if (!snapshot.exists) {
        transaction.set(counterRef, {'currentNumber': 1});
        currentNumber = 1;
      } else {
        currentNumber = snapshot['currentNumber'] ?? 0;
        currentNumber++;

        transaction.update(counterRef, {
          'currentNumber': currentNumber,
        });
      }

      final formatted =
          currentNumber.toString().padLeft(4, '0');

      return "AHRA-$year-$formatted";
    });
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
                widget.role == 'admin'
                    ? 'Welcome Admin 👋'
                    : 'Welcome Sub Admin 👋',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // 🔥 PAYMENT VERIFICATION BUTTON (NEW)
              ElevatedButton.icon(
                icon: const Icon(Icons.verified),
                label: const Text("Payment Verification"),
                style: _adminButtonStyle(const Color(0xFF6366F1)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminPaymentVerificationScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              if (hasPermission('partner_overview'))
                ElevatedButton.icon(
                  icon: const Icon(Icons.badge),
                  label: const Text('Generate Missing Employee IDs'),
                  style: _adminButtonStyle(const Color(0xFF9333EA)),
                  onPressed: generateMissingEmpIds,
                ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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