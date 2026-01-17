import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final String partnerId;

  const HomeScreen({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AHRA Partner'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .doc(partnerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No partner data found'));
          }

          final rawData = snapshot.data!.data();

          if (rawData == null) {
            return const Center(child: Text('Partner data empty'));
          }

          final data = rawData as Map<String, dynamic>;

          final String kycStatus = data['kycStatus'] ?? 'pending';
          final bool profileCompleted =
              data['profileCompleted'] ?? false;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'WELCOME PARTNER 🎉',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Status : $kycStatus',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // 🔁 Profile incomplete
                if (!profileCompleted)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: const Text('Complete Profile'),
                  ),

                // 🔁 KYC pending
                if (kycStatus == 'pending')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/kyc');
                    },
                    child: const Text('Update KYC'),
                  ),

                // ✅ Approved
                if (kycStatus == 'approved')
                  const Text(
                    '✅ KYC Approved',
                    style: TextStyle(color: Colors.green),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
