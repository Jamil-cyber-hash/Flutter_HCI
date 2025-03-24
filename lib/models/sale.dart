import 'package:hive/hive.dart';

part 'sale.g.dart';

@HiveType(typeId: 1)
class Sale extends HiveObject {
  @HiveField(0)
  final String productName;

  @HiveField(1)
  final double price;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final DateTime date;

  Sale({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.date,
  });

  num? get totalAmount => null;
}
