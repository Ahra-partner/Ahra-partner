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

    // 🔥 LOGGED IN PARTNER UID
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

                // ✅ HORIZONTAL PARTNER TYPES
                _partnerTypeHorizontal(context, t),
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

  // ================= PARTNER TYPE – HORIZONTAL =================
  Widget _partnerTypeHorizontal(
      BuildContext context, AppStrings t) {
    final items = [
      {
        'title': t.farmers,
        'img': 'assets/partner_types/farmer.png',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FarmerListScreen(),
            ),
          );
        },
      },
      {
        'title': t.retailers,
        'img': 'assets/partner_types/retailer.png',
      },
      {
        'title': t.wholesalers,
        'img': 'assets/partner_types/wholesaler.png',
      },
      {
        'title': t.exporters,
        'img': 'assets/partner_types/exporter.png',
      },
      {
        'title': t.foodProcessor,
        'img': 'assets/partner_types/processor.png',
      },
    ];

    return SizedBox(
      height: 135, // 🔥 SMALLER HEIGHT
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: items[i]['onTap'] as VoidCallback? ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coming soon 🚧'),
                    ),
                  );
                },
            child: Container(
              width: 120, // 🔥 SMALLER CARD
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: lightGreen),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    items[i]['img'] as String,
                    height: 42, // 🔥 SMALL ICON
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[i]['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
              Text(
                t.walletBalance,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '₹ $wallet',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
