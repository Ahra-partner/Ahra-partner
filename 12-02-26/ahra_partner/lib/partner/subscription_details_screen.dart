import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  final String farmerId;
  final String subscriptionId;

  const SubscriptionDetailsScreen({
    super.key,
    required this.farmerId,
    required this.subscriptionId,
  });

  // 📞 Call Farmer Function
  Future<void> _callFarmer(String mobile) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: mobile,
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch dialer';
    }
  }

  // 💬 WhatsApp Farmer Function
  Future<void> _whatsAppFarmer(String mobile) async {
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/91$mobile?text=Hello%20Farmer',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmerRef =
        FirebaseFirestore.instance.collection('farmers').doc(farmerId);

    final subRef =
        farmerRef.collection('subscriptions').doc(subscriptionId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Details'),
      ),
      body: FutureBuilder(
        future: Future.wait([
          farmerRef.get(),
          subRef.get(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final farmer =
              (snapshot.data![0] as DocumentSnapshot).data()
                  as Map<String, dynamic>;
          final sub =
              (snapshot.data![1] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

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

              // 📞 Call Farmer Button
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('Call Farmer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  _callFarmer(farmer['mobile']);
                },
              ),

              // 💬 WhatsApp Farmer Button
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('WhatsApp Farmer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF25D366),
                ),
                onPressed: () {
                  _whatsAppFarmer(farmer['mobile']);
                },
              ),

              const SizedBox(height: 16),

              _section('Subscription Details'),
              _row('Month', sub['month'] ?? '-'),
              _row('Category', sub['category'] ?? '-'),
              _row('Product', sub['product'] ?? '-'),
              _row(
                'Quantity',
                '${sub['quantity'] ?? 0} ${sub['unit'] ?? ''}',
              ),
              _row('Amount', '₹ ${sub['amount'] ?? 0}'),
              _row('Transaction', sub['transactionNo'] ?? '-'),
              _row('Status', sub['status'] ?? '-'),

              const SizedBox(height: 24),

              if (sub['status'] != 'paid')
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Paid'),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('farmers')
                        .doc(farmerId)
                        .collection('subscriptions')
                        .doc(subscriptionId)
                        .update({
                      'status': 'paid',
                      'paidAt': FieldValue.serverTimestamp(),
                      'paidBy':
                          FirebaseAuth.instance.currentUser!.uid,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Marked as Paid'),
                      ),
                    );

                    Navigator.pop(context);
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
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(k),
            ),
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
