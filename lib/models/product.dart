import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double price;

  @HiveField(2)
  int stock;

  Product({required this.name, required this.price, required this.stock});
}
  