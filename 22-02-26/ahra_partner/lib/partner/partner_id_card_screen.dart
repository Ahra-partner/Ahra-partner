import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PartnerIdCardScreen extends StatefulWidget {
  const PartnerIdCardScreen({super.key});

  @override
  State<PartnerIdCardScreen> createState() =>
      _PartnerIdCardScreenState();
}

class _PartnerIdCardScreenState
    extends State<PartnerIdCardScreen> {

  Future<void> _downloadPdf(
      Map<String, dynamic> data) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [
              pw.Text("AHRA PARTNER ID CARD",
                  style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight:
                          pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text("Name: ${data['name'] ?? ''}"),
              pw.Text("Employee ID: ${data['empId'] ?? ''}"),
              pw.Text("Designation: ${data['designation'] ?? 'Relationship Manager'}"),
              pw.Text("Mobile: ${data['mobile'] ?? ''}"),
              pw.Text("Email: ${data['email'] ?? ''}"),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (format) async =>
            pdf.save());
  }

  Future<void> _shareIdCard(
      String empId,
      String name,
      String mobile) async {

    await Share.share(
        "AHRA Partner ID\n\n"
        "Name: $name\n"
        "Employee ID: $empId\n"
        "Mobile: $mobile");
  }

  @override
  Widget build(BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title:
            const Text("Digital ID Card"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final doc =
                  await FirebaseFirestore
                      .instance
                      .collection('partners')
                      .doc(user.uid)
                      .get();

              _downloadPdf(doc.data()
                  as Map<String, dynamic>);
            },
          ),
        ],
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore
            .instance
            .collection('partners')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
                child:
                    CircularProgressIndicator());
          }

          final data =
              snapshot.data!.data()
                  as Map<String, dynamic>;

          final name = data['name'] ?? '';
          final empId = data['empId'] ?? '';

          // ✅ FIX: Default designation fallback
          final designation =
              (data['designation'] == null ||
                      data['designation']
                          .toString()
                          .isEmpty)
                  ? "Relationship Manager"
                  : data['designation'];

          final email =
              data['email'] ??
                  user.email ??
                  '';
          final mobile =
              data['mobile'] ?? '';
          final village =
              data['village'] ?? '';
          final state =
              data['state'] ?? '';
          final pincode =
              data['pincode']
                      ?.toString() ??
                  '';
          final photoUrl =
              data['photoUrl'] ?? '';

          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: 340,
                padding:
                    const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                          22),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 16,
                      offset:
                          Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [

                    Image.asset(
                      "assets/logo/ahra_logo.png",
                      height: 110,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Ahra Partner",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF00897B),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      height: 4,
                      color:
                          const Color(0xFF00897B),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Container(
                          width: 105,
                          height: 125,
                          decoration:
                              BoxDecoration(
                            border: Border.all(
                                color: const Color(
                                    0xFF00897B),
                                width: 2),
                            borderRadius:
                                BorderRadius
                                    .circular(12),
                          ),
                          child: photoUrl
                                  .isNotEmpty
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              10),
                                  child:
                                      Image.network(
                                    photoUrl,
                                    fit: BoxFit
                                        .cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Text(
                                name,
                                style:
                                    const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                "Employee ID:",
                                style:
                                    TextStyle(
                                  color: Colors.orange,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              Text(empId),

                              const SizedBox(height: 6),

                              const Text(
                                "Designation:",
                                style:
                                    TextStyle(
                                  color: Colors.orange,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              // ✅ Now always visible
                              Text(
                                designation,
                                style:
                                    const TextStyle(
                                  color: Color(
                                      0xFF00897B),
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),

                    QrImageView(
                      data:
                          "AHRA|$empId|$name|$mobile",
                      size: 90,
                    ),

                    const SizedBox(height: 14),
                    const Divider(),

                    _infoRow(Icons.email, email),
                    const SizedBox(height: 6),
                    _infoRow(Icons.phone, mobile),
                    const SizedBox(height: 6),
                    _infoRow(Icons.location_on,
                        "$village, $state"),
                    const SizedBox(height: 6),
                    _infoRow(Icons.pin_drop,
                        pincode),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: () =>
                          _shareIdCard(
                              empId,
                              name,
                              mobile),
                      icon: const Icon(Icons.share),
                      label:
                          const Text("Share ID Card"),
                    ),

                    const SizedBox(height: 16),

                    // ✅ Bottom designation also guaranteed
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                              vertical: 14),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF00897B),
                        borderRadius:
                            BorderRadius.circular(
                                12),
                      ),
                      child: Center(
                        child: Text(
                          designation,
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(
      IconData icon, String text) {
    return Row(
      children: [
        Icon(icon,
            color: Colors.orange,
            size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style:
                const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
