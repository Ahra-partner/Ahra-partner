import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLocationDetailScreen extends StatelessWidget {
  final String state;
  final String district;
  final String mandal;

  const AdminLocationDetailScreen({
    super.key,
    required this.state,
    required this.district,
    required this.mandal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mandal),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ================= 🔵 PARTNERS =================
            const Text(
              'Partners',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('partners')
                  .where('state', isEqualTo: state)
                  .where('district', isEqualTo: district)
                  .where('mandal', isEqualTo: mandal)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text('No partners found');
                }

                return Column(
                  children: docs.map((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;

                    final name =
                        data['name'] ?? 'No Name';
                    final mobile =
                        data['mobile'] ?? '';

                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(name),
                      subtitle: Text(mobile),
                    );
                  }).toList(),
                );
              },
            ),

            const Divider(),

            // ================= 🟢 FARMERS =================
            const Text(
              'Farmers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('farmers')
                  .where('state', isEqualTo: state)
                  .where('district', isEqualTo: district)
                  .where('mandal', isEqualTo: mandal)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text('No farmers found');
                }

                return Column(
                  children: docs.map((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;

                    final name =
                        data['farmerName'] ?? 'No Name';
                    final mobile =
                        data['mobile'] ?? '';

                    return ListTile(
                      leading:
                          const Icon(Icons.agriculture),
                      title: Text(name),
                      subtitle: Text(mobile),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
