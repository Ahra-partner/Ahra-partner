import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

// 🔥 NEW IMPORT
import 'package:share_plus/share_plus.dart';

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

  Future<List<Map<String, dynamic>>> _fetchAllUsers() async {

    List<Map<String, dynamic>> result = [];

    for (String collection in collections) {

      final query = await FirebaseFirestore.instance
          .collection(collection)
          .get();

      for (var doc in query.docs) {

        final data = doc.data();

        // 🔥 DEBUG
        print("DOC ID: ${doc.id}");
        print("MAIN DATA: $data");

        final partnerId = data['partnerId'];

        final partnerSnap = await FirebaseFirestore.instance
            .collection('partners')
            .doc(partnerId)
            .get();

        final partner = partnerSnap.data();

        // 🔥🔥 FINAL EXPIRY LOGIC
        DateTime? expiry;

        // ✅ Case 1: direct field
        if (data['expiryDate'] != null) {
          expiry = (data['expiryDate'] as Timestamp).toDate();
        }

        // ✅ Case 2: nested object
        else if (data['subscription'] != null &&
            data['subscription']['expiryDate'] != null) {
          expiry = (data['subscription']['expiryDate'] as Timestamp).toDate();
        }

        // ✅ Case 3: old field
        else if (data['subscriptionEndDate'] != null) {
          expiry = (data['subscriptionEndDate'] as Timestamp).toDate();
        }

        // ✅🔥 Case 4: MULTIPLE SUBCOLLECTION CHECK (LATEST FIX)
        if (expiry == null) {

          List<String> possibleSubs = [
            'subscriptions',
            'subscription',
            'plans',
            'user_subscriptions'
          ];

          for (String subName in possibleSubs) {

            final subSnap = await FirebaseFirestore.instance
                .collection(collection)
                .doc(doc.id)
                .collection(subName)
                .orderBy('expiryDate', descending: true) // 🔥 FIX
                .limit(1) // 🔥 FIX
                .get();

            print("Checking subcollection: $subName -> ${subSnap.docs.length}");

            if (subSnap.docs.isNotEmpty) {

              final subData = subSnap.docs.first.data();
              print("LATEST SUB DATA in $subName: $subData");

              if (subData['expiryDate'] != null) {
                expiry =
                    (subData['expiryDate'] as Timestamp).toDate();
                break;
              }
            }
          }
        }

        // 🔥 STATUS AUTO CHANGE
        String status = 'Active';

        if (expiry != null && expiry.isBefore(DateTime.now())) {
          status = 'Inactive';
        }

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

          'status': status,

          'subscriptionEndDate': expiry != null
              ? "${expiry.day}-${expiry.month}-${expiry.year}"
              : 'N/A',

          'partnerName': partner?['name'] ?? '',
          'partnerMobile': partner?['mobile'] ?? '',

          'partnerAddress': partner?['address'] ??
              partner?['village'] ??
              partner?['location'] ??
              '',

          'partnerPincode': partner?['pincode'] ?? '',
        });
      }
    }

    return result;
  }

  Future<void> _exportExcel(
      List<Map<String, dynamic>> data) async {

    var excel = Excel.createExcel();

    excel.delete('Sheet1');

    Sheet sheet = excel['All_Data'];

    sheet.appendRow([
      'Type',
      'Name',
      'Mobile',
      'Village',
      'Mandal',
      'District',
      'State',
      'Status',
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
        item['status'],
        item['subscriptionEndDate'],
        item['partnerName'],
        item['partnerMobile'],
        item['partnerAddress'],
        item['partnerPincode'],
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/AHRA_All_Users.xlsx");

    await file.writeAsBytes(excel.encode()!);

    await Share.shareXFiles([XFile(file.path)]);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel saved at: ${file.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users Export"),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAllUsers(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text("Download Excel"),
                  onPressed: () => _exportExcel(data),
                ),
              ),

              Expanded(
                child: data.isEmpty
                    ? const Center(child: Text("No data found"))
                    : ListView.builder(
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
                                  Text("Status: ${item['status']}"),
                                  Text("Partner: ${item['partnerName']}"),
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