import 'package:y3s1_final/models/cart_model.dart';
import 'package:y3s1_final/models/product_model.dart';

sealed class ProductEvent {}

final class LoadProductsEvent extends ProductEvent {}

final class AddCartEvent extends ProductEvent {
  AddCartEvent({
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
  });

  final ProductModel product;
  final String size;
  final String color;
  final int quantity;
}

final class SelectCategory extends ProductEvent {
  final String category;

  SelectCategory(this.category);
}

final class RemoveCartEvent extends ProductEvent {
  RemoveCartEvent({required this.removeCart, required this.code});

  final CartModel removeCart;
  final int code;
}

final class UpdateQuantityEvent extends ProductEvent {
  UpdateQuantityEvent({required this.cartModel, required this.quantity});

  final CartModel cartModel;
  final int quantity;
}

final class IncrementEvent extends ProductEvent {}

final class DescrementEvent extends ProductEvent {}

final class ResetQuantityEvent extends ProductEvent {}

final class ClearCartEvent extends ProductEvent {}
