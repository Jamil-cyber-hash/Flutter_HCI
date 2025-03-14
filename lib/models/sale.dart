import 'package:hive/hive.dart';

part 'sale.g.dart';

@HiveType(typeId: 1)
class Sale extends HiveObject {
  @HiveField(0)
  String productName;

  @HiveField(1)
  double price;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  DateTime date;

  Sale({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.date,
  });
}
