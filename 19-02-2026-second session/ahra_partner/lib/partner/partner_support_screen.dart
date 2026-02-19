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

    Navigator.pop(context);
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

    final issues =
        issueData[_selectedCategory]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Center"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // CATEGORY SELECT
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: ["Technical", "Payment", "Account"]
                  .map((category) {
                final isSelected =
                    _selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory =
                          category;
                      _selectedIssue = "";
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepPurple
                          : Colors.grey[200],
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // SUB ISSUE LIST
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Select Issue:",
                style: TextStyle(
                    fontWeight:
                        FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Column(
              children: issues.map((issue) {
                return RadioListTile(
                  value: issue,
                  groupValue: _selectedIssue,
                  title: Text(issue),
                  onChanged: (value) {
                    setState(() {
                      _selectedIssue =
                          value.toString();
                      _descController.clear();
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // OTHER OPTION
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration:
                  const InputDecoration(
                labelText:
                    "Other (describe here)",
                border:
                    OutlineInputBorder(),
              ),
              onTap: () {
                setState(() {
                  _selectedIssue = "";
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed:
                  _loading ? null : _submitTicket,
              child: _loading
                  ? const CircularProgressIndicator(
                      color: Colors.white)
                  : const Text("Submit Ticket"),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: _openWhatsApp,
              icon: const Icon(Icons.chat),
              label:
                  const Text("Chat on WhatsApp"),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: _makeCall,
              icon: const Icon(Icons.phone),
              label:
                  const Text("Call Support"),
            ),
          ],
        ),
      ),
    );
  }
}
