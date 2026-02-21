import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../language_screen.dart';
import '../app_strings.dart';

class FarmerDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const FarmerDetailsScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final t = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.farmers),
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
                _row('Farmer Name', data['farmerName']),
                _row('Mobile', data['mobile']),
                _row('Village', data['village']),
                _row('Mandal', data['mandal']),
                _row('District', data['district']),
                _row('State', data['state']),
                const Divider(),

                _row('Category', data['category']),
                _row('Product', data['product']),
                _row(
                  'Quantity',
                  '${data['quantity']} ${data['unit']}',
                ),
                const Divider(),

                _row(
                  'Amount',
                  '₹ ${data['subscriptionAmount']}',
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
