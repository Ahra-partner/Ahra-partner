import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// 🔥 IMPORT EDIT SCREEN
import 'edit_wholesaler_subscription_screen.dart';

class WholesalerSubscriptionDetailsScreen extends StatelessWidget {
  final String wholesalerId;
  final String subscriptionId;

  const WholesalerSubscriptionDetailsScreen({
    super.key,
    required this.wholesalerId,
    required this.subscriptionId,
  });

  Future<void> _callWholesaler(String mobile) async {
    final uri = Uri(scheme: 'tel', path: mobile);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _whatsAppWholesaler(String mobile) async {
    final cleanPhone = mobile.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse("https://wa.me/91$cleanPhone");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {

    final wholesalerRef =
        FirebaseFirestore.instance.collection('wholesalers').doc(wholesalerId);

    final subRef =
        wholesalerRef.collection('subscriptions').doc(subscriptionId);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Wholesaler Subscription Details')),
      body: FutureBuilder(
        future: Future.wait([wholesalerRef.get(), subRef.get()]),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final wholesaler =
              (snapshot.data![0] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

          final sub =
              (snapshot.data![1] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

          /// 🔥 START DATE (same logic)
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

          List products = sub['products'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              _section('Wholesaler Details'),
              _row('Name', wholesaler['name'] ?? '-'),
              _row('Mobile', wholesaler['mobile'] ?? '-'),
              _row('Mandal', wholesaler['mandal'] ?? '-'),
              _row('District', wholesaler['district'] ?? '-'),
              _row('State', wholesaler['state'] ?? '-'),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('Call Wholesaler'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () =>
                    _callWholesaler(wholesaler['mobile']),
              ),

              const SizedBox(height: 8),

              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('WhatsApp Wholesaler'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                ),
                onPressed: () =>
                    _whatsAppWholesaler(wholesaler['mobile']),
              ),

              const SizedBox(height: 16),

              _section('Subscription Details'),

              _row('Month', sub['month'] ?? '-'),

              /// ✅ START DATE
              _row(
                'Start Date',
                startDate != null
                    ? "${startDate.day}-${startDate.month}-${startDate.year}"
                    : '-',
              ),

              /// 🔥 EXPIRY DATE (AUTO FIXED)
              _row(
                'Expiry Date',
                expiryCalculated != null
                    ? "${expiryCalculated.day}-${expiryCalculated.month}-${expiryCalculated.year}"
                    : '-',
              ),

              _row('Amount', '₹ ${sub['amount'] ?? 0}'),
              _row('Reference No', sub['referenceNumber'] ?? '-'),

              const SizedBox(height: 10),

              const Text(
                "Products",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              if (products.isEmpty)
                const Text("-")
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: products.map<Widget>((p) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
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

              // ✅ ONLY EDIT BUTTON
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
                          EditWholesalerSubscriptionScreen(
                        wholesalerId: wholesalerId,
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
              fontSize: 16,
              fontWeight: FontWeight.bold),
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