import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_district_screen.dart';

class AdminLocationSummaryScreen extends StatelessWidget {
  const AdminLocationSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Summary'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          final Set<String> states = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            states.add(data['state'] ?? 'Unknown');
          }

          final stateList = states.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: stateList.length,
            itemBuilder: (context, index) {

              final state = stateList[index];

              // ✅ STATE COUNT CARD WITH PARTNER + FARMER COUNT
              return FutureBuilder(
                future: Future.wait([
                  FirebaseFirestore.instance
                      .collection('partners')
                      .where('state', isEqualTo: state)
                      .get(),
                  FirebaseFirestore.instance
                      .collection('farmers')
                      .where('state', isEqualTo: state)
                      .get(),
                ]),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final partnerCount =
                      (snapshot.data![0] as QuerySnapshot)
                          .docs
                          .length;

                  final farmerCount =
                      (snapshot.data![1] as QuerySnapshot)
                          .docs
                          .length;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        state,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Partners: $partnerCount | Farmers: $farmerCount',
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminDistrictScreen(
                              state: state,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
