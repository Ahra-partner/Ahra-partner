import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PartnerPendingRequestsScreen extends StatelessWidget {
  final String partnerId;

  const PartnerPendingRequestsScreen({
    super.key,
    required this.partnerId,
  });

  // 📷 PICK + COMPRESS IMAGE
  Future<File?> pickAndCompressImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) return null;

    final compressed = await FlutterImageCompress.compressAndGetFile(
      picked.path,
      "${picked.path}_compressed.jpg",
      quality: 30,
    );

    return File(compressed!.path);
  }

  // ☁️ UPLOAD IMAGE
  Future<String> uploadScreenshot(File image) async {

    final ref = FirebaseStorage.instance
        .ref()
        .child('payment_screenshots')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  // 🔁 RESUBMIT REQUEST (UPDATED WITH IMAGE)
  Future<void> resubmitRequest(
      BuildContext context,
      DocumentReference docRef,
      Map<String, dynamic> data) async {

    final txnController =
        TextEditingController(text: data['transactionNo'] ?? "");

    File? selectedImage;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {

            return AlertDialog(
              title: const Text("Resubmit Payment"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  TextField(
                    controller: txnController,
                    decoration: const InputDecoration(
                      labelText: "Correct Transaction Number",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () async {

                      final image = await pickAndCompressImage();

                      if (image != null) {
                        setState(() {
                          selectedImage = image;
                        });
                      }

                    },
                    child: const Text("Change Screenshot"),
                  ),

                  if (selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.file(
                        selectedImage!,
                        height: 120,
                      ),
                    ),
                ],
              ),
              actions: [

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () async {

                    final txn = txnController.text.trim();

                    if (txn.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enter transaction number"),
                        ),
                      );
                      return;
                    }

                    String screenshotUrl = data['screenshot'];

                    if (selectedImage != null) {
                      screenshotUrl =
                          await uploadScreenshot(selectedImage!);
                    }

                    await docRef.update({
                      "transactionNo": txn,
                      "screenshot": screenshotUrl,
                      "status": "pending_verification",
                      "rejectReason": "",
                      "resubmittedAt": FieldValue.serverTimestamp(),
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Payment resubmitted"),
                      ),
                    );
                  },
                  child: const Text("Resubmit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final query = FirebaseFirestore.instance
        .collectionGroup('subscriptions');

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Payment Requests"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("No requests found"),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No payment requests"),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final doc = docs[index];
              final data =
                  doc.data() as Map<String, dynamic>;

              if (data['partnerId'] != partnerId) {
                return const SizedBox();
              }

              final status = data['status'] ?? "";

              if (status != "pending_verification" &&
                  status != "rejected" &&
                  status != "approved") {
                return const SizedBox();
              }

              final reason = data['rejectReason'] ?? "";
              final screenshot = data['screenshot'] ?? "";

              Color statusColor = Colors.orange;

              if (status == "approved") {
                statusColor = Colors.green;
              } else if (status == "rejected") {
                statusColor = Colors.red;
              }

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Transaction: ${data['transactionNo'] ?? ""}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text("Amount: ₹${data['amount'] ?? 0}"),

                      const SizedBox(height: 10),

                      if (screenshot.isNotEmpty)
                        Image.network(
                          screenshot,
                          height: 150,
                          fit: BoxFit.cover,
                        ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Text("Status: "),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Pending
                      if (status == "pending_verification")
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            "Waiting for admin approval",
                            style: TextStyle(
                              color: Colors.orange,
                            ),
                          ),
                        ),

                      // Rejected
                      if (status == "rejected")
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            const SizedBox(height: 6),

                            Text(
                              "Reject Reason: $reason",
                              style: const TextStyle(
                                  color: Colors.red),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              "Fix and resubmit within 12 hours",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),

                            const SizedBox(height: 10),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              onPressed: () {
                                resubmitRequest(
                                    context,
                                    doc.reference,
                                    data);
                              },
                              child: const Text("Resubmit"),
                            ),
                          ],
                        ),

                      // Approved
                      if (status == "approved")
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            "Payment approved by admin",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}