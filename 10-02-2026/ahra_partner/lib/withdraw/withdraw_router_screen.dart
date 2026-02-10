import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_bank_details_screen.dart';
import 'withdraw_amount_screen.dart';

class WithdrawRouterScreen extends StatelessWidget {
  final String partnerId;
  final int walletAmount;

  const WithdrawRouterScreen({
    super.key,
    required this.partnerId,
    required this.walletAmount,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('bank_details')
          .doc(partnerId)
          .get(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snap.data!.exists) {
          return AddBankDetailsScreen(partnerId: partnerId);
        }

        return WithdrawAmountScreen(
          partnerId: partnerId,
          walletAmount: walletAmount,
        );
      },
    );
  }
}
