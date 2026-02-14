import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // ================= BULK REASSIGN FUNCTION =================
  Future<void> _bulkReassign(String newPartnerId) async {

    final farmersSnapshot = await FirebaseFirestore.instance
        .collection('farmers')
        .where('partnerId', isEqualTo: widget.partnerId)
        .get();

    if (farmersSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No farmers to transfer'),
        ),
      );
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    for (var doc in farmersSnapshot.docs) {
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
        return AlertDialog(
          title: const Text('Reassign All Farmers'),
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
        title: const Text('Partner Farmers'),
        centerTitle: true,

        // 🔥 REASSIGN BUTTON
        actions: [
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
                'No farmers found for this partner',
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

              final String farmerName =
                  data['farmerName'] ?? 'No Name';
              final String mobile =
                  data['mobile'] ?? '-';
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
