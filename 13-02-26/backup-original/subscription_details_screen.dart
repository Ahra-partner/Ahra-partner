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

  // 📞 Call Farmer
  Future<void> _callFarmer(String mobile) async {
    final uri = Uri(scheme: 'tel', path: mobile);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // 💬 WhatsApp Farmer
  Future<void> _whatsAppFarmer(String mobile) async {
    final uri =
        Uri.parse('https://wa.me/91$mobile?text=Hello%20Farmer');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ✅ FINAL MARK AS PAID (WALLET + LEDGER + STATS)
  Future<void> markAsPaid() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final farmerRef =
        FirebaseFirestore.instance.collection('farmers').doc(farmerId);

    final subRef =
        farmerRef.collection('subscriptions').doc(subscriptionId);

    final partnerRef =
        FirebaseFirestore.instance.collection('partners').doc(uid);

    final ledgerRef =
        FirebaseFirestore.instance.collection('wallet_ledger');

    final today = DateTime.now();
    final dayId =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    await FirebaseFirestore.instance.runTransaction((tx) async {
final subSnap = await tx.get(subRef);
if (!subSnap.exists) {
  throw 'Subscription not found';
}

// 🔒 BLOCK DOUBLE CREDIT
if (subSnap['status'] == 'paid') {
  throw 'Already paid';
}

      final int amount = subSnap['amount'];
      final int partnerShare = (amount * 0.5).round();

      // 1️⃣ Mark subscription as PAID
      tx.update(subRef, {
        'status': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
        'paidBy': uid,
      });

      // 2️⃣ Credit partner wallet + earnings
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

      // 3️⃣ Wallet ledger entry
      tx.set(ledgerRef.doc(), {
        'partnerId': uid,
        'amount': partnerShare,
        'direction': 'credit',
        'type': 'subscription_commission',
        'description': 'Farmer subscription commission',
        'farmerId': farmerId,
        'subscriptionId': subscriptionId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4️⃣ Daily stats
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

                  // ✅ FINAL CORRECT onPressed
                  onPressed: () async {
                    try {
                      await markAsPaid();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Payment confirmed & wallet credited',
                          ),
                        ),
                      );

                      // ✅ ONLY close this screen
                      Navigator.pop(context);

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ERROR: $e')),
                      );
                    }
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
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
