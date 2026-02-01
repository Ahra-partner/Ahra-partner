import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class ReportExportService {
  /// EXPORT WITHDRAW REPORT (CSV)
  static Future<File> exportWithdrawReportCSV() async {
    final firestore = FirebaseFirestore.instance;

    final querySnapshot =
        await firestore.collection('withdraw_requests').get();

    List<List<dynamic>> rows = [];

    // CSV HEADER
    rows.add([
      'Partner ID',
      'Amount',
      'Status',
      'Requested At',
      'Approved At',
    ]);

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      rows.add([
        data['partnerId'] ?? '',
        data['amount'] ?? 0,
        data['status'] ?? '',
        data['requestedAt'] != null
            ? data['requestedAt'].toDate().toString()
            : '',
        data['approvedAt'] != null
            ? data['approvedAt'].toDate().toString()
            : '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/withdraw_report_${DateTime.now().millisecondsSinceEpoch}.csv');

    await file.writeAsString(csv);
    return file;
  }
}
