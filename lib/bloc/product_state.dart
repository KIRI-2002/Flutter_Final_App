
import 'package:y3s1_final/data/data_store.dart';
import 'package:y3s1_final/models/cart_model.dart';
import 'package:y3s1_final/models/product_model.dart';

class ProductState {
  ProductState({
    List<ProductModel>? dataStore,
    List<CartModel>? cartModel,
    int? quantity,
    String? selectedCategory,
  }) : dataStore = dataStore ?? DataStore().products,
       cartModel = cartModel ?? const [],
       quantity = quantity ?? 1,
       selectedCategory = selectedCategory ?? "All";

  final List<ProductModel> dataStore;
  final List<CartModel> cartModel;
  final int quantity;
  final String selectedCategory;

  List<String> get categories {
    return [
      "All",
      ...dataStore.map((product) => product.category).toSet(),
    ];
  }

  List<ProductModel> get filteredProducts {
    if (selectedCategory == "All") return dataStore;
    const homeCategoryGroups = <String, Set<String>>{
      "Phones": {"Case", "Screen Protector", "Holder"},
      "Laptops": {"Cable", "Charger", "Power Bank", "Stand"},
      "Tablets": {"Case", "Screen Protector", "Stand", "Charger"},
      "Audio": {"Earbuds", "Audio", "Speaker", "Headphones"},
      "Watches": {"Smart Watch", "Wearable"},
      "Gaming": {"Headphones", "Speaker"},
      "Accessories": {
        "Case",
        "Screen Protector",
        "Charger",
        "Cable",
        "Power Bank",
        "Wireless Charger",
        "Stand",
        "Holder",
      },
    };
    final groupedCategories = homeCategoryGroups[selectedCategory];
    if (groupedCategories != null) {
      return dataStore
          .where((product) => groupedCategories.contains(product.category))
          .toList();
    }
    return dataStore.where((p) => p.category == selectedCategory).toList();
  }

  ProductState copyWith({
    List<ProductModel>? dataStore,
    List<CartModel>? cartModel,
    int? quantity,
    String? selectedCategory,
  }) {
    return ProductState(
      dataStore: dataStore ?? this.dataStore,
      cartModel: cartModel ?? this.cartModel,
      quantity: quantity ?? this.quantity,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  double getotal() {
    return cartModel.fold(
      0.0,
      (total, item) => total + (item.product.oldprice * item.quantity),
    );
  }

  double getDiscount() {
    return cartModel.fold(
      0.0,
      (total, item) =>
          total +
          ((item.product.oldprice * item.product.discount / 100) *
              item.quantity),
    );
  }

  double subtotal() {
    if (cartModel.isEmpty) {
      return 0;
    }
    return getotal() - getDiscount() + 1.0;
  }
}
