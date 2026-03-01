import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class PartnerSupportScreen extends StatefulWidget {
  const PartnerSupportScreen({super.key});

  @override
  State<PartnerSupportScreen> createState() =>
      _PartnerSupportScreenState();
}

class _PartnerSupportScreenState
    extends State<PartnerSupportScreen> {

  final TextEditingController _descController =
      TextEditingController();

  bool _loading = false;

  String _selectedCategory = "Technical";
  String _selectedIssue = "";

  final Map<String, List<String>> issueData = {
    "Technical": [
      "Farmer button not opening",
      "Retailer button not opening",
      "Wholesaler button not opening",
      "Processor button not opening",
      "Exporter button not opening",
      "App crash",
      "Login problem",
      "QR scan not working",
      "Screen blank",
      "Data not saving",
      "App slow",
    ],
    "Payment": [
      "Wallet balance wrong",
      "Withdraw not approved",
      "Amount deducted not reflected",
      "Commission wrong",
      "Subscription issue",
      "Double payment",
    ],
    "Account": [
      "Mobile number change",
      "Bank details update",
      "KYC rejected",
      "Password reset",
      "Account blocked",
      "ID card issue",
    ],
  };

  String _generateTicketId() {
    return "TKT-${DateTime.now().millisecondsSinceEpoch}";
  }

  Future<void> _submitTicket() async {

    if (_selectedIssue.isEmpty &&
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Please select or describe issue")),
      );
      return;
    }

    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser!;
    final partnerDoc = await FirebaseFirestore.instance
        .collection('partners')
        .doc(user.uid)
        .get();

    final partnerData =
        partnerDoc.data() as Map<String, dynamic>;

    final ticketId = _generateTicketId();

    final description =
        _selectedIssue.isNotEmpty
            ? _selectedIssue
            : _descController.text.trim();

    await FirebaseFirestore.instance
        .collection('support_tickets')
        .doc(ticketId)
        .set({
      "ticketId": ticketId,
      "partnerId": user.uid,
      "partnerName": partnerData['name'] ?? '',
      "mobile": partnerData['mobile'] ?? '',
      "issueType": _selectedCategory,
      "description": description,
      "status": "Open",
      "adminReply": "",
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Ticket Created: $ticketId"),
      ),
    );

    _descController.clear();
    setState(() {
      _selectedIssue = "";
    });
  }

  void _openWhatsApp() async {
    const number = "6362384841";

    final message =
        "Hi AHRA Support,\nCategory: $_selectedCategory\nIssue: ${_selectedIssue.isNotEmpty ? _selectedIssue : _descController.text.trim()}";

    final url =
        "https://wa.me/$number?text=${Uri.encodeComponent(message)}";

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void _makeCall() async {
    const number = "6362384841";
    final Uri uri = Uri.parse("tel:$number");
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser!;
    final issues = issueData[_selectedCategory]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Center"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= CATEGORY + QUICK ACTIONS =================

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [

                  ...["Technical", "Payment", "Account"]
                      .map((category) {
                    final isSelected =
                        _selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                            _selectedIssue = "";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.grey[200],
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // WhatsApp Button
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _openWhatsApp,
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text("WhatsApp"),
                    ),
                  ),

                  // Call Button
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _makeCall,
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text("Call"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= ISSUE LIST =================

            Column(
              children: issues.map((issue) {
                return RadioListTile(
                  value: issue,
                  groupValue: _selectedIssue,
                  title: Text(issue),
                  onChanged: (value) {
                    setState(() {
                      _selectedIssue = value.toString();
                      _descController.clear();
                    });
                  },
                );
              }).toList(),
            ),

            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Other (describe here)",
                border: OutlineInputBorder(),
              ),
              onTap: () {
                setState(() {
                  _selectedIssue = "";
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loading ? null : _submitTicket,
              child: _loading
                  ? const CircularProgressIndicator(
                      color: Colors.white)
                  : const Text("Submit Ticket"),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "My Tickets",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('support_tickets')
                  .where('partnerId',
                      isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        "Error: ${snapshot.error}"),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                      child:
                          CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text(
                      "No tickets yet");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final data =
                        docs[index].data()
                            as Map<String, dynamic>;

                    final status =
                        data['status'] ?? 'Open';
                    final adminReply =
                        data['adminReply'] ?? '';

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                            data['ticketId'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text("Status: $status"),
                            Text(
                                "Issue: ${data['description']}"),
                            if (adminReply.isNotEmpty)
                              Text(
                                "Admin Reply: $adminReply",
                                style:
                                    const TextStyle(
                                  color: Colors.green,
                                  fontWeight:
                                      FontWeight.bold,
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
          ],
        ),
      ),
    );
  }
}