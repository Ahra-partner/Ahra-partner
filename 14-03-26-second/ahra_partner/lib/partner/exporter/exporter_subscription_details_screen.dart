import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'edit_exporter_subscription_screen.dart';

class ExporterSubscriptionDetailsScreen extends StatefulWidget {
  final String exporterId;
  final String subscriptionId;

  const ExporterSubscriptionDetailsScreen({
    super.key,
    required this.exporterId,
    required this.subscriptionId,
  });

  @override
  State<ExporterSubscriptionDetailsScreen> createState() =>
      _ExporterSubscriptionDetailsScreenState();
}

class _ExporterSubscriptionDetailsScreenState
    extends State<ExporterSubscriptionDetailsScreen> {

  File? screenshotFile;
  final txnController = TextEditingController();

  Future<void> _callExporter(String mobile) async {
    final uri = Uri(scheme: 'tel', path: mobile);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _whatsAppExporter(String mobile) async {
    final cleanPhone = mobile.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse("https://wa.me/91$cleanPhone");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // PICK SCREENSHOT
  Future<void> pickScreenshot() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        screenshotFile = File(picked.path);
      });
    }
  }

  // UPLOAD SCREENSHOT
  Future<String> uploadScreenshot(File image) async {

    final ref = FirebaseStorage.instance
        .ref()
        .child('payment_screenshots')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  // DUPLICATE TRANSACTION CHECK
  Future<bool> isDuplicateTxn(String txnId) async {

    final query = await FirebaseFirestore.instance
        .collectionGroup('subscriptions')
        .where('txnId', isEqualTo: txnId)
        .get();

    return query.docs.isNotEmpty;
  }

  // MARK AS PAID (UPDATED)
  Future<void> markAsPaid() async {

    final txnId = txnController.text.trim();

    if (txnId.isEmpty) {
      throw "Enter Transaction ID";
    }

    if (screenshotFile == null) {
      throw "Upload payment screenshot";
    }

    if (await isDuplicateTxn(txnId)) {
      throw "Transaction already used";
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final exporterRef =
        FirebaseFirestore.instance.collection('exporters').doc(widget.exporterId);

    final subRef =
        exporterRef.collection('subscriptions').doc(widget.subscriptionId);

    final screenshotUrl = await uploadScreenshot(screenshotFile!);

//final uid = FirebaseAuth.instance.currentUser!.uid;

await subRef.update({

  "txnId": txnId,
  "screenshotUrl": screenshotUrl,
  "status": "pending_verification",
  "partnerId": uid,
  "submittedAt": FieldValue.serverTimestamp(),

    });
  }

  //final TextEditingController txnController =
    //  TextEditingController();

  @override
  Widget build(BuildContext context) {

    final exporterRef =
        FirebaseFirestore.instance.collection('exporters').doc(widget.exporterId);

    final subRef =
        exporterRef.collection('subscriptions').doc(widget.subscriptionId);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Exporter Subscription Details')),
      body: FutureBuilder(
        future: Future.wait([exporterRef.get(), subRef.get()]),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final exporter =
              (snapshot.data![0] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

          final sub =
              (snapshot.data![1] as DocumentSnapshot).data()
                  as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              _section('Exporter Details'),
              _row('Name', exporter['name'] ?? '-'),
              _row('Mobile', exporter['mobile'] ?? '-'),
              _row('Mandal', exporter['mandal'] ?? '-'),
              _row('District', exporter['district'] ?? '-'),
              _row('State', exporter['state'] ?? '-'),

              const SizedBox(height: 16),

              _section('Subscription Details'),
              _row('Month', sub['month'] ?? '-'),
              _row('Amount', '₹ ${sub['amount'] ?? 0}'),

              const SizedBox(height: 10),

              const Text(
                "Products",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              if ((sub['products'] ?? []).isEmpty)
                const Text("-")
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (sub['products'] as List)
                      .map<Widget>((p) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "${p['name']} - ${p['quantity']} ${p['unit']}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 10),

              _row('Status', sub['status'] ?? '-'),

              const SizedBox(height: 24),

              if (sub['status'] != 'paid') ...[

                const Text(
                  "Transaction ID",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: txnController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Transaction ID",
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: pickScreenshot,
                  child: const Text("Upload Payment Screenshot"),
                ),

                if (screenshotFile != null) ...[
                  const SizedBox(height: 10),
                  const Text("Screenshot Selected"),
                ],

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Paid'),
                  onPressed: () async {
                    try {

                      await markAsPaid();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Payment submitted for verification'),
                        ),
                      );

                      Navigator.pop(context);

                    } catch (e) {

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ERROR: $e')),
                      );
                    }
                  },
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Subscription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditExporterSubscriptionScreen(
                          exporterId: widget.exporterId,
                          subscriptionId: widget.subscriptionId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(k)),
            Expanded(
              flex: 3,
              child: Text(
                v,
                style:
                    const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
}