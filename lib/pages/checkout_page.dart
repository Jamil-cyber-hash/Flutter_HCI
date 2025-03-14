import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/sale.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Box<Product> productBox;
  late Box<Sale> saleBox;
  double total = 0;

  @override
  void initState() {
    super.initState();
    productBox = Hive.box<Product>('products');
    saleBox = Hive.box<Sale>('sales');
    calculateTotal();
  }

  void calculateTotal() {
    total = 0;
    for (int i = 0; i < productBox.length; i++) {
      final product = productBox.getAt(i);
      if (product != null) {
        total += product.price * product.stock;
      }
    }
    setState(() {});
  }

  void adjustQuantity(int index, int change) {
    final product = productBox.getAt(index);
    if (product != null) {
      if (change > 0) {
        if (product.stock > 0) {
          product.stock -= 1;
          product.save();
        }
      } else if (change < 0) {
        product.stock += 1;
        product.save();
      }
    }
    calculateTotal();
  }

  void confirmCheckout() {
    for (int i = 0; i < productBox.length; i++) {
      final product = productBox.getAt(i);
      if (product != null && product.stock > 0) {
        final sale = Sale(
          productName: product.name,
          price: product.price,
          quantity: 1,
          date: DateTime.now(),
        );
        saleBox.add(sale);
        sale.save();
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checkout Successful!')),
    );

    calculateTotal();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: ValueListenableBuilder(
        valueListenable: productBox.listenable(),
        builder: (context, Box<Product> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No products available for checkout'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final product = box.getAt(index);
              return ListTile(
                title: Text('${product!.name} - ₱${product.price}'),
                subtitle: Text('Stock: ${product.stock}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () => adjustQuantity(index, -1),
                    ),
                    Text('${product.stock}'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => adjustQuantity(index, 1),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        color: Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: ₱${total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: total > 0 ? confirmCheckout : null,
              child: Text('Confirm Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
