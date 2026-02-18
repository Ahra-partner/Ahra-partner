import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_mandal_screen.dart';

class AdminDistrictScreen extends StatelessWidget {
  final String state;

  const AdminDistrictScreen({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(state),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .where('state', isEqualTo: state)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          final Set<String> districts = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            districts.add(data['district'] ?? 'Unknown');
          }

          final districtList = districts.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: districtList.length,
            itemBuilder: (context, index) {

              final district = districtList[index];

              // ✅ DISTRICT COUNT CARD WITH RETAILERS
              return FutureBuilder(
                future: Future.wait([
                  FirebaseFirestore.instance
                      .collection('partners')
                      .where('state', isEqualTo: state)
                      .where('district', isEqualTo: district)
                      .get(),
                  FirebaseFirestore.instance
                      .collection('farmers')
                      .where('state', isEqualTo: state)
                      .where('district', isEqualTo: district)
                      .get(),
                  FirebaseFirestore.instance
                      .collection('retailers')
                      .where('state', isEqualTo: state)
                      .where('district', isEqualTo: district)
                      .get(),
                ]),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final partnerCount =
                      (snapshot.data![0] as QuerySnapshot)
                          .docs.length;

                  final farmerCount =
                      (snapshot.data![1] as QuerySnapshot)
                          .docs.length;

                  final retailerCount =
                      (snapshot.data![2] as QuerySnapshot)
                          .docs.length;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        district,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Partners: $partnerCount  |  Farmers: $farmerCount  |  Retailers: $retailerCount',
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
                                AdminMandalScreen(
                              state: state,
                              district: district,
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
