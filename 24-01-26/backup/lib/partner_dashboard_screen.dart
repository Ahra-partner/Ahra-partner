import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerDashboardScreen extends StatefulWidget {
  final String partnerId;

  const PartnerDashboardScreen({
    super.key,
    required this.partnerId,
  });

  @override
  State<PartnerDashboardScreen> createState() =>
      _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  String? selectedPartnerType;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partners')
          .doc(widget.partnerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final name = data['name'] ?? 'Partner';
        final location = data['village'] ?? '-';
        final phone = data['phone'] ?? '-';

        final walletBalance = data['walletBalance'] ?? 0;
        final todayEarnings = data['todayEarnings'] ?? 0;
        final weekEarnings = data['weekEarnings'] ?? 0;
        final monthEarnings = data['monthEarnings'] ?? 0;

        selectedPartnerType =
            data['partnerType'] ?? selectedPartnerType;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),

          // ================= TOP APP BAR =================
          appBar: AppBar(
            backgroundColor: Colors.green.shade700,
            elevation: 0,
            title: Row(
              children: const [
                Icon(Icons.eco),
                SizedBox(width: 6),
                Text('AHRA'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
            ],
          ),

          body: SingleChildScrollView(
            child: Column(
              children: [
                // ================= HEADER =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $name 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$location • $phone',
                        style:
                            const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================= PARTNER TYPE =================
                _sectionTitle('Select Partner Type'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _partnerTypeCard(
                        title: 'Farmers',
                        icon: Icons.person,
                        color: Colors.green,
                        value: 'farmers',
                      ),
                      _partnerTypeCard(
                        title: 'Retailers',
                        icon: Icons.store,
                        color: Colors.blue,
                        value: 'retailers',
                      ),
                      _partnerTypeCard(
                        title: 'Exporters',
                        icon: Icons.local_shipping,
                        color: Colors.orange,
                        value: 'exporters',
                      ),
                      _partnerTypeCard(
                        title: 'Food Processor',
                        icon: Icons.factory,
                        color: Colors.purple,
                        value: 'food_processor',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================= WALLET =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Wallet Balance',
                                style:
                                    TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹ $walletBalance',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          // ✅ STEP-W2: Withdraw Button Connected
                          ElevatedButton(
                            onPressed: () {
                              _showWithdrawBottomSheet(
                                context,
                                walletBalance: walletBalance,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Withdraw'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= EARNINGS =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _earningCard(
                          title: "Today", amount: todayEarnings),
                      _earningCard(
                          title: "Week", amount: weekEarnings),
                      _earningCard(
                          title: "Month", amount: monthEarnings),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ================= BOTTOM INFO =================
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'Onboarding Completed 🎉',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Your account is active and ready for jobs',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= BOTTOM NAV =================
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            selectedItemColor: Colors.green.shade700,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work),
                label: 'Jobs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= HELPERS =================

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );

  Widget _partnerTypeCard({
    required String title,
    required IconData icon,
    required Color color,
    required String value,
  }) {
    final isSelected = selectedPartnerType == value;

    return GestureDetector(
      onTap: () async {
        setState(() => selectedPartnerType = value);
        await FirebaseFirestore.instance
            .collection('partners')
            .doc(widget.partnerId)
            .update({'partnerType': value});
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _earningCard({
    required String title,
    required int amount,
  }) {
    return Expanded(
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '₹ $amount',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= STEP-W1: WITHDRAW BOTTOM SHEET =================
  void _showWithdrawBottomSheet(
    BuildContext context, {
    required int walletBalance,
  }) {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(Icons.horizontal_rule,
                    size: 40, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              const Text(
                'Withdraw Money',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Available Balance: ₹ $walletBalance',
                style: const TextStyle(color: Colors.green),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    final amount = int.tryParse(
                            amountController.text.trim()) ??
                        0;

                    if (amount <= 0 ||
                        amount > walletBalance) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text('Enter valid amount'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Withdrawal request of ₹$amount submitted'),
                      ),
                    );
                  },
                  child: const Text('Request Withdraw'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
