import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminKycReviewScreen extends StatefulWidget {
  final String partnerId;

  const AdminKycReviewScreen({
    super.key,
    required this.partnerId,
  });

  @override
  State<AdminKycReviewScreen> createState() =>
      _AdminKycReviewScreenState();
}

class _AdminKycReviewScreenState
    extends State<AdminKycReviewScreen> {
  final TextEditingController _rejectReasonCtrl =
      TextEditingController();

  bool _loading = false;

  Future<void> _approveKyc() async {
    setState(() => _loading = true);

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .update({
      'kycStatus': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
      'rejectionReason': null,
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _rejectKyc() async {
    if (_rejectReasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter rejection reason'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .update({
      'kycStatus': 'rejected',
      'rejectionReason': _rejectReasonCtrl.text.trim(),
      'rejectedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Review'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .doc(widget.partnerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title('Basic Details'),
                _row('Name', data['name']),
                _row('Phone', data['phone']),
                _row('Email', data['email']),

                const SizedBox(height: 20),

                _title('KYC Documents'),
                _docLink('Aadhaar Front',
                    data['aadhaarFrontUrl']),
                _docLink('Aadhaar Back',
                    data['aadhaarBackUrl']),
                _docLink('PAN Card', data['panUrl']),
                _docLink('Photo', data['photoUrl']),

                const SizedBox(height: 24),

                _title('Action'),

                TextField(
                  controller: _rejectReasonCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reject reason (required)',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                if (_loading)
                  const Center(
                      child: CircularProgressIndicator()),

                if (!_loading)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: _approveKyc,
                          child: const Text('APPROVE'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: _rejectKyc,
                          child: const Text('REJECT'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _title(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _row(String label, String? value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text('$label: ${value ?? '-'}'),
      );

  Widget _docLink(String title, String? url) {
    if (url == null || url.isEmpty) {
      return Text('$title: Not uploaded');
    }

    return Text(
      '$title: Uploaded',
      style: const TextStyle(color: Colors.green),
    );
  }
}
