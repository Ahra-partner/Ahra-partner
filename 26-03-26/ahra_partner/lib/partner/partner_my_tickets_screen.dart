import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PartnerMyTicketsScreen extends StatelessWidget {
  const PartnerMyTicketsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case "Open":
        return Colors.orange;
      case "Resolved":
        return Colors.green;
      case "Closed":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    final partnerId =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tickets"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('support_tickets')
            .where('partnerId',
                isEqualTo: partnerId)
            .orderBy('createdAt',
                descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
                child:
                    CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                  "No tickets raised yet."),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data =
                  docs[index].data()
                      as Map<String, dynamic>;

              final status =
                  data['status'] ?? 'Open';

              return Card(
                margin:
                    const EdgeInsets.only(
                        bottom: 12),
                child: ListTile(
                  title: Text(
                      data['issueType'] ??
                          ''),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                          data['description'] ??
                              ''),
                      const SizedBox(
                          height: 4),
                      if ((data['adminReply'] ??
                              '')
                          .isNotEmpty)
                        Text(
                          "Admin: ${data['adminReply']}",
                          style:
                              const TextStyle(
                                  color: Colors
                                      .deepPurple),
                        ),
                    ],
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                                horizontal:
                                    10,
                                vertical:
                                    4),
                    decoration:
                        BoxDecoration(
                      color:
                          _statusColor(
                              status),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  12),
                    ),
                    child: Text(
                      status,
                      style:
                          const TextStyle(
                              color: Colors
                                  .white),
                    ),
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
