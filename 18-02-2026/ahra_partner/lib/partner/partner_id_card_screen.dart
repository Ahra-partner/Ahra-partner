import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerIdCardScreen extends StatelessWidget {
  const PartnerIdCardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text("Digital ID Card"),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('partners')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          final name = data['name'] ?? '';
          final empId = data['empId'] ?? '';
          final designation =
              data['designation'] ?? 'Relationship Manager';
          final email = data['email'] ?? user.email ?? '';
          final mobile = data['mobile'] ?? '';
          final village = data['village'] ?? '';
          final state = data['state'] ?? '';
          final pincode =
              data['pincode']?.toString() ?? '';
          final photoUrl = data['photoUrl'] ?? '';

          return Center(
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // 🔥 BIGGER CENTERED LOGO
                  Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Image.asset(
                          "assets/logo/ahra_logo.png",
                          height: 110, // 👈 Increased Size
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Ahra Partner",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00897B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Container(
                    height: 4,
                    color: const Color(0xFF00897B),
                  ),

                  const SizedBox(height: 20),

                  // 🔷 Photo + Basic Details
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Container(
                        width: 105,
                        height: 125,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  const Color(0xFF00897B),
                              width: 2),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: photoUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(10),
                                child: Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 60,
                              ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              "Employee ID:",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            Text(empId),

                            const SizedBox(height: 6),

                            const Text(
                              "Designation:",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            Text(
                              designation,
                              style: const TextStyle(
                                color:
                                    Color(0xFF00897B),
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(),

                  _infoRow(Icons.email, email),
                  const SizedBox(height: 6),

                  _infoRow(Icons.phone, mobile),
                  const SizedBox(height: 6),

                  _infoRow(Icons.location_on, "$village, $state"),
                  const SizedBox(height: 6),

                  _infoRow(Icons.pin_drop, pincode),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                            vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        designation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
