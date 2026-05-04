import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// 🔥 IMPORT EDIT SCREEN
import 'edit_farmer_subscription_screen.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  final String farmerId;
  final String subscriptionId;

  const SubscriptionDetailsScreen({
    super.key,
    required this.farmerId,
    required this.subscriptionId,
  });

  Future<void> _callFarmer(String mobile) async {
    final uri = Uri(scheme: 'tel', path: mobile);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _whatsAppFarmer(String mobile) async {
    final cleanPhone = mobile.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse("https://wa.me/91$cleanPhone");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ✅ DATE FORMAT
  String formatDate(Timestamp? t) {
    if (t == null) return "-";
    final d = t.toDate();
    return "${d.day}-${d.month}-${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final farmerRef =
        FirebaseFirestore.instance.collection('farmers').doc(farmerId);

    final subRef =
        farmerRef.collection('subscriptions').doc(subscriptionId);

    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Subscription Details')),
      body: FutureBuilder(
        future: Future.wait([farmerRef.get(), subRef.get()]),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final farmer =
              (snapshot.data![0] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

          final sub =
              (snapshot.data![1] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

          // ✅ START DATE
          final Timestamp? startDate =
              sub['subscriptionStartDate'] ?? sub['createdAt'];

          // 🔥 EXPIRY CALCULATION
          Timestamp? startTs =
              sub['subscriptionStartDate'] ?? sub['createdAt'];

          DateTime? expiryCalculated;

          if (startTs != null) {
            final start = startTs.toDate();

            final nextMonth =
                start.month == 12 ? 1 : start.month + 1;
            final nextYear =
                start.month == 12 ? start.year + 1 : start.year;

            final lastDay =
                DateTime(nextYear, nextMonth + 1, 0).day;

            final safeDay =
                start.day > lastDay ? lastDay : start.day;

            expiryCalculated =
                DateTime(nextYear, nextMonth, safeDay);
          }

          List products = sub['products'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              _section('Farmer Details'),
              _row('Name', farmer['farmerName'] ?? '-'),
              _row('Mobile', farmer['mobile'] ?? '-'),
              _row('Village', farmer['village'] ?? '-'),
              _row('Mandal', farmer['mandal'] ?? '-'),
              _row('District', farmer['district'] ?? '-'),
              _row('State', farmer['state'] ?? '-'),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('Call Farmer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () =>
                    _callFarmer(farmer['mobile']),
              ),

              const SizedBox(height: 8),

              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('WhatsApp Farmer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                ),
                onPressed: () =>
                    _whatsAppFarmer(farmer['mobile']),
              ),

              const SizedBox(height: 16),

              _section('Subscription Details'),

              _row('Month', sub['month'] ?? '-'),

              // ✅ START DATE
              _row(
                'Start Date',
                formatDate(startDate),
              ),

              // 🔥 EXPIRY DATE
              _row(
                'Expiry Date',
                expiryCalculated != null
                    ? "${expiryCalculated.day}-${expiryCalculated.month}-${expiryCalculated.year}"
                    : '-',
              ),

              _row('Amount', '₹ ${sub['amount'] ?? 0}'),
              _row('Transaction No', sub['transactionNo'] ?? '-'),

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
                          EditFarmerSubscriptionScreen(
                        farmerId: farmerId,
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