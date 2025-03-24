import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/sale.dart';

class CheckoutPage extends StatefulWidget {
  final Map<int, int> selectedProducts;
  final Box<Product> productBox;

  const CheckoutPage({
    super.key,
    required this.selectedProducts,
    required this.productBox,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  double totalPrice = 0;
  TextEditingController paymentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    calculateTotal();
  }

  void calculateTotal() {
    setState(() {
      totalPrice = widget.selectedProducts.entries.fold(0, (sum, entry) {
        final product = widget.productBox.getAt(entry.key);
        if (product != null) {
          return sum + (product.price * entry.value);
        }
        return sum;
      });
    });
  }

  void completeCheckout() {
    final saleBox = Hive.box<Sale>('sales');
    double paymentAmount = double.tryParse(paymentController.text) ?? 0;

    if (paymentAmount < totalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient payment amount')),
      );
      return;
    }

    double change = paymentAmount - totalPrice;

    widget.selectedProducts.forEach((key, quantity) {
      final product = widget.productBox.getAt(key);
      if (product != null && product.stock >= quantity) {
        widget.productBox.putAt(
          key,
          Product(
            name: product.name,
            price: product.price,
            stock: product.stock - quantity,
            category: product.category,
          ),
        );

        saleBox.add(
          Sale(
            productName: product.name,
            price: product.price,
            quantity: quantity,
            totalAmount: product.price * quantity,
            date: DateTime.now(),
          ),
        );
      }
    });

    widget.selectedProducts.clear();
    calculateTotal();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checkout successful! Change: ₱${change.toStringAsFixed(2)}')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.selectedProducts.length,
              itemBuilder: (context, index) {
                final key = widget.selectedProducts.keys.elementAt(index);
                final product = widget.productBox.getAt(key);
                if (product == null) return const SizedBox();

                return ListTile(
                  title: Text('${product.name} - ₱${product.price}'),
                  subtitle: Text('Quantity: ${widget.selectedProducts[key]}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        widget.selectedProducts.remove(key);
                        calculateTotal();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Total: ₱${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: paymentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Enter amount paid'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: widget.selectedProducts.isEmpty ? null : completeCheckout,
                  child: const Text('Complete Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
