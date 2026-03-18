import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_processor_subscription_screen.dart';

class ProcessorSubscriptionDetailsScreen extends StatelessWidget {
  final String processorId;
  final String subscriptionId;

  const ProcessorSubscriptionDetailsScreen({
    super.key,
    required this.processorId,
    required this.subscriptionId,
  });

  Future<void> _callProcessor(String mobile) async {
    final uri = Uri(scheme: 'tel', path: mobile);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _whatsAppProcessor(String mobile) async {
    final cleanPhone = mobile.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse("https://wa.me/91$cleanPhone");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {

    final processorRef =
        FirebaseFirestore.instance.collection('processors').doc(processorId);

    final subRef =
        processorRef.collection('subscriptions').doc(subscriptionId);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Processor Subscription Details')),
      body: FutureBuilder(
        future: Future.wait([processorRef.get(), subRef.get()]),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final processor =
              (snapshot.data![0] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

          final sub =
              (snapshot.data![1] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

          /// 🔥 START & EXPIRY DATE LOGIC
          DateTime? startDate;
          DateTime? expiryDate;

          if (sub['subscriptionStartDate'] != null) {
            startDate =
                (sub['subscriptionStartDate'] as Timestamp).toDate();
          }

          if (sub['subscriptionEndDate'] != null) {
            expiryDate =
                (sub['subscriptionEndDate'] as Timestamp).toDate();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              _section('Processor Details'),
              _row('Name', processor['name'] ?? '-'),
              _row('Mobile', processor['mobile'] ?? '-'),
              _row('Mandal', processor['mandal'] ?? '-'),
              _row('District', processor['district'] ?? '-'),
              _row('State', processor['state'] ?? '-'),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('Call Processor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () =>
                    _callProcessor(processor['mobile']),
              ),

              const SizedBox(height: 8),

              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('WhatsApp Processor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                ),
                onPressed: () =>
                    _whatsAppProcessor(processor['mobile']),
              ),

              const SizedBox(height: 16),

              _section('Subscription Details'),

              _row('Month', sub['month'] ?? '-'),

              /// ✅ NEW ROWS ADDED
              _row(
                'Start Date',
                startDate != null
                    ? "${startDate.day}-${startDate.month}-${startDate.year}"
                    : '-',
              ),

              _row(
                'Expiry Date',
                expiryDate != null
                    ? "${expiryDate.day}-${expiryDate.month}-${expiryDate.year}"
                    : '-',
              ),

              _row('Amount', '₹ ${sub['amount'] ?? 0}'),

              _row('Reference No', sub['transactionNo'] ?? '-'),

              const SizedBox(height: 10),

              const Text(
                "Services",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              if ((sub['services'] ?? []).isEmpty)
                const Text("-")
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (sub['services'] as List)
                      .map<Widget>((s) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "${s['name']} - ${s['quantity']} ${s['unit']}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 10),

              _row('Status', sub['status'] ?? '-'),

              const SizedBox(height: 24),

              /// 🔥 ONLY EDIT BUTTON (Mark as Paid removed)
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
                          EditProcessorSubscriptionScreen(
                        processorId: processorId,
                        subscriptionId: subscriptionId,
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
                style: const TextStyle(
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
}