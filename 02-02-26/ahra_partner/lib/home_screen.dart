import 'package:flutter/material.dart';

import 'partner/partner_dashboard.dart';

/// =====================
/// HOME SCREEN
/// (FINAL – NO FIRESTORE / NO SPINNER)
/// =====================
class HomeScreen extends StatelessWidget {
  final String partnerId;

  const HomeScreen({
    super.key,
    required this.partnerId,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 Directly open dashboard
    // No StreamBuilder
    // No Firestore read
    // No KYC checks (for now)

    return PartnerDashboard(
      partnerId: partnerId,
      partnerName: 'Dummy Partner', // ✅ static for now
    );
  }
}
