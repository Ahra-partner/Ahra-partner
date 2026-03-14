import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// 🔥 IMPORT EDIT SCREEN
import 'edit_retailer_subscription_screen.dart';

class RetailerSubscriptionDetailsScreen extends StatelessWidget {
  final String retailerId;
  final String subscriptionId;

  const RetailerSubscriptionDetailsScreen({
    super.key,
    required this.retailerId,
    required this.subscriptionId,
  });

  Future<void> _callRetailer(String mobile) async {
    final uri = Uri(scheme: 'tel', path: mobile);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _whatsAppRetailer(String mobile) async {
    final cleanPhone = mobile.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse("https://wa.me/91$cleanPhone");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final retailerRef =
        FirebaseFirestore.instance.collection('retailers').doc(retailerId);

    final subRef =
        retailerRef.collection('subscriptions').doc(subscriptionId);

    return Scaffold(
      appBar: AppBar(title: const Text('Retailer Subscription Details')),
      body: FutureBuilder(
        future: Future.wait([retailerRef.get(), subRef.get()]),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final retailer =
              (snapshot.data![0] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

          final sub =
              (snapshot.data![1] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

          /// 🔥 NEW: START & EXPIRY DATE LOGIC
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

          List products = sub['products'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              _section('Retailer Details'),
              _row('Name', retailer['name'] ?? '-'),
              _row('Mobile', retailer['mobile'] ?? '-'),
              _row('Mandal', retailer['mandal'] ?? '-'),
              _row('District', retailer['district'] ?? '-'),
              _row('State', retailer['state'] ?? '-'),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('Call Retailer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () =>
                    _callRetailer(retailer['mobile']),
              ),

              const SizedBox(height: 8),

              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('WhatsApp Retailer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                ),
                onPressed: () =>
                    _whatsAppRetailer(retailer['mobile']),
              ),

              const SizedBox(height: 16),

              _section('Subscription Details'),

              _row('Month', sub['month'] ?? '-'),

              /// 🔥 NEW ROWS
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
                          EditRetailerSubscriptionScreen(
                        retailerId: retailerId,
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