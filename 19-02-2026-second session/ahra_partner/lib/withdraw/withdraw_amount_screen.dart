import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 ADD THIS IMPORT
import 'partner_withdraw_history_screen.dart';

class WithdrawAmountScreen extends StatefulWidget {
  const WithdrawAmountScreen({super.key});

  @override
  State<WithdrawAmountScreen> createState() =>
      _WithdrawAmountScreenState();
}

class _WithdrawAmountScreenState extends State<WithdrawAmountScreen> {
  final _amountCtrl = TextEditingController();
  bool _loading = false;

  late String partnerId;
  int walletAmount = 0;

  @override
  void initState() {
    super.initState();
    partnerId = FirebaseAuth.instance.currentUser!.uid;
    _loadWallet();
  }

  // ✅ UPDATED WALLET LOAD (50% LOGIC)
  Future<void> _loadWallet() async {
    final doc = await FirebaseFirestore.instance
        .collection('partners')
        .doc(partnerId)
        .get();

    if (doc.exists) {
      final rawWallet =
          (doc.data()?['walletBalance'] ?? 0).toInt();

      setState(() {
        walletAmount = (rawWallet / 2).round(); // ✅ 50% logic
      });
    }
  }

  Future<void> _submit() async {
    final amount = int.tryParse(_amountCtrl.text) ?? 0;

    if (amount <= 0 || amount > walletAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid withdraw amount')),
      );
      return;
    }

    setState(() => _loading = true);

    await FirebaseFirestore.instance
        .collection('withdraw_requests')
        .add({
      'partnerId': partnerId,
      'amount': amount,
      'status': 'pending', // admin approval needed
      'requestedAt': FieldValue.serverTimestamp(),
    });

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Withdraw request sent to admin'),
      ),
    );

    // ✅ NEW: DIRECTLY OPEN WITHDRAW HISTORY
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PartnerWithdrawHistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Amount'),
      ),
      body: walletAmount == 0
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Wallet Balance',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹ $walletAmount',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter withdraw amount',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'ℹ️ Amount will be sent after admin approval',
                    style: TextStyle(color: Colors.grey),
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Submit Withdraw Request',
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
