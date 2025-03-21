import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/sale.dart';

class DailySalesPage extends StatelessWidget {
  final Box<Sale> saleBox;

  const DailySalesPage({super.key, required this.saleBox});

  List<Sale> getTodaySales(Box<Sale> saleBox) {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    return saleBox.values.where((sale) {
      return sale.date.isAfter(startOfDay);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Sale> todaySales = getTodaySales(saleBox);

    return Scaffold(
      appBar: AppBar(title: const Text('Today\'s Sales')),
      body: todaySales.isEmpty
          ? const Center(child: Text('No sales today'))
          : ListView.builder(
              itemCount: todaySales.length,
              itemBuilder: (context, index) {
                final sale = todaySales[index];
                return ListTile(
                  title: Text(sale.productName),
                  subtitle: Text('Quantity: ${sale.quantity} - ₱${sale.price * sale.quantity}'),
                );
              },
            ),
    );
  }
}
