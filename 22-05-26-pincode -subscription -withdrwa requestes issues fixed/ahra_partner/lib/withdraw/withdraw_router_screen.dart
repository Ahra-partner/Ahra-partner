import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_bank_details_screen.dart';
import 'withdraw_amount_screen.dart';

class WithdrawRouterScreen extends StatelessWidget {
  const WithdrawRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final partnerId =
        FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('partners')
          .doc(partnerId)
          .collection('bank_details') // ✅ FIXED HERE
          .doc('main')
          .get(),
      builder: (context, snapshot) {
        // ⏳ Loading
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❗ ERROR → treat as NO bank details
        if (snapshot.hasError) {
          debugPrint(
              'WithdrawRouter error: ${snapshot.error}');
          return const AddBankDetailsScreen();
        }

        // 🏦 Bank details not added yet
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const AddBankDetailsScreen();
        }

        // 💰 Bank details exist → go to withdraw screen
        return const WithdrawAmountScreen();
      },
    );
  }
}