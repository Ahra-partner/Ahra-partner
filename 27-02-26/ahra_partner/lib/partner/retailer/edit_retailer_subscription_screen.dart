import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditRetailerSubscriptionScreen extends StatefulWidget {
  final String retailerId;
  final String subscriptionId;

  const EditRetailerSubscriptionScreen({
    super.key,
    required this.retailerId,
    required this.subscriptionId,
  });

  @override
  State<EditRetailerSubscriptionScreen> createState() =>
      _EditRetailerSubscriptionScreenState();
}

class _EditRetailerSubscriptionScreenState
    extends State<EditRetailerSubscriptionScreen> {

  final _formKey = GlobalKey<FormState>();

  String month = '';
  int amount = 0;
  String referenceNumber = '';
  String status = '';

  List<Map<String, dynamic>> products = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection('retailers')
        .doc(widget.retailerId)
        .collection('subscriptions')
        .doc(widget.subscriptionId)
        .get();

    final data = doc.data()!;

    setState(() {
      month = data['month'] ?? '';
      amount = data['amount'] ?? 0;
      referenceNumber = data['referenceNumber'] ?? '';
      status = data['status'] ?? '';

      products = List<Map<String, dynamic>>.from(
        (data['products'] ?? []).map((p) => {
              'name': p['name'] ?? '',
              'quantity': p['quantity'] ?? 0,
              'unit': p['unit'] ?? 'Kg',
            }),
      );

      isLoading = false;
    });
  }

  void addProduct() {
    setState(() {
      products.add({
        'name': '',
        'quantity': 0,
        'unit': 'Kg',
      });
    });
  }

  void removeProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  Future<void> updateSubscription() async {

    if (!_formKey.currentState!.validate()) return;

    // 🔥 Clean products (remove empty & zero qty)
    List<Map<String, dynamic>> cleanedProducts = [];

    for (var p in products) {
      if (p['name'].toString().trim().isNotEmpty &&
          p['quantity'] != 0) {

        cleanedProducts.add({
          'name': p['name'].toString().trim(),
          'quantity': p['quantity'],
          'unit': p['unit'],
        });
      }
    }

    if (cleanedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add valid product details"),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('retailers')
        .doc(widget.retailerId)
        .collection('subscriptions')
        .doc(widget.subscriptionId)
        .set({

      // 🔒 Lock month & amount if paid
      if (status != 'paid') 'month': month,
      if (status != 'paid') 'amount': amount,

      'referenceNumber': referenceNumber,
      'products': cleanedProducts,
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
        title: const Text("Edit Retailer Subscription"),
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
                initialValue: referenceNumber,
                decoration:
                    const InputDecoration(labelText: "Reference Number"),
                onChanged: (v) => referenceNumber = v,
              ),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Products",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              ...products.asMap().entries.map((entry) {
                int index = entry.key;
                var product = entry.value;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [

                        TextFormField(
                          initialValue: product['name'],
                          decoration:
                              const InputDecoration(
                                  labelText: "Product Name"),
                          onChanged: (v) =>
                              product['name'] = v,
                        ),

                        TextFormField(
                          initialValue:
                              product['quantity'].toString(),
                          keyboardType:
                              TextInputType.number,
                          decoration:
                              const InputDecoration(
                                  labelText: "Quantity"),
                          onChanged: (v) =>
                              product['quantity'] =
                                  int.tryParse(v) ?? 0,
                        ),

                        DropdownButtonFormField<String>(
                          value: product['unit'],
                          items: ['Kg', 'Ton', 'Bag']
                              .map((e) =>
                                  DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              product['unit'] = v,
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
                                removeProduct(index),
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
                label: const Text("Add Product"),
                onPressed: addProduct,
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