import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminKycDetailScreen extends StatefulWidget {
  final String partnerId;
  final Map<String, dynamic> data;

  const AdminKycDetailScreen({
    super.key,
    required this.partnerId,
    required this.data,
  });

  @override
  State<AdminKycDetailScreen> createState() => _AdminKycDetailScreenState();
}

class _AdminKycDetailScreenState extends State<AdminKycDetailScreen> {
  final TextEditingController rejectReasonController =
      TextEditingController();

  bool loading = false;

  // ---------------- APPROVE ----------------

  Future<void> approveKyc() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .update({
      'kycStatus': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    setState(() => loading = false);

    Navigator.pop(context); // back to pending list
  }

  // ---------------- REJECT (FIXED) ----------------

  Future<void> rejectKyc() async {
    final reason = rejectReasonController.text.trim();

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter rejection reason'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .update({
      'kycStatus': 'rejected',
      'rejectionReason': reason,
      'rejectedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    setState(() => loading = false);

    Navigator.pop(context); // back to pending list
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Details'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -------- BASIC INFO --------
                  _infoTile('Name', data['name'] ?? '-'),
                  _infoTile('Phone', data['phone'] ?? '-'),
                  _infoTile('PAN', data['pan'] ?? '-'),
                  _infoTile('Aadhaar', data['aadhaar'] ?? '-'),

                  const SizedBox(height: 20),

                  // -------- KYC IMAGES --------
                  const Text(
                    'KYC Images',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _imagePreview(
                    'Passport Photo',
                    data['selfieUrl'],
                  ),
                  _imagePreview(
                    'Aadhaar Front',
                    data['aadhaarFrontUrl'],
                  ),
                  _imagePreview(
                    'Aadhaar Back',
                    data['aadhaarBackUrl'],
                  ),
                  _imagePreview(
                    'PAN Card',
                    data['panCardUrl'],
                  ),

                  const SizedBox(height: 30),

                  // -------- REJECTION REASON --------
                  TextField(
                    controller: rejectReasonController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Rejection Reason (if rejecting)',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // -------- ACTION BUTTONS --------
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: approveKyc,
                          child: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: rejectKyc,
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _imagePreview(String title, String? url) {
    if (url == null || url.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text('$title: Not uploaded'),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Text('Failed to load image'),
            ),
          ),
        ],
      ),
    );
  }
}
