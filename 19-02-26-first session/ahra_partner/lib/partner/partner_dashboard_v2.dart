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
import '../partner/retailer_list_screen.dart';
import '../partner/wholesaler_list_screen.dart';
import '../partner/processor_list_screen.dart';
import '../partner/exporter_list_screen.dart';

import 'partner_wallet_screen.dart';
import 'partner_profile_screen.dart';
import 'partner_id_card_screen.dart'; // ✅ NEW IMPORT

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

          // 🌍 Language
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

          // 🪪 Digital ID Card (NEW)
          IconButton(
            icon: const Icon(Icons.badge),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PartnerIdCardScreen(),
                ),
              );
            },
          ),

          // 👤 Profile
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PartnerProfileScreen(),
                ),
              );
            },
          ),

          // 🚪 Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

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

          final int wallet =
              ((data['walletBalance'] ?? 0) / 2).round();

          final int today =
              ((data['todayEarnings'] ?? 0) / 2).round();

          final int week =
              ((data['weekEarnings'] ?? 0) / 2).round();

          final int month =
              ((data['monthEarnings'] ?? 0) / 2).round();

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

                _paymentModeSelector(context, t),
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
        'screen': const FarmerListScreen(),
      },
      {
        'title': 'Retailers',
        'img': 'assets/partner_types/retailer.png',
        'screen': const RetailerListScreen(),
      },
      {
        'title': 'Wholesalers',
        'img': 'assets/partner_types/wholesaler.png',
        'screen': const WholesalerListScreen(),
      },
      {
        'title': 'Processors',
        'img': 'assets/partner_types/processor.png',
        'screen': const ProcessorListScreen(),
      },
      {
        'title': 'Exporters',
        'img': 'assets/partner_types/exporter.png',
        'screen': const ExporterListScreen(),
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      items[i]['screen'] as Widget,
                ),
              );
            },
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

  Widget _paymentModeSelector(
      BuildContext context, AppStrings t) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 10,
        children: [
          ActionChip(
            label: Text(t.daily),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PartnerWalletScreen(
                    initialType: StatsType.daily,
                  ),
                ),
              );
            },
          ),
          ActionChip(
            label: Text(t.weekly),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PartnerWalletScreen(
                    initialType: StatsType.weekly,
                  ),
                ),
              );
            },
          ),
          ActionChip(
            label: Text(t.monthly),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PartnerWalletScreen(
                    initialType: StatsType.monthly,
                  ),
                ),
              );
            },
          ),
        ],
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
            ],
          ),
        ),
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
