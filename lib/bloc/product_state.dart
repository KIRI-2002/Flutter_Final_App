import 'package:y3s1_final/models/cart_model.dart';
import 'package:y3s1_final/models/product_model.dart';

class ProductState {
  ProductState({
    List<ProductModel>? dataStore,
    List<CartModel>? cartModel,
    int? quantity,
    String? selectedCategory,
    this.isLoading = false,
    this.error,
  }) : dataStore = dataStore ?? const [],
       cartModel = cartModel ?? const [],
       quantity = quantity ?? 1,
       selectedCategory = selectedCategory ?? 'All';

  final List<ProductModel> dataStore;
  final List<CartModel> cartModel;
  final int quantity;
  final String selectedCategory;
  final bool isLoading;
  final String? error;

  List<String> get categories {
    return ['All', ...dataStore.map((product) => product.category).toSet()];
  }

  List<ProductModel> get filteredProducts {
    if (selectedCategory == 'All') {
      return dataStore;
    }

    const homeCategoryGroups = <String, Set<String>>{
      'Phones': {'Phones', 'Case', 'Screen Protector', 'Holder'},
      'Laptops': {'Laptops', 'Cable', 'Charger', 'Power Bank', 'Stand'},
      'Tablets': {'Tablets', 'Case', 'Screen Protector', 'Stand', 'Charger'},
      'Audio': {'Audio', 'Earbuds', 'Speaker', 'Headphones'},
      'Watches': {'Watches', 'Smart Watch', 'Wearable'},
      'Gaming': {'Gaming', 'Headphones', 'Speaker'},
      'Accessories': {
        'Accessories',
        'Case',
        'Screen Protector',
        'Charger',
        'Cable',
        'Power Bank',
        'Wireless Charger',
        'Stand',
        'Holder',
      },
    };

    final groupedCategories = homeCategoryGroups[selectedCategory];

    if (groupedCategories != null) {
      return dataStore.where((product) {
        return groupedCategories.contains(product.category);
      }).toList();
    }

    return dataStore.where((product) {
      return product.category == selectedCategory;
    }).toList();
  }

  ProductState copyWith({
    List<ProductModel>? dataStore,
    List<CartModel>? cartModel,
    int? quantity,
    String? selectedCategory,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProductState(
      dataStore: dataStore ?? this.dataStore,
      cartModel: cartModel ?? this.cartModel,
      quantity: quantity ?? this.quantity,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
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
    return cartModel.fold<double>(0.0, (total, item) {
      return total + (item.product.price * item.quantity);
    });
  }
}
