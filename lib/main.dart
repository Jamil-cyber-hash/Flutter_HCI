import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moto_casher/models/sale.dart';
import 'models/product.dart';
import 'pages/product_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
   Hive.registerAdapter(SaleAdapter());
  await Hive.openBox<Product>('products');
   await Hive.deleteBoxFromDisk('sales');
 await Hive.openBox<Sale>('sales');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductListPage(),
    );
  }
}
