import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double price;

  @HiveField(2)
  int stock;

  @HiveField(3)
  String category;

  Product({
    required this.name,
    required this.price,
    required this.stock,
    required this.category
  });
}
