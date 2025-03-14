import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/sale.dart';
import 'sales_history_page.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Box<Product> productBox;
  late Box<Sale> saleBox;

  @override
  void initState() {
    super.initState();
    productBox = Hive.box<Product>('products');
    saleBox = Hive.box<Sale>('sales');
  }

  void addProduct(String name, double price, int stock) {
    final product = Product(name: name, price: price, stock: stock);
    productBox.add(product);
    product.save();
  }

  void checkoutProduct(int index) {
    final product = productBox.getAt(index);

    if (product != null && product.stock > 0) {
      product.stock -= 1;
      product.save();

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

  void _showAddProductDialog() {
    String name = '';
    String price = '';
    String stock = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Product Name'),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (value) => price = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              onChanged: (value) => stock = value,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              if (name.isNotEmpty &&
                  double.tryParse(price) != null &&
                  int.tryParse(stock) != null) {
                addProduct(name, double.parse(price), int.parse(stock));
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: ValueListenableBuilder(
        valueListenable: productBox.listenable(),
        builder: (context, Box<Product> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No products available'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final product = box.getAt(index);
              return ListTile(
                title: Text('${product!.name} - ₱${product.price}'),
                subtitle: Text('Stock: ${product.stock}'),
                trailing: IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () => checkoutProduct(index),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _showAddProductDialog,
            child: Icon(Icons.add),
            heroTag: 'addProduct',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SalesHistoryPage()),
              );
            },
            child: Icon(Icons.history), // ✅ Sales History Button
            heroTag: 'salesHistory',
          ),
        ],
      ),
    );
  }
}
