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
      body: StreamBuilder<DocumentSnapshot>(
        key: const ValueKey('partner-wallet-stream'),
        stream: FirebaseFirestore.instance
            .collection('partners')
            .doc(partnerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.data!.exists) {
            return const Center(
              child: Text('Wallet data not found'),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          // 🔥 RAW VALUES FROM FIRESTORE (100%)
          final int rawWallet =
              data['walletBalance'] ?? 0;
          final int rawToday =
              data['todayEarnings'] ?? 0;
          final int rawWeek =
              data['weekEarnings'] ?? 0;
          final int rawMonth =
              data['monthEarnings'] ?? 0;

          // ✅ FINAL DISPLAY VALUES (50% ONLY)
          final int wallet = (rawWallet / 2).round();
          final int today = (rawToday / 2).round();
          final int week = (rawWeek / 2).round();
          final int month = (rawMonth / 2).round();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerSection(t, partnerName),
                const SizedBox(height: 16),

                _partnerTypeHorizontal(context, t),
                const SizedBox(height: 16),

                // ✅ WALLET
                _walletCard(context, t, wallet),
                const SizedBox(height: 16),

                _paymentModeSelector(t),
                const SizedBox(height: 16),

                _earnings(t, today, week, month),
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

  // ================= PARTNER TYPE =================
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
      height: 135,
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
              width: 120,
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
                    height: 42,
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
                                const WithdrawRouterScreen(),
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
