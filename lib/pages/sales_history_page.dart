import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sale.dart';
import 'package:intl/intl.dart';
import 'daily_sales_page.dart';

class SalesHistoryPage extends StatelessWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<Sale> saleBox = Hive.box<Sale>('sales');

    // ✅ Calculate total sales
    double totalSales = saleBox.values.fold(
      0,
      (sum, sale) => sum + (sale.price * sale.quantity),
    );

    // ✅ Daily sales
    double dailySales = saleBox.values
        .where((sale) =>
            DateFormat('yyyy-MM-dd').format(sale.date) ==
            DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .fold(0, (sum, sale) => sum + (sale.price * sale.quantity));

    // ✅ Weekly sales
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    double weeklySales = saleBox.values
        .where((sale) =>
            sale.date.isAfter(startOfWeek) &&
            sale.date.isBefore(startOfWeek.add(Duration(days: 7))))
        .fold(0, (sum, sale) => sum + (sale.price * sale.quantity));

    // ✅ Monthly sales
    double monthlySales = saleBox.values
        .where((sale) =>
            sale.date.year == now.year && sale.date.month == now.month)
        .fold(0, (sum, sale) => sum + (sale.price * sale.quantity));

    return Scaffold(
      appBar: AppBar(title: const Text('Sales History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Sales: ₱${totalSales.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Today: ₱${dailySales.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'This Week: ₱${weeklySales.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'This Month: ₱${monthlySales.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DailySalesPage(
                              saleBox: Hive.box<Sale>('sales'))),
                    );
                  },
                  child: const Text('View Today\'s Sales'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: saleBox.listenable(),
              builder: (context, Box<Sale> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text('No sales yet.'));
                }
                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final sale = box.getAt(index);
                    return ListTile(
                      title: Text('${sale!.productName} - ₱${sale.price}'),
                      subtitle: Text(
                        sale.date != null
                            ? 'Date: ${DateFormat('yyyy-MM-dd – HH:mm').format(sale.date)}'
                            : 'Date: No Date',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteSale(context, index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSale(BuildContext context, int index) {
    final Box<Sale> saleBox = Hive.box<Sale>('sales');
    saleBox.deleteAt(index);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sale deleted')),
    );
  }
}