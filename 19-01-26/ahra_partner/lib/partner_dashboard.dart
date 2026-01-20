import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'app_strings.dart';
import 'language_screen.dart';

class PartnerDashboard extends StatelessWidget {
  final String partnerName;

  const PartnerDashboard({
    super.key,
    required this.partnerName,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 REAL-TIME language listen
    final lang = context.watch<LanguageProvider>().lang;
    final s = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(s.get('dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: s.get('change_language'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LanguageScreen(fromSettings: true),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Welcome text (REAL-TIME)
            Text(
              '${s.get('welcome')}, $partnerName 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Earnings
            Card(
              child: ListTile(
                leading: const Icon(Icons.currency_rupee),
                title: Text(s.get('today_earnings')),
                trailing: const Text('₹ 0'),
              ),
            ),

            // Jobs
            Card(
              child: ListTile(
                leading: const Icon(Icons.work),
                title: Text(s.get('jobs_assigned')),
                trailing: const Text('0'),
              ),
            ),

            const Spacer(),

            // Change Language (bottom)
            OutlinedButton.icon(
              icon: const Icon(Icons.language),
              label: Text(s.get('change_language')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const LanguageScreen(fromSettings: true),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(s.get('logout_later')),
                  ),
                );
              },
              child: Text(s.get('logout')),
            ),
          ],
        ),
      ),
    );
  }
}
