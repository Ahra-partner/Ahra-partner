import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';

// 🔥 ADD THIS IMPORT
import '../withdraw/withdraw_router_screen.dart';

class PartnerDashboardV2 extends StatelessWidget {
  final String partnerId;
  final String partnerName;

  const PartnerDashboardV2({
    super.key,
    required this.partnerId,
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
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerSection(t, partnerName),
                const SizedBox(height: 16),

                _partnerTypeSelector(t),
                const SizedBox(height: 16),

                _walletCard(context, t, wallet),
                const SizedBox(height: 16),

                _paymentModeSelector(t),
                const SizedBox(height: 16),

                _earnings(t, today, week, month),

                if (docs.isEmpty) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      t.noTransactions,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],

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
        softWrap: true,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= PARTNER TYPE SELECTOR =================
  Widget _partnerTypeSelector(AppStrings t) {
    final types = [
      {'title': t.farmers, 'img': 'assets/partner_types/farmer.png'},
      {'title': t.retailers, 'img': 'assets/partner_types/retailer.png'},
      {'title': t.wholesalers, 'img': 'assets/partner_types/wholesaler.png'},
      {'title': t.exporters, 'img': 'assets/partner_types/exporter.png'},
      {'title': t.foodProcessor, 'img': 'assets/partner_types/processor.png'},
    ];

    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        primary: false,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        itemBuilder: (context, i) {
          return Container(
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
                Image.asset(
                  types[i]['img']!,
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Text(
                  types[i]['title']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
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
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                t.walletBalance,
                textAlign: TextAlign.center,
                softWrap: true,
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

              // 🔥 WITHDRAW BUTTON – FINAL FIX
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                ),
                onPressed: wallet <= 0
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WithdrawRouterScreen(
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
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(t.daily)),
              Chip(label: Text(t.weekly)),
              Chip(label: Text(t.monthly)),
            ],
          ),
        ),
      ),
    );
  }

  // ================= EARNINGS =================
  Widget _earnings(AppStrings t, int today, int week, int month) {
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.currency_rupee),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '₹ $amount',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
