import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Approval')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('partners').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final partners = snapshot.data!.docs;

          return ListView.builder(
            itemCount: partners.length,
            itemBuilder: (context, index) {
              final doc = partners[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['name'] ?? 'No Name'),
                  subtitle: Text('Status: ${data['kycStatus']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('partners')
                              .doc(doc.id)
                              .update({'kycStatus': 'approved'});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('partners')
                              .doc(doc.id)
                              .update({'kycStatus': 'rejected'});
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
