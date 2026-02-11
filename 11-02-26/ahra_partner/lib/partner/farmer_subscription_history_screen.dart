import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';

// ✅ ADD THIS IMPORT (STEP-2)
import '../partner/add_subscription_screen.dart';

class FarmerSubscriptionHistoryScreen extends StatelessWidget {
  final String farmerId; // 🔥 mobile number (document ID)
  final String farmerName;

  const FarmerSubscriptionHistoryScreen({
    super.key,
    required this.farmerId,
    required this.farmerName,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final t = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription History'), // ✅ SAFE TITLE
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

      // ✅ STEP-2 : ADD NEW MONTH SUBSCRIPTION BUTTON
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSubscriptionScreen(
                farmerId: farmerId,
                farmerName: farmerName,
              ),
            ),
          );
        },
      ),

      body: Column(
        children: [
          // ================= FARMER BASIC DETAILS =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  farmerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t.mobileNumber}: $farmerId',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ================= SUBSCRIPTION HISTORY =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('farmers')
                  .doc(farmerId)
                  .collection('subscriptions')
                  .orderBy('createdAt', descending: true)
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
                      style:
                          const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No subscriptions yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data =
                        docs[i].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.calendar_month,
                        ),
                        title: Text(
                          data['month'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Amount: ₹ ${data['amount'] ?? 0}',
                        ),
                        trailing: Text(
                          data['status'] ?? 'pending',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: data['status'] == 'paid'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
