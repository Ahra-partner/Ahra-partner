import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';

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

    return Scaffold(
      backgroundColor: bgColor,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text('Ahra Partner'),
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
              // AuthRouter will handle navigation
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
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final location =
              '${data['district'] ?? ''}, ${data['state'] ?? ''}';
          final mobile = data['mobile'] ?? '';
          final wallet = data['walletBalance'] ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                _headerSection(partnerName, location, mobile),
                const SizedBox(height: 16),
                _partnerTypeSelector(),
                const SizedBox(height: 16),
                _profileAndWallet(context, wallet),
                const SizedBox(height: 16),
                _paymentModeSelector(),
                const SizedBox(height: 16),
                _earningsSection(data),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= HEADER =================
  Widget _headerSection(
      String name, String location, String mobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: primaryGreen,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $name 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                location,
                style:
                    const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                mobile,
                style:
                    const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= PARTNER TYPE =================
  Widget _partnerTypeSelector() {
    final types = [
      'Farmers',
      'Retailers',
      'Wholesalers',
      'Exporters',
      'Food Processor',
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: types.length,
        itemBuilder: (_, i) {
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lightGreen),
            ),
            child: Center(
              child: Text(
                types[i],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= PROFILE + WALLET =================
  Widget _profileAndWallet(
      BuildContext context, int wallet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // PROFILE CARD
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          AssetImage('assets/profile_dummy.png'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Partner',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.message),
                      label: const Text('Message'),
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content:
                                Text('Messaging coming soon'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // WALLET CARD
          Expanded(
            child: Card(
              color: lightGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Wallet Balance',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹ $wallet',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentOrange,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content:
                                Text('Withdraw screen coming soon'),
                          ),
                        );
                      },
                      child: const Text('Withdraw'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PAYMENT MODE =================
  Widget _paymentModeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Payment Mode',
                style:
                    TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Chip(label: Text('Daily')),
                  SizedBox(width: 8),
                  Chip(label: Text('Weekly')),
                  SizedBox(width: 8),
                  Chip(label: Text('Monthly')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= EARNINGS =================
  Widget _earningsSection(Map<String, dynamic> data) {
    final today = data['todayEarnings'] ?? 0;
    final week = data['weekEarnings'] ?? 0;
    final month = data['monthEarnings'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _earnCard('Today\'s Earnings', today),
          _earnCard('This Week\'s Earnings', week),
          _earnCard('This Month\'s Earnings', month),
        ],
      ),
    );
  }

  Widget _earnCard(String title, int amount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.currency_rupee),
        title: Text(title),
        trailing: Text(
          '₹ $amount',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
