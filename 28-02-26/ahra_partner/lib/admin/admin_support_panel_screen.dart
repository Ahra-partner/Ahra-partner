import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSupportPanelScreen extends StatefulWidget {
  const AdminSupportPanelScreen({super.key});

  @override
  State<AdminSupportPanelScreen> createState() =>
      _AdminSupportPanelScreenState();
}

class _AdminSupportPanelScreenState
    extends State<AdminSupportPanelScreen> {

  String _statusFilter = "All";
  String _searchText = "";

  @override
  Widget build(BuildContext context) {

    Query query = FirebaseFirestore.instance
        .collection('support_tickets')
        .orderBy('createdAt', descending: true);

    if (_statusFilter != "All") {
      query = query.where('status', isEqualTo: _statusFilter);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Tickets"),
        centerTitle: true,
      ),
      body: Column(
        children: [

          // 🔍 Search Field
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search by Partner Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),

          // 🔄 Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonFormField<String>(
              value: _statusFilter,
              items: const [
                DropdownMenuItem(
                    value: "All", child: Text("All")),
                DropdownMenuItem(
                    value: "Open", child: Text("Open")),
                DropdownMenuItem(
                    value: "Closed", child: Text("Closed")),
              ],
              onChanged: (value) {
                setState(() {
                  _statusFilter = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Filter by Status",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 📋 Ticket List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;
                  final partnerName =
                      (data['partnerName'] ?? "")
                          .toString()
                          .toLowerCase();
                  return partnerName
                      .contains(_searchText);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                      child: Text("No tickets found"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final data =
                        docs[index].data()
                            as Map<String, dynamic>;

                    final ticketId =
                        data['ticketId'] ?? '';
                    final partnerName =
                        data['partnerName'] ?? '';
                    final issueType =
                        data['issueType'] ?? '';
                    final status =
                        data['status'] ?? 'Open';

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          "$ticketId - $partnerName",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            "Issue: $issueType\nStatus: $status"),
                        trailing: const Icon(
                            Icons.arrow_forward_ios),
                        onTap: () {
                          _openTicketDetails(
                              docs[index].id, data);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= TICKET DETAILS =================

  void _openTicketDetails(
      String docId, Map<String, dynamic> data) {

    final replyController =
        TextEditingController(
            text: data['adminReply'] ?? '');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(data['ticketId'] ?? ''),
          content: SingleChildScrollView(
            child: Column(
              children: [

                Text("Partner: ${data['partnerName']}"),
                const SizedBox(height: 8),
                Text("Issue: ${data['issueType']}"),
                const SizedBox(height: 8),
                Text("Description:\n${data['description']}"),
                const SizedBox(height: 12),

                TextField(
                  controller: replyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Admin Reply",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [

            // 🔄 Change Status
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('support_tickets')
                    .doc(docId)
                    .update({
                  'status': data['status'] == 'Open'
                      ? 'Closed'
                      : 'Open',
                  'updatedAt':
                      FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
              },
              child: const Text("Toggle Status"),
            ),

            // 💾 Save Reply
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('support_tickets')
                    .doc(docId)
                    .update({
                  'adminReply':
                      replyController.text.trim(),
                  'updatedAt':
                      FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
              },
              child: const Text("Save Reply"),
            ),
          ],
        );
      },
    );
  }
}
