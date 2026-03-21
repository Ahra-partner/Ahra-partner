import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_exporter_subscription_screen.dart';

class ExporterSubscriptionDetailsScreen extends StatefulWidget {
  final String exporterId;
  final String subscriptionId;

  const ExporterSubscriptionDetailsScreen({
    super.key,
    required this.exporterId,
    required this.subscriptionId,
  });

  @override
  State<ExporterSubscriptionDetailsScreen> createState() =>
      _ExporterSubscriptionDetailsScreenState();
}

class _ExporterSubscriptionDetailsScreenState
    extends State<ExporterSubscriptionDetailsScreen> {

  Future<void> _callExporter(String mobile) async {
    final uri = Uri(scheme: 'tel', path: mobile);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _whatsAppExporter(String mobile) async {
    final cleanPhone = mobile.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse("https://wa.me/91$cleanPhone");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {

    final exporterRef =
        FirebaseFirestore.instance.collection('exporters').doc(widget.exporterId);

    final subRef =
        exporterRef.collection('subscriptions').doc(widget.subscriptionId);

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

          /// 🔥 START DATE (same as before)
          DateTime? startDate;

          if (sub['subscriptionStartDate'] != null) {
            startDate =
                (sub['subscriptionStartDate'] as Timestamp).toDate();
          } else if (sub['createdAt'] != null) {
            startDate =
                (sub['createdAt'] as Timestamp).toDate();
          }

          /// 🔥 AUTO CALCULATE EXPIRY (MAIN FIX)
          DateTime? expiryCalculated;

          if (startDate != null) {
            final nextMonth =
                startDate.month == 12 ? 1 : startDate.month + 1;
            final nextYear =
                startDate.month == 12 ? startDate.year + 1 : startDate.year;

            final lastDay =
                DateTime(nextYear, nextMonth + 1, 0).day;

            final safeDay =
                startDate.day > lastDay ? lastDay : startDate.day;

            expiryCalculated =
                DateTime(nextYear, nextMonth, safeDay);
          }

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

              _row(
                'Start Date',
                startDate != null
                    ? "${startDate.day}-${startDate.month}-${startDate.year}"
                    : '-',
              ),

              _row(
                'Expiry Date',
                expiryCalculated != null
                    ? "${expiryCalculated.day}-${expiryCalculated.month}-${expiryCalculated.year}"
                    : '-',
              ),

              _row('Amount', '₹ ${sub['amount'] ?? 0}'),

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

              // 🔥 ONLY EDIT BUTTON
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
                        exporterId: widget.exporterId,
                        subscriptionId: widget.subscriptionId,
                      ),
                    ),
                  );
                },
              ),
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