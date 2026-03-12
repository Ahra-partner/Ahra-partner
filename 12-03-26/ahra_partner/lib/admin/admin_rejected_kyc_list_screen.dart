import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRejectedKycListScreen extends StatelessWidget {
  const AdminRejectedKycListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partners')
          .where('kycStatus', isEqualTo: 'rejected')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text('No rejected KYCs'),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, index) {
            final data =
                docs[index].data() as Map<String, dynamic>;

            return ListTile(
              leading: const Icon(Icons.cancel,
                  color: Colors.red),
              title: Text(data['name'] ?? 'Partner'),
              subtitle: Text(
                data['rejectionReason'] ?? 'No reason',
              ),
            );
          },
        );
      },
    );
  }
}
