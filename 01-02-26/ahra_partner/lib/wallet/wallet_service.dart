import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  static Future<void> creditPartnerWallet({
    required String partnerId,
    required int totalAmount, // eg: 200
    required String customerId,
    required String paymentId, // 🔐 STEP-S1: UNIQUE PAYMENT ID
  }) async {
    final firestore = FirebaseFirestore.instance;

    final partnerRef =
        firestore.collection('partners').doc(partnerId);

    // 🔐 Duplicate payment guard
    final paymentRef =
        firestore.collection('payments').doc(paymentId);

    final ledgerRef =
        firestore.collection('wallet_ledger').doc();

    // 🔢 50% split logic
    final int partnerShare = (totalAmount * 0.5).round();
    final int companyShare = totalAmount - partnerShare;

    await firestore.runTransaction((transaction) async {
      // 🔒 STEP-S1: Check duplicate payment
      final paymentSnap = await transaction.get(paymentRef);
      if (paymentSnap.exists) {
        throw Exception('Payment already processed');
      }

      final partnerSnap = await transaction.get(partnerRef);
      if (!partnerSnap.exists) {
        throw Exception('Partner not found');
      }

      final int currentWallet =
          partnerSnap['walletBalance'] ?? 0;

      // 1️⃣ CREDIT partner wallet
      transaction.update(partnerRef, {
        'walletBalance': currentWallet + partnerShare,
        'todayEarnings': FieldValue.increment(partnerShare),
      });

      // 2️⃣ SAVE PAYMENT (ANTI DUPLICATE RECORD)
      transaction.set(paymentRef, {
        'paymentId': paymentId,
        'partnerId': partnerId,
        'customerId': customerId,
        'totalAmount': totalAmount,
        'partnerShare': partnerShare,
        'companyShare': companyShare,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3️⃣ LEDGER ENTRY (CREDIT)
      transaction.set(ledgerRef, {
        'partnerId': partnerId,
        'customerId': customerId,
        'type': 'customer_payment',
        'direction': 'credit',
        'amount': partnerShare,
        'companyShare': companyShare,
        'totalAmount': totalAmount,
        'description':
            'Customer payment credited (50% partner share)',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
