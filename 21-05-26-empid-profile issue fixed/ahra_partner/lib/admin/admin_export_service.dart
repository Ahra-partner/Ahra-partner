import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AdminExportService {
  /// 🔽 Export full wallet ledger to CSV
  static Future<void> exportLedgerToCsv() async {
    final snap = await FirebaseFirestore.instance
        .collection('wallet_ledger')
        .orderBy('createdAt')
        .get();

    // 🧾 CSV header
    List<List<dynamic>> rows = [
      [
        'Partner ID',
        'Type',
        'Direction',
        'Amount',
        'Description',
        'Created At',
      ]
    ];

    for (final doc in snap.docs) {
      final data = doc.data();

      rows.add([
        data['partnerId'] ?? '',
        data['type'] ?? '',
        data['direction'] ?? '',
        data['amount'] ?? 0,
        data['description'] ?? '',
        (data['createdAt'] as Timestamp?)?.toDate().toString() ?? '',
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ahra_wallet_ledger.csv');

    await file.writeAsString(csvData);

    // 📤 Share / Download
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'AHRA Wallet Ledger (CSV)',
    );
  }
}
