import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PartnerIdCardScreen extends StatefulWidget {
  const PartnerIdCardScreen({super.key});

  @override
  State<PartnerIdCardScreen> createState() =>
      _PartnerIdCardScreenState();
}

class _PartnerIdCardScreenState
    extends State<PartnerIdCardScreen> {

  bool isLoading = true;

  String name = '';
  String empId = '';
  String email = '';
  String mobile = '';
  String location = '';
  String pincode = '';
  String photoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('partners')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    setState(() {
      name = data['name'] ?? '';
      empId = data['empId'] ?? '';
      email = user.email ?? '';
      mobile = data['mobile'] ?? '';
      location =
          "${data['village'] ?? ''}, ${data['state'] ?? ''}";
      pincode = data['pincode']?.toString() ?? '';
      photoUrl = data['photoUrl'] ?? '';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Digital ID Card")),
      backgroundColor: Colors.grey[200],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const Text(
                      "Ahra Partner",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),

                    const SizedBox(height: 15),

                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                      child: photoUrl.isEmpty
                          ? const Icon(Icons.person,
                              size: 50)
                          : null,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text("Employee ID: $empId"),

                    const SizedBox(height: 8),

                    const Text(
                      "Designation: Relationship Manager",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Divider(height: 25),

                    _infoRow(Icons.email, email),
                    _infoRow(Icons.phone, mobile),
                    _infoRow(Icons.location_on, location),
                    _infoRow(Icons.pin_drop, pincode),

                    const SizedBox(height: 15),

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "Relationship Manager",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 4),
      child: Row(
        children: [
          Icon(icon,
              size: 18, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
