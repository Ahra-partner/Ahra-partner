import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_location_detail_screen.dart';

class AdminMandalScreen extends StatelessWidget {
  final String state;
  final String district;

  const AdminMandalScreen({
    super.key,
    required this.state,
    required this.district,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(district),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .where('state', isEqualTo: state)
            .where('district', isEqualTo: district)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          final Set<String> mandals = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            mandals.add(data['mandal'] ?? 'Unknown');
          }

          final mandalList = mandals.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: mandalList.length,
            itemBuilder: (context, index) {

              final mandal = mandalList[index];

              // ✅ Mandal count card
              return FutureBuilder(
                future: Future.wait([
                  FirebaseFirestore.instance
                      .collection('partners')
                      .where('state', isEqualTo: state)
                      .where('district', isEqualTo: district)
                      .where('mandal', isEqualTo: mandal)
                      .get(),
                  FirebaseFirestore.instance
                      .collection('farmers')
                      .where('state', isEqualTo: state)
                      .where('district', isEqualTo: district)
                      .where('mandal', isEqualTo: mandal)
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
                        mandal,
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
                                AdminLocationDetailScreen(
                              state: state,
                              district: district,
                              mandal: mandal,
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
