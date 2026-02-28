import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AdminQrScanScreen extends StatefulWidget {
  const AdminQrScanScreen({super.key});

  @override
  State<AdminQrScanScreen> createState() =>
      _AdminQrScanScreenState();
}

class _AdminQrScanScreenState
    extends State<AdminQrScanScreen> {

  bool isScanned = false;

  Future<void> _fetchPartner(String empId) async {

    final snapshot = await FirebaseFirestore.instance
        .collection('partners')
        .where('empId', isEqualTo: empId)
        .get();

    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Partner not found")),
      );
      return;
    }

    final data =
        snapshot.docs.first.data();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Partner Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text("Name: ${data['name'] ?? ''}"),
              Text("Employee ID: ${data['empId'] ?? ''}"),
              Text("Mobile: ${data['mobile'] ?? ''}"),
              Text("State: ${data['state'] ?? ''}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isScanned = false;
                });
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Partner QR"),
        centerTitle: true,
      ),
      body: MobileScanner(
        onDetect: (capture) {

          if (isScanned) return;

          final List<Barcode> barcodes =
              capture.barcodes;

          if (barcodes.isEmpty) return;

          final String? rawValue =
              barcodes.first.rawValue;

          if (rawValue == null) return;

          setState(() {
            isScanned = true;
          });

          // QR format: AHRA|EMPID|NAME|MOBILE
          final parts = rawValue.split('|');

          if (parts.length >= 2) {
            final empId = parts[1];
            _fetchPartner(empId);
          }
        },
      ),
    );
  }
}
