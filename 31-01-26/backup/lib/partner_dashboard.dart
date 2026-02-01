import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'language_provider.dart';
import 'app_strings.dart';
import 'language_screen.dart';
import 'partner_earnings_history.dart';

/// =====================
/// DATE KEY HELPERS
/// =====================
String _todayKey() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

List<String> _weekKeys() {
  final now = DateTime.now();
  final diff = now.weekday % 7; // Sunday = 0
  final sunday = now.subtract(Duration(days: diff));

  return List.generate(7, (i) {
    final d = sunday.add(Duration(days: i));
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  });
}

String _monthPrefix() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}';
}

/// =====================
/// PARTNER DASHBOARD
/// =====================
class PartnerDashboard extends StatefulWidget {
  final String partnerName;
  final String partnerId;

  const PartnerDashboard({
    super.key,
    required this.partnerName,
    required this.partnerId,
  });

  @override
  State<PartnerDashboard> createState() => _PartnerDashboardState();
}

class _PartnerDashboardState extends State<PartnerDashboard> {
  /// =====================
  /// TODAY
  /// =====================
  Stream<int> todayEarningsStream() {
    final today = _todayKey();

    return FirebaseFirestore.instance
        .collection('wallet_ledger')
        .where('partnerId', isEqualTo: widget.partnerId)
        .where('direction', isEqualTo: 'credit')
        .where('dateKey', isEqualTo: today)
        .snapshots()
        .map((snap) {
      return snap.docs.fold<int>(
        0,
        (sum, d) => sum + ((d.data()['amount'] ?? 0) as int),
      );
    });
  }

  /// =====================
  /// WEEK
  /// =====================
  Stream<int> weekEarningsStream() {
    final weekDates = _weekKeys();

    return FirebaseFirestore.instance
        .collection('wallet_ledger')
        .where('partnerId', isEqualTo: widget.partnerId)
        .where('direction', isEqualTo: 'credit')
        .where('dateKey', whereIn: weekDates)
        .snapshots()
        .map((snap) {
      return snap.docs.fold<int>(
        0,
        (sum, d) => sum + ((d.data()['amount'] ?? 0) as int),
      );
    });
  }

  /// =====================
  /// MONTH
  /// =====================
  Stream<int> monthEarningsStream() {
    final prefix = _monthPrefix();

    return FirebaseFirestore.instance
        .collection('wallet_ledger')
        .where('partnerId', isEqualTo: widget.partnerId)
        .where('direction', isEqualTo: 'credit')
        .where('dateKey', isGreaterThanOrEqualTo: '$prefix-01')
        .where('dateKey', isLessThanOrEqualTo: '$prefix-31')
        .snapshots()
        .map((snap) {
      return snap.docs.fold<int>(
        0,
        (sum, d) => sum + ((d.data()['amount'] ?? 0) as int),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final s = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(s.get('dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LanguageScreen(fromSettings: true),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${s.get('welcome')}, ${widget.partnerName} 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _earningsCard(
              title: s.get('today_earnings'),
              stream: todayEarningsStream(),
            ),
            _earningsCard(
              title: s.get('week_earnings'),
              stream: weekEarningsStream(),
            ),
            _earningsCard(
              title: s.get('month_earnings'),
              stream: monthEarningsStream(),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: const Text('View Earnings History'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PartnerEarningsHistory(
                      partnerId: widget.partnerId,
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            /// 🔴 LOGOUT (FIXED)
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: Text(s.get('logout')),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // AuthRouter will auto redirect
              },
            ),
          ],
        ),
      ),
    );
  }

  /// =====================
  /// EARNINGS CARD
  /// =====================
  Widget _earningsCard({
    required String title,
    required Stream<int> stream,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: StreamBuilder<int>(
        stream: stream,
        builder: (_, snap) {
          final amount = snap.data ?? 0;

          return ListTile(
            leading: const Icon(Icons.currency_rupee),
            title: Text(title),
            trailing: Text(
              '₹ $amount',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
