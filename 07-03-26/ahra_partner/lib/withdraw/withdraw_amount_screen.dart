import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'partner_withdraw_history_screen.dart';

class WithdrawAmountScreen extends StatefulWidget {
  const WithdrawAmountScreen({super.key});

  @override
  State<WithdrawAmountScreen> createState() =>
      _WithdrawAmountScreenState();
}

class _WithdrawAmountScreenState
    extends State<WithdrawAmountScreen> {
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

  Future<void> _loadWallet() async {
    final doc = await FirebaseFirestore.instance
        .collection('partners')
        .doc(partnerId)
        .get();

    if (doc.exists) {
      final rawWallet =
          (doc.data()?['walletBalance'] ?? 0).toInt();

      setState(() {
        walletAmount = (rawWallet / 2).round();
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
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Withdraw request sent to admin'),
      ),
    );

    _amountCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Amount'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PartnerWithdrawHistoryScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: walletAmount == 0
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [

                  // Wallet Card
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Wallet Balance',
                            style: TextStyle(
                                color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹ $walletAmount',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _amountCtrl,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Enter withdraw amount',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'ℹ️ Amount will be sent after admin approval',
                    style:
                        TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Recent Requests",
                    style: TextStyle(
                        fontWeight:
                            FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child:
                        StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore
                          .instance
                          .collection(
                              'withdraw_requests')
                          .where('partnerId',
                              isEqualTo:
                                  partnerId)
                          .limit(3)
                          .snapshots(),
                      builder:
                          (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text(
                                  "No requests yet"));
                        }

                        final docs =
                            snapshot.data!.docs;

                        return ListView.builder(
                          itemCount:
                              docs.length,
                          itemBuilder:
                              (context, index) {

                            final data =
                                docs[index].data()
                                    as Map<String, dynamic>;

                            final amount =
                                data['amount'];
                            final status =
                                data['status'];

                            Color statusColor;
                            String statusText;

                            switch (status) {
                              case 'approved':
                                statusColor =
                                    Colors.green;
                                statusText =
                                    "Approved";
                                break;
                              case 'rejected':
                                statusColor =
                                    Colors.red;
                                statusText =
                                    "Rejected";
                                break;
                              default:
                                statusColor =
                                    Colors.orange;
                                statusText =
                                    "Pending";
                            }

                            return Card(
                              margin:
                                  const EdgeInsets
                                      .only(
                                          bottom:
                                              8),
                              child: Padding(
                                padding:
                                    const EdgeInsets
                                        .all(12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Text(
                                      "₹ $amount",
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        fontSize:
                                            16,
                                      ),
                                    ),
                                    Container(
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
                                            statusColor
                                                .withOpacity(
                                                    0.15),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    20),
                                      ),
                                      child: Text(
                                        statusText,
                                        style:
                                            TextStyle(
                                          color:
                                              statusColor,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  ElevatedButton(
                    onPressed:
                        _loading
                            ? null
                            : _submit,
                    style:
                        ElevatedButton
                            .styleFrom(
                      padding:
                          const EdgeInsets
                              .symmetric(
                                  vertical:
                                      14),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color:
                                Colors.white)
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