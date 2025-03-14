import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sale.dart';
import 'package:intl/intl.dart';

class SalesHistoryPage extends StatelessWidget {
  final Box<Sale> saleBox = Hive.box<Sale>('sales');

  @override
  Widget build(BuildContext context) {
    double totalSales = saleBox.values.fold(
      0,
      (sum, sale) => sum + (sale.price * sale.quantity),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Sales History')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Total Sales: ₱${totalSales.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: saleBox.listenable(),
              builder: (context, Box<Sale> box, _) {
                if (box.isEmpty) {
                  return Center(child: Text('No sales yet.'));
                }
                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final sale = box.getAt(index);
                    return ListTile(
                      title: Text('${sale!.productName} - ₱${sale.price}'),
                      subtitle: Text(
                        'Date: ${sale.date != null 
                          ? DateFormat('yyyy-MM-dd – HH:mm').format(sale.date) 
                          : 'No Date'}',
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
}
