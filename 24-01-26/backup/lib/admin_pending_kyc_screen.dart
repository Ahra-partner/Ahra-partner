import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_kyc_detail_screen.dart'; // 🔥 STEP-2 screen

class AdminPendingKycScreen extends StatelessWidget {
  const AdminPendingKycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending KYC Requests'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .where('kycStatus', isEqualTo: 'pending')
            .orderBy('kycSubmittedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No pending KYC requests',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final partnerId = doc.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: Colors.orange,
                  ),
                  title: Text(
                    data['name'] ?? 'No Name',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Phone: ${data['phone'] ?? '-'}'),
                      const SizedBox(height: 4),
                      if (data['kycSubmittedAt'] != null)
                        Text(
                          'Submitted: ${data['kycSubmittedAt'].toDate()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),

                  // 🔥 VIEW KYC BUTTON (STEP-2 LINK)
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminKycDetailScreen(
                            partnerId: partnerId,
                            data: data,
                          ),
                        ),
                      );
                    },
                    child: const Text('View KYC'),
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
