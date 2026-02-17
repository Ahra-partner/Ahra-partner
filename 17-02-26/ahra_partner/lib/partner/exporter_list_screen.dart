import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExporterListScreen extends StatelessWidget {
  const ExporterListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final partnerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exporters'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exporters')
            .where('partnerId', isEqualTo: partnerId)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No exporters found'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data =
                  docs[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.flight_takeoff),
                title: Text(data['name'] ?? ''),
                subtitle: Text(data['mobile'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
