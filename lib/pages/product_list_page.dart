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
  String _sortType = 'name'; // Default sorting type
  String _searchQuery = ''; // Search query

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

  // ✅ Sort and Search Products
  List<Product> _getFilteredProducts() {
    List<Product> products = productBox.values.toList();

    if (_searchQuery.isNotEmpty) {
      products = products
          .where((product) => product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    switch (_sortType) {
      case 'price':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'stock':
        products.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      default:
        products.sort((a, b) => a.name.compareTo(b.name)); // Default: Name
    }
    return products;
  }

  void _changeSorting(String sortType) {
    setState(() {
      _sortType = sortType;
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = _getFilteredProducts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Motorcycle Accessory Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(productBox.values.toList(), _updateSearchQuery),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: _changeSorting,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'price', child: Text('Sort by Price')),
              const PopupMenuItem(value: 'stock', child: Text('Sort by Stock')),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: productBox.listenable(),
        builder: (context, Box<Product> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          return ListView.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return ListTile(
                title: Text('${product.name} - ₱${product.price}'),
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
            onPressed: () => _showProductDialog(index: null),
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
  
  Widget _showProductDialog({int? index}) {
    return Container(); // Replace with your actual widget
  }
}

Widget _showQuantityDialog(int index, Product product) {
  return Container(); // Replace with your actual widget
}

Widget _deleteProduct(int index) {
  // Add your delete logic here
  return Container(); // Return an empty container or any other widget
}

// Search Delegate for Searching Products
class ProductSearchDelegate extends SearchDelegate {
  final List<Product> products;
  final Function(String) onSearch;

  ProductSearchDelegate(this.products, this.onSearch);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Product> filteredProducts = products
        .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ListTile(
          title: Text('${product.name} - ₱${product.price}'),
          subtitle: Text('Stock: ${product.stock}'),
          onTap: () {
            close(context, null);
            onSearch(product.name);
          },
        );
      },
    );
  }
}
