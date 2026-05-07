import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProcessorSubscriptionScreen extends StatefulWidget {
  final String processorId;
  final String subscriptionId;

  const EditProcessorSubscriptionScreen({
    super.key,
    required this.processorId,
    required this.subscriptionId,
  });

  @override
  State<EditProcessorSubscriptionScreen> createState() =>
      _EditProcessorSubscriptionScreenState();
}

class _EditProcessorSubscriptionScreenState
    extends State<EditProcessorSubscriptionScreen> {

  final _formKey = GlobalKey<FormState>();

  String month = '';
  int amount = 0;
  String transactionNo = '';
  String status = '';

  List<Map<String, dynamic>> services = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection('processors')
        .doc(widget.processorId)
        .collection('subscriptions')
        .doc(widget.subscriptionId)
        .get();

    final data = doc.data()!;

    setState(() {
      month = data['month'] ?? '';
      amount = data['amount'] ?? 0;
      transactionNo = data['transactionNo'] ?? '';
      status = data['status'] ?? '';

      services = List<Map<String, dynamic>>.from(
        (data['services'] ?? []).map((s) => {
              'name': s['name'] ?? '',
              'quantity': s['quantity'] ?? 0,
              'unit': s['unit'] ?? 'Kg',
            }),
      );

      isLoading = false;
    });
  }

  void addService() {
    setState(() {
      services.add({
        'name': '',
        'quantity': 0,
        'unit': 'Kg',
      });
    });
  }

  void removeService(int index) {
    setState(() {
      services.removeAt(index);
    });
  }

  Future<void> updateSubscription() async {

    if (!_formKey.currentState!.validate()) return;

    // 🔥 Clean services
    List<Map<String, dynamic>> cleanedServices = [];

    for (var s in services) {
      if (s['name'].toString().trim().isNotEmpty &&
          s['quantity'] != 0) {

        cleanedServices.add({
          'name': s['name'].toString().trim(),
          'quantity': s['quantity'],
          'unit': s['unit'],
        });
      }
    }

    if (cleanedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add valid service details"),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('processors')
        .doc(widget.processorId)
        .collection('subscriptions')
        .doc(widget.subscriptionId)
        .set({

      // 🔒 Lock month & amount if paid
      if (status != 'paid') 'month': month,
      if (status != 'paid') 'amount': amount,

      'transactionNo': transactionNo,
      'services': cleanedServices,
      'updatedAt': FieldValue.serverTimestamp(),
      'isCorrected': true,

    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Subscription Updated Successfully"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    bool isPaid = status == 'paid';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Processor Subscription"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                initialValue: month,
                enabled: !isPaid,
                decoration:
                    const InputDecoration(labelText: "Month"),
                onChanged: (v) => month = v,
                validator: (v) =>
                    v!.isEmpty ? "Month required" : null,
              ),

              TextFormField(
                initialValue: amount.toString(),
                enabled: !isPaid,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Amount"),
                onChanged: (v) =>
                    amount = int.tryParse(v) ?? 0,
                validator: (v) =>
                    v!.isEmpty ? "Amount required" : null,
              ),

              TextFormField(
                initialValue: transactionNo,
                decoration:
                    const InputDecoration(labelText: "Transaction No"),
                onChanged: (v) => transactionNo = v,
              ),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Services",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              ...services.asMap().entries.map((entry) {
                int index = entry.key;
                var service = entry.value;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [

                        TextFormField(
                          initialValue: service['name'],
                          decoration:
                              const InputDecoration(
                                  labelText: "Service Name"),
                          onChanged: (v) =>
                              service['name'] = v,
                        ),

                        TextFormField(
                          initialValue:
                              service['quantity'].toString(),
                          keyboardType:
                              TextInputType.number,
                          decoration:
                              const InputDecoration(
                                  labelText: "Quantity"),
                          onChanged: (v) =>
                              service['quantity'] =
                                  int.tryParse(v) ?? 0,
                        ),

                        DropdownButtonFormField<String>(
                          value: service['unit'],
                          items: ['Kg', 'Ton', 'Bag']
                              .map((e) =>
                                  DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              service['unit'] = v,
                          decoration:
                              const InputDecoration(
                                  labelText: "Unit"),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                removeService(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Service"),
                onPressed: addService,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: updateSubscription,
                child: const Text("Update Subscription"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}