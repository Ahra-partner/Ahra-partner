import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApprovedKycListScreen extends StatelessWidget {
  const AdminApprovedKycListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partners')
          .where('kycStatus', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text('No approved partners'),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, index) {
            final data =
                docs[index].data() as Map<String, dynamic>;

            return ListTile(
              leading: const Icon(Icons.check_circle,
                  color: Colors.green),
              title: Text(data['name'] ?? 'Partner'),
              subtitle: Text(data['phone'] ?? ''),
            );
          },
        );
      },
    );
  }
}
