import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PartnerEarningsHistory extends StatefulWidget {
  final String partnerId;

  const PartnerEarningsHistory({
    super.key,
    required this.partnerId,
  });

  @override
  State<PartnerEarningsHistory> createState() =>
      _PartnerEarningsHistoryState();
}

class _PartnerEarningsHistoryState
    extends State<PartnerEarningsHistory> {
  DateTime? _startDate;
  DateTime? _endDate;

  /// 📅 Pick start / end date
  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate =
              DateTime(picked.year, picked.month, picked.day);
        } else {
          _endDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            23,
            59,
            59,
          );
        }
      });
    }
  }

  /// 🔥 Firestore query (ledger = source of truth)
  Query<Map<String, dynamic>> _query() {
    Query<Map<String, dynamic>> q = FirebaseFirestore.instance
        .collection('wallet_ledger')
        .where('partnerId', isEqualTo: widget.partnerId)
        .orderBy('createdAt', descending: true);

    if (_startDate != null) {
      q = q.where(
        'createdAt',
        isGreaterThanOrEqualTo:
            Timestamp.fromDate(_startDate!),
      );
    }

    if (_endDate != null) {
      q = q.where(
        'createdAt',
        isLessThanOrEqualTo:
            Timestamp.fromDate(_endDate!),
      );
    }

    return q;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// 📅 Date filters
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(isStart: true),
                    child: Text(
                      _startDate == null
                          ? 'From Date'
                          : DateFormat('dd MMM yyyy')
                              .format(_startDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(isStart: false),
                    child: Text(
                      _endDate == null
                          ? 'To Date'
                          : DateFormat('dd MMM yyyy')
                              .format(_endDate!),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// 📃 Ledger list + totals
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: (_startDate == null || _endDate == null)
                    ? null
                    : _query().snapshots(),
                builder: (context, snapshot) {
                  if (_startDate == null || _endDate == null) {
                    return const Center(
                      child: Text(
                        'Select date range to view history',
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No records found'),
                    );
                  }

                  int totalCredit = 0;
                  int totalDebit = 0;

                  for (final d in docs) {
                    final data =
                        d.data() as Map<String, dynamic>;
                    final amount = data['amount'] ?? 0;
                    final direction = data['direction'];

                    if (direction == 'credit') {
                      totalCredit += amount as int;
                    } else if (direction == 'debit') {
                      totalDebit += amount as int;
                    }
                  }

                  return Column(
                    children: [
                      /// 💰 Summary card
                      Card(
                        color: Colors.blue.shade50,
                        child: ListTile(
                          title: const Text(
                            'Summary',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Credit: ₹ $totalCredit\nDebit: ₹ $totalDebit',
                          ),
                          trailing: Text(
                            'Net: ₹ ${totalCredit - totalDebit}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 📃 Ledger list
                      Expanded(
                        child: ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (_, i) {
                            final data = docs[i].data()
                                as Map<String, dynamic>;

                            final amount = data['amount'] ?? 0;
                            final direction = data['direction'];
                            final ts =
                                data['createdAt'] as Timestamp?;
                            final date = ts?.toDate();

                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  direction == 'credit'
                                      ? Icons.add
                                      : Icons.remove,
                                  color: direction == 'credit'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(
                                  '₹ $amount',
                                  style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold),
                                ),
                                subtitle: Text(
                                  date == null
                                      ? ''
                                      : DateFormat(
                                              'dd MMM yyyy, hh:mm a')
                                          .format(date),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
