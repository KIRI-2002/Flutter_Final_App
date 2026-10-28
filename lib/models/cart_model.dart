import 'package:y3s1_final/models/product_model.dart';

class CartModel {
  ProductModel product;
  String size;
  String color;
  int quantity;
  CartModel({
    required this.product,
    required this.color,
    required this.quantity,
    required this.size,
  });
  CartModel copyCart({
    ProductModel? product,
    String? size,
    String? color,
    int? quantity,
  }) {
    return CartModel(
      product: product ?? this.product,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
    );
  }
}
