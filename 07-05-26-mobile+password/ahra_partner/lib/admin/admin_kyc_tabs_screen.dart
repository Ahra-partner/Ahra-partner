import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_kyc_review_screen.dart';

class AdminKycTabsScreen extends StatelessWidget {
  const AdminKycTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('KYC Requests'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _KycList(status: 'under_review'), // ✅ FIX
            _KycList(status: 'approved'),
            _KycList(status: 'rejected'),
          ],
        ),
      ),
    );
  }
}

class _KycList extends StatelessWidget {
  final String status;

  const _KycList({required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partners')
          .where('kycStatus', isEqualTo: status)
          .orderBy('kycSubmittedAt', descending: true) // ✅ FIX
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No ${_label(status)} KYC requests',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data =
                doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.person,
                  color: status == 'approved'
                      ? Colors.green
                      : status == 'rejected'
                          ? Colors.red
                          : Colors.orange,
                ),
                title: Text(data['name'] ?? 'Partner'),
                subtitle: Text(data['mobile'] ?? '-'), // ✅ FIX
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
              ),
            );
          },
        );
      },
    );
  }

  // 🔹 Status label helper
  static String _label(String status) {
    switch (status) {
      case 'under_review':
        return 'pending';
      case 'approved':
        return 'approved';
      case 'rejected':
        return 'rejected';
      default:
        return status;
    }
  }
}
