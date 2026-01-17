import 'package:flutter/material.dart';

class PartnerDashboard extends StatelessWidget {
  final String partnerName;

  const PartnerDashboard({super.key, required this.partnerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $partnerName 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Earnings (dummy)
            Card(
              child: ListTile(
                leading: const Icon(Icons.currency_rupee),
                title: const Text('Today Earnings'),
                trailing: const Text('₹ 0'),
              ),
            ),

            // Jobs (dummy)
            Card(
              child: ListTile(
                leading: const Icon(Icons.work),
                title: const Text('Jobs Assigned'),
                trailing: const Text('0'),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout later integrate cheddam')),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
