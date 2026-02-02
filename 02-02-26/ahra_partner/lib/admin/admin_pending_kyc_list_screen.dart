import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_kyc_review_screen.dart';

class AdminPendingKycListScreen extends StatelessWidget {
  const AdminPendingKycListScreen({super.key});

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
            .where('kycStatus', isEqualTo: 'under_review')
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
              child: Text(
                'No pending KYC requests',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data =
                  doc.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Partner';
              final phone = data['phone'] ?? '-';
              final createdAt = data['createdAt'];

              return ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: Colors.orange,
                ),
                title: Text(name),
                subtitle: Text(phone),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminKycReviewScreen(
                        partnerId: doc.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
