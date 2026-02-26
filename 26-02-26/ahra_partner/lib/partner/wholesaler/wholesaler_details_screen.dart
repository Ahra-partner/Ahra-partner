import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';

class WholesalerDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const WholesalerDetailsScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final t = AppStrings(lang);

    final List products =
        data['productsSupplied'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wholesaler Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) =>
                    const LanguageScreen(fromSettings: true),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [

                // 🔹 BASIC INFO
                _row('Wholesaler Name', data['name']),
                _row('Mobile', data['mobile']),
                _row('Company Name', data['companyName']),
                _row('Village', data['village']),
                _row('Mandal', data['mandal']),
                _row('District', data['district']),
                _row('State', data['state']),

                const Divider(),

                // 🔹 PRODUCT INFO
                const Text(
                  'Products Supplied',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                ...products.map((p) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "${p['name']} - ${p['quantity']} ${p['unit']}",
                    ),
                  );
                }).toList(),

                const Divider(),

                // 🔹 PAYMENT INFO
                _row(
                  'Subscription Amount',
                  '₹ ${data['subscriptionAmount'] ?? 0}',
                ),
                _row('Status', data['status']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(value ?? '-'),
          ),
        ],
      ),
    );
  }
}
