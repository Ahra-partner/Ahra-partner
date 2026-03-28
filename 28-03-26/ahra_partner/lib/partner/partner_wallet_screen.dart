import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'partner_wallet_ledger_screen.dart';

enum StatsType { daily, weekly, monthly }

class PartnerWalletScreen extends StatefulWidget {
  final StatsType initialType;

  const PartnerWalletScreen({
    super.key,
    required this.initialType,
  });

  @override
  State<PartnerWalletScreen> createState() =>
      _PartnerWalletScreenState();
}

class _PartnerWalletScreenState
    extends State<PartnerWalletScreen> {

  late StatsType selectedType;

  DateTime? fromDate;
  DateTime? toDate;

  int weekOffset = 0; // 🔥 weekly navigation

  double rangeTotal = 0;
  bool isLoading = false;

  List<Map<String, dynamic>> monthlyList = [];

  @override
  void initState() {
    super.initState();

    selectedType = widget.initialType;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {

        if (selectedType == StatsType.daily) {
          _pickDateRange(user.uid);
        } else if (selectedType == StatsType.weekly) {
          _loadWeekly(user.uid);
        } else {
          _loadMonthly(user.uid);
        }
      }
    });
  }

  // ================= DAILY =================

  Future<void> _pickDateRange(String partnerId) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    fromDate = picked.start;
    toDate = picked.end;

    await _calculateRangeTotal(partnerId);
  }

  // ================= COMMON RANGE CALC =================

  Future<void> _calculateRangeTotal(String partnerId) async {

    if (fromDate == null || toDate == null) return;

    setState(() => isLoading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('wallet_ledger')
        .where('partnerId', isEqualTo: partnerId)
        .get();

    double total = 0;

    for (var doc in snapshot.docs) {

      final data = doc.data();

      if (data['createdAt'] == null) continue;

      final date =
          (data['createdAt'] as Timestamp).toDate();

      if (date.isAfter(
              fromDate!.subtract(const Duration(seconds: 1))) &&
          date.isBefore(
              toDate!.add(const Duration(days: 1)))) {

        final direction = data['direction'];
        final amount =
            (data['amount'] ?? 0).toDouble();

        if (direction == 'credit') {
          total += amount;
        } else {
          total -= amount;
        }
      }
    }

    setState(() {
      rangeTotal = total;
      isLoading = false;
    });
  }

  // ================= WEEKLY =================

  Future<void> _loadWeekly(String partnerId) async {

    final now = DateTime.now();

    final currentWeekStart =
        now.subtract(Duration(days: now.weekday - 1));

    final start =
        currentWeekStart.add(Duration(days: weekOffset * 7));

    final end = start.add(const Duration(days: 6));

    fromDate = DateTime(start.year, start.month, start.day);
    toDate = DateTime(end.year, end.month, end.day);

    await _calculateRangeTotal(partnerId);
  }

  // ================= MONTHLY =================

  Future<void> _loadMonthly(String partnerId) async {

    setState(() {
      isLoading = true;
      monthlyList = [];
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('wallet_ledger')
        .where('partnerId', isEqualTo: partnerId)
        .get();

    Map<String, double> monthTotals = {};

    for (var doc in snapshot.docs) {

      final data = doc.data();

      if (data['createdAt'] == null) continue;

      DateTime date =
          (data['createdAt'] as Timestamp).toDate();

      String key =
          DateFormat('MMM yyyy').format(date);

      final direction = data['direction'];
      final amount =
          (data['amount'] ?? 0).toDouble();

      monthTotals.putIfAbsent(key, () => 0);

      if (direction == 'credit') {
        monthTotals[key] =
            monthTotals[key]! + amount;
      } else {
        monthTotals[key] =
            monthTotals[key]! - amount;
      }
    }

    monthlyList = monthTotals.entries
        .map((e) => {
              "month": e.key,
              "amount": e.value,
            })
        .toList();

    setState(() => isLoading = false);
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Analytics'),
        centerTitle: true,
      ),
      body: StreamBuilder<User?>(
        stream:
            FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {

          if (!authSnapshot.hasData) {
            return const Center(
                child: Text('User not logged in'));
          }

          final partnerId =
              authSnapshot.data!.uid;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                if (isLoading)
                  const CircularProgressIndicator()

                else if (selectedType ==
                    StatsType.monthly)

                  // 🔥 MONTHLY LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: monthlyList.length,
                      itemBuilder: (context, i) {

                        return Card(
                          child: ListTile(
                            title: Text(
                                monthlyList[i]['month']),
                            trailing: Text(
                                "₹ ${monthlyList[i]['amount']}"),
                            onTap: () {

                              // 🔥 Month click → ledger filter
                              final monthDate =
                                  DateFormat('MMM yyyy')
                                      .parse(
                                monthlyList[i]['month'],
                              );

                              final start = DateTime(
                                  monthDate.year,
                                  monthDate.month, 1);

                              final end = DateTime(
                                  monthDate.year,
                                  monthDate.month + 1, 0);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PartnerWalletLedgerScreen(
                                    partnerId: partnerId,
                                    fromDate: start,
                                    toDate: end,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  )

                else

                  // 🔥 DAILY / WEEKLY VIEW
                  Column(
                    children: [

                      if (selectedType ==
                          StatsType.weekly)

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [

                            IconButton(
                              icon: const Icon(
                                  Icons.arrow_back),
                              onPressed: () async {
                                weekOffset--;
                                await _loadWeekly(
                                    partnerId);
                              },
                            ),

                            Text(
                              "${DateFormat('dd MMM').format(fromDate!)} → ${DateFormat('dd MMM yyyy').format(toDate!)}",
                              style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold),
                            ),

                            IconButton(
                              icon: const Icon(
                                  Icons.arrow_forward),
                              onPressed: () async {
                                weekOffset++;
                                await _loadWeekly(
                                    partnerId);
                              },
                            ),
                          ],
                        )
                      else if (fromDate != null)
                        Text(
                          "${DateFormat('dd MMM yyyy').format(fromDate!)} → ${DateFormat('dd MMM yyyy').format(toDate!)}",
                        ),

                      const SizedBox(height: 15),

                      Text(
                        "Total: ₹ $rangeTotal",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // 🔥 FILTERED LEDGER
                OutlinedButton.icon(
                  icon: const Icon(Icons.list),
                  label:
                      const Text('View Wallet Ledger'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PartnerWalletLedgerScreen(
                          partnerId: partnerId,
                          fromDate: fromDate,
                          toDate: toDate,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
