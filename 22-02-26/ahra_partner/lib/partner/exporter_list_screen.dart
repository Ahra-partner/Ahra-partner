import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';

// ✅ Exporter imports (create these files inside partner/exporter/)
import 'exporter/add_exporter_screen.dart';
import 'exporter/exporter_subscription_history_screen.dart';

class ExporterListScreen extends StatelessWidget {
  const ExporterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final t = AppStrings(lang);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exporters'),
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExporterScreen(),
            ),
          );
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exporters')
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
            return const Center(
              child: Text(
                'No Exporters Found',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {

              final doc = docs[i];
              final data =
                  doc.data() as Map<String, dynamic>;

              final totalPaid =
                  data['totalPaid'] ?? 0;

              final status =
                  data['status'] ?? 'active';

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.flight_takeoff,
                    color: Colors.blue,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ExporterSubscriptionHistoryScreen(
                          exporterId: doc.id,
                          exporterName:
                              data['name'] ?? '',
                        ),
                      ),
                    );
                  },

                  title: Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    '${data['companyName'] ?? '-'} • '
                    '${data['district'] ?? '-'}',
                  ),

                  trailing: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [

                      Text(
                        '₹ $totalPaid',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: status == 'active'
                              ? Colors.green
                              : Colors.red,
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
