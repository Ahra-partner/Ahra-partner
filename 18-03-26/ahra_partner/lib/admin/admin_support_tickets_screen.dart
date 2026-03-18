import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSupportTicketsScreen extends StatelessWidget {
  const AdminSupportTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Tickets"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('support_tickets')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No tickets found"),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data =
                  docs[index].data()
                      as Map<String, dynamic>;

              final ticketId = data['ticketId'];
              final partnerName =
                  data['partnerName'];
              final issue =
                  data['issueType'];
              final status =
                  data['status'];

              return Card(
                margin:
                    const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("$ticketId - $partnerName"),
                  subtitle: Text(
                      "Issue: $issue\nStatus: $status"),
                  trailing: const Icon(
                      Icons.arrow_forward_ios),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
