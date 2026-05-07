import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';
import '../partner/add_farmer_screen.dart';

// ✅ SUBSCRIPTION HISTORY SCREEN IMPORT
import '../partner/farmer_subscription_history_screen.dart';

class FarmerListScreen extends StatelessWidget {
  const FarmerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final t = AppStrings(lang);

    // 🔥 CURRENT LOGGED IN PARTNER UID
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.farmers),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) =>
                    const LanguageScreen(fromSettings: true),
              );
            },
          ),
        ],
      ),

      // ➕ ADD FARMER
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddFarmerScreen(),
            ),
          );
        },
      ),

      // 📋 FARMER LIST
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('farmers')
            .where('partnerId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                t.noTransactions,
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data =
                  doc.data() as Map<String, dynamic>;

              // 🔥 FIX START (IMPORTANT)
              String productText = '-';

              if (data.containsKey('products')) {
                final products = data['products'] as List?;

                if (products != null && products.isNotEmpty) {
                  final first = products[0];
                  productText =
                      "${first['name'] ?? ''} • ${first['quantity'] ?? ''} ${first['unit'] ?? ''}";
                }
              } else {
                productText =
                    "${data['product'] ?? '-'} • ${data['quantity'] ?? 0} ${data['unit'] ?? ''}";
              }
              // 🔥 FIX END

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: const Icon(Icons.person),

                  // ✅ TAP → FARMER SUBSCRIPTION HISTORY
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FarmerSubscriptionHistoryScreen(
                          farmerId: doc.id,
                          farmerName: data['farmerName'],
                        ),
                      ),
                    );
                  },

                  title: Text(
                    data['farmerName'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // 🔥 UPDATED SUBTITLE
                  subtitle: Text(productText),

                  trailing: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹ ${data['subscriptionAmount'] ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['status'] ?? 'submitted',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}