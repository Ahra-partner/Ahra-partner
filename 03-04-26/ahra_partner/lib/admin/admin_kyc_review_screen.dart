import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminKycReviewScreen extends StatefulWidget {
  final String partnerId;
  final Map<String, dynamic>? data;

  const AdminKycReviewScreen({
    super.key,
    required this.partnerId,
    this.data,
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

  // ✅ APPROVE
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

  // ❌ REJECT
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
  void dispose() {
    _rejectReasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Review'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partners')
            .doc(widget.partnerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text('Partner data not found'),
            );
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
                _row('Mobile', data['mobile']),
                _row('Email', data['email']),

                const SizedBox(height: 20),

                _title('Address'),
                _row('State', data['state']),
                _row('District', data['district']),
                _row('Mandal', data['mandal']),
                _row('Village', data['village']),
                _row('Pincode', data['pincode']),

                const SizedBox(height: 20),

                _title('KYC Documents'),
                _docStatus(
                  'Aadhaar Front',
                  data['aadhaarFrontUrl'],
                ),
                _docStatus(
                  'Aadhaar Back',
                  data['aadhaarBackUrl'],
                ),
                _docStatus(
                  'PAN Card',
                  data['panCardUrl'], // ✅ FIXED
                ),
                _docStatus(
                  'Photo',
                  data['photoUrl'],
                ),

                const SizedBox(height: 24),

                _title('Admin Action'),

                TextField(
                  controller: _rejectReasonCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText:
                        'Reject reason (required for reject)',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),

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

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _row(String label, dynamic value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          '$label: ${value ?? '-'}',
          style: const TextStyle(fontSize: 14),
        ),
      );

  Widget _docStatus(String title, String? url) {
    final uploaded =
        url != null && url.toString().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        uploaded
            ? '$title: Uploaded'
            : '$title: Not uploaded',
        style: TextStyle(
          color: uploaded ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
