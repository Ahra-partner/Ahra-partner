import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPartnerFarmersScreen extends StatefulWidget {
  final String partnerId;

  const AdminPartnerFarmersScreen({
    super.key,
    required this.partnerId,
  });

  @override
  State<AdminPartnerFarmersScreen> createState() =>
      _AdminPartnerFarmersScreenState();
}

class _AdminPartnerFarmersScreenState
    extends State<AdminPartnerFarmersScreen> {

  // ================= BULK WHATSAPP BROADCAST =================
  Future<void> _broadcastWhatsApp() async {

    final snapshot = await FirebaseFirestore.instance
        .collection('farmers')
        .get();

    final filteredDocs = snapshot.docs.where((doc) {
      final data = doc.data();
      return data['partnerId'] == widget.partnerId;
    }).toList();

    if (filteredDocs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No farmers found'),
        ),
      );
      return;
    }

    const message =
        "Dear Farmer, Please check latest update from AHRA.";

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

    print("Widget PartnerId: ${widget.partnerId}");

    final farmersSnapshot = await FirebaseFirestore.instance
        .collection('farmers')
        .get();

    final filteredDocs = farmersSnapshot.docs.where((doc) {
      final data = doc.data();
      return data['partnerId'] == widget.partnerId;
    }).toList();

    print("Matched Farmers: ${filteredDocs.length}");

    if (filteredDocs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No farmers to transfer'),
        ),
      );
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    for (var doc in filteredDocs) {
      batch.update(doc.reference, {
        'partnerId': newPartnerId,
      });
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Farmers reassigned successfully'),
      ),
    );
  }

  // ================= REASSIGN DIALOG =================
  void _showReassignDialog() {
    String? selectedPartnerId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Reassign All Farmers'),
              content: SizedBox(
                width: double.maxFinite,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('partners')
                      .snapshots(),
                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final partners = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final isActive = data['isActive'];

                      return doc.id != widget.partnerId &&
                          (isActive == true || isActive == null);
                    }).toList();

                    if (partners.isEmpty) {
                      return const Text(
                          'No active partners available');
                    }

                    return DropdownButtonFormField<String>(
                      value: selectedPartnerId,
                      items: partners.map((doc) {
                        final data =
                            doc.data() as Map<String, dynamic>;

                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(data['name'] ?? doc.id),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedPartnerId = value;
                        });
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

                    if (selectedPartnerId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select partner"),
                        ),
                      );
                      return;
                    }

                    try {
                      final allDocs = await FirebaseFirestore.instance
                          .collection('farmers')
                          .get();

                      int updatedCount = 0;

                      for (var doc in allDocs.docs) {
                        final data = doc.data();

                        if (data['partnerId'] == widget.partnerId) {
                          await doc.reference.update({
                            'partnerId': selectedPartnerId,
                          });

                          updatedCount++;
                        }
                      }

                      print("UPDATED COUNT: $updatedCount");

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("✅ $updatedCount farmers reassigned"),
                        ),
                      );

                    } catch (e) {
                      print("ERROR: $e");

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("❌ Error: $e"),
                        ),
                      );
                    }
                  },
                  child: const Text('Transfer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Farmers'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign),
            tooltip: 'Broadcast WhatsApp',
            onPressed: _broadcastWhatsApp,
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Reassign All Farmers',
            onPressed: _showReassignDialog,
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('farmers')
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No farmers found for this partner',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['partnerId'] == widget.partnerId;
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No farmers found for this partner',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data =
                  docs[index].data()
                      as Map<String, dynamic>;

              final String farmerName =
                  data['farmerName'] ?? 'No Name';
              final String mobile =
                  data['mobile'] ?? '';
              final String village =
                  data['village'] ?? '-';

              return Card(
                margin:
                    const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.agriculture,
                    color: Colors.green,
                  ),
                  title: Text(
                    farmerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Mobile: $mobile\nVillage: $village',
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

                            try {
                              await launchUrl(uri);
                            } catch (e) {
                              debugPrint("Dial error: $e");
                            }
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