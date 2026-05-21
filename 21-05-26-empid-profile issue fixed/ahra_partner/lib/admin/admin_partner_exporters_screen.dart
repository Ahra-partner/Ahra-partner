import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPartnerExportersScreen extends StatefulWidget {
  final String partnerId;

  const AdminPartnerExportersScreen({
    super.key,
    required this.partnerId,
  });

  @override
  State<AdminPartnerExportersScreen> createState() =>
      _AdminPartnerExportersScreenState();
}

class _AdminPartnerExportersScreenState
    extends State<AdminPartnerExportersScreen> {

  // ================= BULK WHATSAPP BROADCAST =================
  Future<void> _broadcastWhatsApp() async {

    final snapshot = await FirebaseFirestore.instance
        .collection('exporters')
        .where('partnerId', isEqualTo: widget.partnerId)
        .get();

    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No exporters found'),
        ),
      );
      return;
    }

    const message =
        "Dear Exporter, Please check latest update from AHRA.";

    final Uri uri = Uri.parse(
      "whatsapp://send?text=${Uri.encodeComponent(message)}",
    );

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint("WhatsApp error: $e");
    }
  }

  // ================= BULK REASSIGN FUNCTION =================
  Future<void> _bulkReassign(String newPartnerId) async {

    final snapshot = await FirebaseFirestore.instance
        .collection('exporters')
        .where('partnerId', isEqualTo: widget.partnerId)
        .get();

    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No exporters to transfer'),
        ),
      );
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {
        'partnerId': newPartnerId,
      });
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Exporters reassigned successfully'),
      ),
    );
  }

  // ================= REASSIGN DIALOG =================
  void _showReassignDialog() {
    String? selectedPartnerId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reassign All Exporters'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('partners')
                  .where('status', isEqualTo: 'active')
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final partners = snapshot.data!.docs
                    .where((doc) =>
                        doc.id != widget.partnerId)
                    .toList();

                if (partners.isEmpty) {
                  return const Text(
                      'No active partners available');
                }

                return DropdownButtonFormField<String>(
                  items: partners.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc.id),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedPartnerId = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select New Partner',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {

                if (selectedPartnerId == null) return;

                Navigator.pop(context);

                await _bulkReassign(
                  selectedPartnerId!,
                );
              },
              child: const Text('Transfer'),
            ),
          ],
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Exporters'),
        centerTitle: true,
        actions: [

          // 📢 WHATSAPP BROADCAST
          IconButton(
            icon: const Icon(Icons.campaign),
            tooltip: 'Broadcast WhatsApp',
            onPressed: _broadcastWhatsApp,
          ),

          // 🔁 REASSIGN
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Reassign All Exporters',
            onPressed: _showReassignDialog,
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exporters')
            .where('partnerId',
                isEqualTo: widget.partnerId)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No exporters found for this partner',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data =
                  docs[index].data()
                      as Map<String, dynamic>;

              final String name =
                  data['name'] ?? 'No Name';
              final String mobile =
                  data['mobile'] ?? '';
              final String businessName =
                  data['businessName'] ?? '-';

              return Card(
                margin:
                    const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.local_shipping,
                    color: Colors.teal,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Mobile: $mobile\nBusiness: $businessName',
                  ),

                  trailing: mobile.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.phone,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            final Uri uri =
                                Uri.parse("tel:$mobile");
                            await launchUrl(uri);
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
