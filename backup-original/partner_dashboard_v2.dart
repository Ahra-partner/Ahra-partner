import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';

// 🔥 WITHDRAW
import '../withdraw/withdraw_router_screen.dart';

// 🔥 FARMER LIST
import '../partner/farmer_list_screen.dart';

class PartnerDashboardV2 extends StatelessWidget {
  final String partnerName;

  const PartnerDashboardV2({
    super.key,
    required this.partnerName,
  });

  // 🌿 BRAND COLORS
  static const primaryGreen = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFF66BB6A);
  static const accentOrange = Color(0xFFE67E22);
  static const bgColor = Color(0xFFF6F8F7);

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final t = AppStrings(lang);

    // 🔥 LOGGED-IN PARTNER UID
    final String partnerId =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: bgColor,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text('AHRA Partner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) =>
                    const LanguageScreen(fromSettings: true),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      // ================= BODY =================
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('partnerId', isEqualTo: partnerId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];
          final now = DateTime.now();

          int wallet = 0;
          int today = 0;
          int week = 0;
          int month = 0;

          // ================= CALCULATION =================
          for (var d in docs) {
            final data = d.data() as Map<String, dynamic>;

            final int amount =
                (data['amount'] as num?)?.toInt() ?? 0;
            final String type = data['type'] ?? '';
            final String status = data['status'] ?? '';
            final DateTime? ts =
                (data['createdAt'] as Timestamp?)?.toDate();

            if (status != 'approved' &&
                status != 'completed') continue;
            if (ts == null) continue;

            if (type == 'credit') wallet += amount;
            if (type == 'debit') wallet -= amount;

            if (type == 'credit' &&
                ts.year == now.year &&
                ts.month == now.month &&
                ts.day == now.day) {
              today += amount;
            }

            final weekStart =
                now.subtract(Duration(days: now.weekday - 1));
            if (type == 'credit' && ts.isAfter(weekStart)) {
              week += amount;
            }

            if (type == 'credit' &&
                ts.year == now.year &&
                ts.month == now.month) {
              month += amount;
            }
          }

          // ================= UI =================
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerSection(t, partnerName),
                const SizedBox(height: 16),

                _partnerTypeSelector(context, t),
                const SizedBox(height: 16),

                _walletCard(context, t, wallet, partnerId),
                const SizedBox(height: 16),

                _paymentModeSelector(t),
                const SizedBox(height: 16),

                _earnings(t, today, week, month),

                if (docs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(
                      child: Text(
                        t.noTransactions,
                        style:
                            const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= HEADER =================
  Widget _headerSection(AppStrings t, String name) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: primaryGreen,
      child: Text(
        '${t.welcome}, $name 👋',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= PARTNER TYPE SELECTOR =================
  Widget _partnerTypeSelector(
      BuildContext context, AppStrings t) {
    return SizedBox(
      height: 170,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _partnerCard(
            context,
            title: t.farmers,
            image: 'assets/partner_types/farmer.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const FarmerListScreen(), // ✅ FIX
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _partnerCard(
    BuildContext context, {
    required String title,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lightGreen),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 60),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WALLET =================
  Widget _walletCard(
    BuildContext context,
    AppStrings t,
    int wallet,
    String partnerId,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: lightGreen,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(t.walletBalance,
                  style:
                      const TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                '₹ $wallet',
                style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange),
                onPressed: wallet <= 0
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WithdrawRouterScreen(
                              partnerId: partnerId,
                              walletAmount: wallet,
                            ),
                          ),
                        );
                      },
                child: Text(t.withdraw),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PAYMENT MODE =================
  Widget _paymentModeSelector(AppStrings t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          Chip(label: Text(t.daily)),
          Chip(label: Text(t.weekly)),
          Chip(label: Text(t.monthly)),
        ],
      ),
    );
  }

  // ================= EARNINGS =================
  Widget _earnings(
      AppStrings t, int today, int week, int month) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _earnCard(t.todayEarnings, today),
          _earnCard(t.weekEarnings, week),
          _earnCard(t.monthEarnings, month),
        ],
      ),
    );
  }

  Widget _earnCard(String title, int amount) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.currency_rupee),
        title: Text(title),
        trailing: Text(
          '₹ $amount',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
