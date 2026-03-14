import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class AdminInactiveSubscriptionsScreen extends StatefulWidget {
  const AdminInactiveSubscriptionsScreen({super.key});

  @override
  State<AdminInactiveSubscriptionsScreen> createState() =>
      _AdminInactiveSubscriptionsScreenState();
}

class _AdminInactiveSubscriptionsScreenState
    extends State<AdminInactiveSubscriptionsScreen> {

  final List<String> collections = [
    'farmers',
    'retailers',
    'wholesalers',
    'processors',
    'exporters',
  ];

  Future<List<Map<String, dynamic>>> _fetchInactiveUsers() async {

    final now = Timestamp.now();
    List<Map<String, dynamic>> result = [];

    for (String collection in collections) {

      final query = await FirebaseFirestore.instance
          .collection(collection)
          .where('subscriptionEndDate', isLessThan: now)
          .get();

      for (var doc in query.docs) {

        final data = doc.data();
        final partnerId = data['partnerId'];

        final partnerSnap = await FirebaseFirestore.instance
            .collection('partners')
            .doc(partnerId)
            .get();

        final partner = partnerSnap.data();

        result.add({
          'type': collection.substring(0, collection.length - 1).toUpperCase(),
          'name': data['farmerName'] ??
              data['retailerName'] ??
              data['wholesalerName'] ??
              data['processorName'] ??
              data['exporterName'] ??
              '',

          'mobile': data['mobile'] ?? '',
          'village': data['village'] ?? '',
          'mandal': data['mandal'] ?? '',
          'district': data['district'] ?? '',
          'state': data['state'] ?? '',
          'subscriptionEndDate':
              (data['subscriptionEndDate'] as Timestamp)
                  .toDate()
                  .toString(),

          'partnerName': partner?['name'] ?? '',
          'partnerMobile': partner?['mobile'] ?? '',
          'partnerAddress': partner?['address'] ?? '',
          'partnerPincode': partner?['pincode'] ?? '',
        });
      }
    }

    return result;
  }

  Future<void> _exportExcel(
      List<Map<String, dynamic>> data) async {

    var excel = Excel.createExcel();
    Sheet sheet = excel['Inactive'];

    sheet.appendRow([
      'Type',
      'Name',
      'Mobile',
      'Village',
      'Mandal',
      'District',
      'State',
      'Expiry Date',
      'Partner Name',
      'Partner Mobile',
      'Partner Address',
      'Partner Pincode',
    ]);

    for (var item in data) {
      sheet.appendRow([
        item['type'],
        item['name'],
        item['mobile'],
        item['village'],
        item['mandal'],
        item['district'],
        item['state'],
        item['subscriptionEndDate'],
        item['partnerName'],
        item['partnerMobile'],
        item['partnerAddress'],
        item['partnerPincode'],
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/inactive_subscriptions.xlsx");

    await file.writeAsBytes(excel.encode()!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel saved at: ${file.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inactive Subscriptions"),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchInactiveUsers(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          if (data.isEmpty) {
            return const Center(
                child: Text("No inactive users"));
          }

          return Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text("Export Excel"),
                  onPressed: () => _exportExcel(data),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {

                    final item = data[index];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text("${item['type']} - ${item['name']}"),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text("Mobile: ${item['mobile']}"),
                            Text("Partner: ${item['partnerName']}"),
                            Text("Expired: ${item['subscriptionEndDate']}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}