import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final uri =
        Uri.parse("https://wa.me/91$cleanPhone?text=Hello%20Farmer");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

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
      appBar: AppBar(title: const Text('Subscription Details')),
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

          final Timestamp? subDate = sub['subscriptionDate'];
          final Timestamp? expDate = sub['expiryDate'];

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
                onPressed: () => _callFarmer(farmer['mobile']),
              ),

              const SizedBox(height: 8),

              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('WhatsApp Farmer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                ),
                onPressed: () => _whatsAppFarmer(farmer['mobile']),
              ),

              const SizedBox(height: 16),

              _section('Subscription Details'),

              _row(
                'Subscription Date',
                formatDate(subDate),
              ),

              _row(
                'Expiry Date',
                formatDate(expDate),
              ),

              _row('Amount', '₹ ${sub['amount'] ?? 0}'),
              _row('Transaction', sub['transactionNo'] ?? '-'),
              _row('Status', sub['status'] ?? '-'),

              const SizedBox(height: 24),

              if (sub['status'] != 'paid')
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Subscription'),
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
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
}