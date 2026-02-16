import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WholesalerListScreen extends StatelessWidget {
  const WholesalerListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final partnerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wholesalers'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wholesalers')
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
              child: Text('No wholesalers found'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data =
                  docs[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.business),
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
