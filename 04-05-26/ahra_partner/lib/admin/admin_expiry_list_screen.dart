import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminExpiryListScreen extends StatelessWidget {
  const AdminExpiryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expiry Alerts"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('expiry_alerts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No expiry alerts found"),
            );
          }

          return ListView(
            children: docs.map((d) {
              final data = d.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Partner: ${data['partnerId']}"),
                  subtitle:
                      Text("Expires in ${data['daysLeft']} days"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}