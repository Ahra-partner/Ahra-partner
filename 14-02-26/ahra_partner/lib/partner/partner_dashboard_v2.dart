import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';

import '../withdraw/withdraw_router_screen.dart';
import '../withdraw/partner_withdraw_history_screen.dart';
import '../partner/farmer_list_screen.dart';

class PartnerDashboardV2 extends StatelessWidget {
  final String partnerName;

  const PartnerDashboardV2({
    super.key,
    required this.partnerName,
  });

  static const primaryGreen = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFF66BB6A);
  static const accentOrange = Color(0xFFE67E22);
  static const bgColor = Color(0xFFF6F8F7);

  // ================= SAVE FCM TOKEN =================
  Future<void> _saveFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await FirebaseFirestore.instance
          .collection('partners')
          .doc(user.uid)
          .update({'fcmToken': token});
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveFcmToken();
    });

    final lang = context.watch<LanguageProvider>().lang;
    final t = AppStrings(lang);

    final String partnerId =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: bgColor,
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

          // 🔴 STATUS CHECK (NEW LOGIC)
          final String status =
              data['status'] ?? 'active';

          if (status == 'inactive') {
            return const Center(
              child: Text(
                'Your account is temporarily inactive.\nContact admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            );
          }

          // 🔥 RAW VALUES (100%)
          final int rawWallet =
              data['walletBalance'] ?? 0;
          final int rawToday =
              data['todayEarnings'] ?? 0;
          final int rawWeek =
              data['weekEarnings'] ?? 0;
          final int rawMonth =
              data['monthEarnings'] ?? 0;

          // ✅ DISPLAY VALUES (50%)
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
    ];

    return SizedBox(
      height: 135,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: items[i]['onTap']
                as VoidCallback?,
            child: Container(
              width: 120,
              margin:
                  const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(14),
                border:
                    Border.all(color: lightGreen),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Image.asset(
                    items[i]['img'] as String,
                    height: 42,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[i]['title'] as String,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _walletCard(
      BuildContext context,
      AppStrings t,
      int wallet) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: lightGreen,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16)),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                t.walletBalance,
                style: const TextStyle(
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '₹ $wallet',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                        backgroundColor:
                            accentOrange),
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

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PartnerWithdrawHistoryScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View Withdraw History',
                  style: TextStyle(
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentModeSelector(AppStrings t) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _earnings(
      AppStrings t,
      int today,
      int week,
      int month) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16),
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
        leading:
            const Icon(Icons.currency_rupee),
        title: Text(title),
        trailing: Text(
          '₹ $amount',
          style: const TextStyle(
              fontWeight:
                  FontWeight.bold),
        ),
      ),
    );
  }
}
