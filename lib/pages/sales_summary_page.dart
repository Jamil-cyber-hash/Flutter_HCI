import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sale.dart';
import 'package:intl/intl.dart';

class SalesSummaryPage extends StatefulWidget {
  const SalesSummaryPage({super.key});

  @override
  _SalesSummaryPageState createState() => _SalesSummaryPageState();
}

class _SalesSummaryPageState extends State<SalesSummaryPage> {
  DateTime selectedDate = DateTime.now();
  double totalSales = 0;
  String selectedFilter = 'Daily'; // Default to Daily

  @override
  void initState() {
    super.initState();
    calculateSalesForDate(selectedDate);
  }

  void calculateSalesForDate(DateTime date) {
    final saleBox = Hive.box<Sale>('sales');
    final dateFormat = DateFormat('yyyy-MM-dd');
    final monthFormat = DateFormat('yyyy-MM');
    final yearFormat = DateFormat('yyyy');

    setState(() {
      totalSales = saleBox.values.where((sale) {
        if (selectedFilter == 'Daily') {
          return dateFormat.format(sale.date) == dateFormat.format(date);
        } else if (selectedFilter == 'Monthly') {
          return monthFormat.format(sale.date) == monthFormat.format(date);
        } else if (selectedFilter == 'Yearly') {
          return yearFormat.format(sale.date) == yearFormat.format(date);
        }
        return false;
      }).fold(0, (sum, sale) => sum + (sale.price * sale.quantity));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select Daily, Monthly, Yearly
            DropdownButton<String>(
              value: selectedFilter,
              items: ['Daily', 'Monthly', 'Yearly'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedFilter = newValue;
                    calculateSalesForDate(selectedDate);
                  });
                }
              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedFilter == 'Daily'
                        ? DateFormat('yyyy-MM-dd').format(selectedDate)
                        : selectedFilter == 'Monthly'
                            ? DateFormat('yyyy-MM').format(selectedDate)
                            : DateFormat('yyyy').format(selectedDate),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        calculateSalesForDate(selectedDate);
                      });
                    }
                  },
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Display total sales
            Text(
              'Total Sales: ₱${totalSales.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
