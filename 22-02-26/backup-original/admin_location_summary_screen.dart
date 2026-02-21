import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLocationSummaryScreen extends StatelessWidget {
  const AdminLocationSummaryScreen({super.key});

  // ================= BUILD LOCATION MAP =================
  Map<String, dynamic> _buildLocationStats(
      List<QueryDocumentSnapshot> partners,
      List<QueryDocumentSnapshot> farmers) {
    final Map<String, dynamic> locationMap = {};

    // 🔹 Count partners
    for (final doc in partners) {
      final data = doc.data() as Map<String, dynamic>;

      final state = data['state'] ?? 'Unknown';
      final district = data['district'] ?? 'Unknown';
      final mandal = data['mandal'] ?? 'Unknown';

      locationMap.putIfAbsent(state, () => {});
      locationMap[state].putIfAbsent(district, () => {});
      locationMap[state][district].putIfAbsent(mandal, () => {
            'partners': 0,
            'farmers': 0,
          });

      locationMap[state][district][mandal]['partners'] += 1;
    }

    // 🔹 Count farmers
    for (final doc in farmers) {
      final data = doc.data() as Map<String, dynamic>;

      final state = data['state'] ?? 'Unknown';
      final district = data['district'] ?? 'Unknown';
      final mandal = data['mandal'] ?? 'Unknown';

      locationMap.putIfAbsent(state, () => {});
      locationMap[state].putIfAbsent(district, () => {});
      locationMap[state][district].putIfAbsent(mandal, () => {
            'partners': 0,
            'farmers': 0,
          });

      locationMap[state][district][mandal]['farmers'] += 1;
    }

    return locationMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Summary'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Future.wait([
          FirebaseFirestore.instance.collection('partners').get(),
          FirebaseFirestore.instance.collection('farmers').get(),
        ]),
        builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final partners = snapshot.data![0].docs;
          final farmers = snapshot.data![1].docs;

          final locationStats =
              _buildLocationStats(partners, farmers);

          if (locationStats.isEmpty) {
            return const Center(
              child: Text(
                'No location data found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: locationStats.keys.map((state) {
              final districts = locationStats[state];

              return ExpansionTile(
                title: Text(
                  state,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                children: districts.keys.map<Widget>((district) {
                  final mandals = districts[district];

                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 16),
                    child: ExpansionTile(
                      title: Text(
                        district,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children:
                          mandals.keys.map<Widget>((mandal) {
                        final stats = mandals[mandal];

                        return Padding(
                          padding:
                              const EdgeInsets.only(
                                  left: 16),
                          child: ListTile(
                            title: Text(mandal),
                            subtitle: Text(
                              'Partners: ${stats['partners']} | Farmers: ${stats['farmers']}',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
