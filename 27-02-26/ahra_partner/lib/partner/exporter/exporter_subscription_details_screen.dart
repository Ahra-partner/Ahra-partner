import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_exporter_subscription_screen.dart';

class ExporterSubscriptionDetailsScreen extends StatelessWidget {
  final String exporterId;
  final String subscriptionId;

  const ExporterSubscriptionDetailsScreen({
    super.key,
    required this.exporterId,
    required this.subscriptionId,
  });

  Future<void> _callExporter(String mobile) async {
    final uri = Uri(scheme: 'tel', path: mobile);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _whatsAppExporter(String mobile) async {
    final cleanPhone = mobile.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse("https://wa.me/91$cleanPhone");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> markAsPaid() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final exporterRef =
        FirebaseFirestore.instance.collection('exporters').doc(exporterId);

    final subRef =
        exporterRef.collection('subscriptions').doc(subscriptionId);

    final partnerRef =
        FirebaseFirestore.instance.collection('partners').doc(uid);

    final ledgerRef =
        FirebaseFirestore.instance.collection('wallet_ledger');

    final today = DateTime.now();
    final endDate =
        DateTime(today.year, today.month + 1, today.day);

    final dayId =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    await FirebaseFirestore.instance.runTransaction((tx) async {

      final subSnap = await tx.get(subRef);

      if (!subSnap.exists) throw 'Subscription not found';
      if (subSnap['status'] == 'paid') throw 'Already paid';

      final int amount = subSnap['amount'];
      final int partnerShare = (amount * 30 ~/ 100);

      tx.update(subRef, {
        'status': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
        'paidBy': uid,
      });

      tx.set(
        exporterRef,
        {
          'lastPaidDate': FieldValue.serverTimestamp(),
          'subscriptionEndDate': endDate,
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      tx.set(
        partnerRef,
        {
          'walletBalance': FieldValue.increment(partnerShare),
          'todayEarnings': FieldValue.increment(partnerShare),
          'weekEarnings': FieldValue.increment(partnerShare),
          'monthEarnings': FieldValue.increment(partnerShare),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      tx.set(ledgerRef.doc(), {
        'partnerId': uid,
        'amount': partnerShare,
        'direction': 'credit',
        'type': 'exporter_subscription_commission',
        'description': 'Exporter subscription commission',
        'exporterId': exporterId,
        'subscriptionId': subscriptionId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.set(
        FirebaseFirestore.instance
            .collection('daily_stats')
            .doc('${dayId}_$uid'),
        {
          'partnerId': uid,
          'date': dayId,
          'amount': FieldValue.increment(partnerShare),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    final exporterRef =
        FirebaseFirestore.instance.collection('exporters').doc(exporterId);

    final subRef =
        exporterRef.collection('subscriptions').doc(subscriptionId);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Exporter Subscription Details')),
      body: FutureBuilder(
        future: Future.wait([exporterRef.get(), subRef.get()]),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final exporter =
              (snapshot.data![0] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

          final sub =
              (snapshot.data![1] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              _section('Exporter Details'),
              _row('Name', exporter['name'] ?? '-'),
              _row('Mobile', exporter['mobile'] ?? '-'),
              _row('Mandal', exporter['mandal'] ?? '-'),
              _row('District', exporter['district'] ?? '-'),
              _row('State', exporter['state'] ?? '-'),

              const SizedBox(height: 16),

              _section('Subscription Details'),
              _row('Month', sub['month'] ?? '-'),
              _row('Amount', '₹ ${sub['amount'] ?? 0}'),
              _row('Reference No', sub['transactionNo'] ?? '-'),

              const SizedBox(height: 10),

              const Text(
                "Products",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              if ((sub['products'] ?? []).isEmpty)
                const Text("-")
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (sub['products'] as List)
                      .map<Widget>((p) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "${p['name']} - ${p['quantity']} ${p['unit']}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 10),

              _row('Status', sub['status'] ?? '-'),

              const SizedBox(height: 24),

              if (sub['status'] != 'paid') ...[

                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Paid'),
                  onPressed: () async {
                    try {
                      await markAsPaid();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Payment confirmed & wallet credited'),
                        ),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ERROR: $e')),
                      );
                    }
                  },
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Subscription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditExporterSubscriptionScreen(
                          exporterId: exporterId,
                          subscriptionId: subscriptionId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(k)),
            Expanded(
              flex: 3,
              child: Text(
                v,
                style:
                    const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
}