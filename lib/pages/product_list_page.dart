import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import 'checkout_page.dart';


class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Box<Product> productBox;
  Map<int, int> selectedProducts = {};

  @override
  void initState() {
    super.initState();
    productBox = Hive.box<Product>('products');
  }

  void updateSelection(int index, int quantity) {
    setState(() {
      if (quantity > 0) {
        selectedProducts[index] = quantity;
      } else {
        selectedProducts.remove(index);
      }
    });
  }

  // ✅ Ipakita ang dialog para mag-add/edit og product
  void _showProductDialog({int? index}) {
    String name = '';
    String price = '';
    String stock = '';

    if (index != null) {
      final product = productBox.getAt(index);
      name = product!.name;
      price = product.price.toString();
      stock = product.stock.toString();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(index == null ? 'Add Product' : 'Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Product Name'),
              onChanged: (value) => name = value,
              controller: TextEditingController(text: name),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (value) => price = value,
              controller: TextEditingController(text: price),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              onChanged: (value) => stock = value,
              controller: TextEditingController(text: stock),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (name.isNotEmpty &&
                  double.tryParse(price) != null &&
                  int.tryParse(stock) != null) {
                if (index == null) {
                  productBox.add(
                    Product(
                      name: name,
                      price: double.parse(price),
                      stock: int.parse(stock),
                    ),
                  );
                } else {
                  productBox.putAt(
                    index,
                    Product(
                      name: name,
                      price: double.parse(price),
                      stock: int.parse(stock),
                    ),
                  );
                }
                Navigator.of(context).pop();
                setState(() {});
              }
            },
            child: Text(index == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(int index) {
    productBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Motorcycle Accessory Shop')),
      body: ValueListenableBuilder(
        valueListenable: productBox.listenable(),
        builder: (context, Box<Product> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No products available'));
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
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showProductDialog(index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteProduct(index),
                    ),
                  ],
                ),
                onTap: () => _showQuantityDialog(index, product),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (selectedProducts.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(
                      selectedProducts: selectedProducts,
                      productBox: productBox,
                    ),
                  ),
                );
              }
            },
            child: const Icon(Icons.shopping_cart),
            heroTag: 'checkoutBtn',
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _showProductDialog(),
            child: const Icon(Icons.add),
            heroTag: 'addBtn',
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
            Navigator.pushNamed(context, '/sales_history');
          },
          child: const Icon(Icons.history),
          heroTag: 'salesHistoryBtn',
          ),

          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/sales_summary');
            },
            child: const Icon(Icons.bar_chart),
            heroTag: 'salessummaryBtn',
          ),


        ],
      ),
    );
  }

  void _showQuantityDialog(int index, Product product) {
    int quantity = selectedProducts[index] ?? 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Quantity'),
        content: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            quantity = int.tryParse(value) ?? 0;
          },
          controller: TextEditingController(text: quantity.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (quantity > product.stock) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Not enough stock available')),
                );
              } else {
                updateSelection(index, quantity);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
