import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'admin_home_screen.dart';

class DecideScreen extends StatelessWidget {
  const DecideScreen({super.key});

  // 🔥 For now dummy id (later real login nunchi vastundi)
  final String userId = 'dummy_partner_001';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final role = data['role'];

          // 🔀 ROLE BASED ROUTING
          if (role == 'admin') {
            return const AdminHomeScreen();
          } else {
            return HomeScreen(partnerId: userId);
          }
        },
      ),
    );
  }
}
