import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProcessorListScreen extends StatelessWidget {
  const ProcessorListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final partnerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Processors'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('processors')
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
              child: Text('No processors found'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data =
                  docs[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.factory),
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
