import 'package:flutter/material.dart';

import 'package:y3s1_final/services/commerce_api.dart';
import 'package:y3s1_final/services/app_preferences.dart';
import 'package:y3s1_final/models/product_model.dart';
import 'package:y3s1_final/customer/screens/detail_product.dart';

// =====================================================
// TRANSLATION HELPERS
// =====================================================

String _tr(String english, String khmer) {
  return AppPreferences.instance.translate(english, khmer);
}

String _translateCategory(String category) {
  switch (category.toLowerCase().trim()) {
    case 'all':
      return _tr('All', 'ទាំងអស់');

    case 'phones':
      return _tr('Phones', 'ទូរស័ព្ទ');

    case 'laptops':
      return _tr('Laptops', 'កុំព្យូទ័រយួរដៃ');

    case 'tablets':
      return _tr('Tablets', 'ថេប្លេត');

    case 'audio':
      return _tr('Audio', 'ឧបករណ៍សំឡេង');

    case 'watches':
      return _tr('Watches', 'នាឡិកា');

    case 'cameras':
      return _tr('Cameras', 'កាមេរ៉ា');

    case 'gaming':
      return _tr('Gaming', 'ហ្គេម');

    case 'accessories':
      return _tr('Accessories', 'គ្រឿងបន្ថែម');

    case 'other':
      return _tr('Other', 'ផ្សេងៗ');

    default:
      return category;
  }
}

// =====================================================
// CATEGORY PRODUCTS SCREEN
// =====================================================

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends State<CategoryProductsScreen> {
  bool _loading = true;

  String? _error;

  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // =====================================================
  // CATEGORY NAME FROM LARAVEL
  // =====================================================

  String _categoryName(Map<String, dynamic> product) {
    final category = product['category'];

    if (category is Map) {
      final name =
          category['name']?.toString().trim() ?? '';

      if (name.isNotEmpty) {
        return name;
      }
    }

    if (category is String &&
        category.trim().isNotEmpty) {
      return category.trim();
    }

    return product['category_name']
            ?.toString()
            .trim() ??
        '';
  }

  // =====================================================
  // LOAD PRODUCTS FROM LARAVEL
  // =====================================================

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = CommerceApi.instance;

      // Keep the existing Laravel API requests.
      final results = await Future.wait<dynamic>([
        api.products(),
        api.categories(),
      ]);

      final products =
          results[0] as List<Map<String, dynamic>>;

      final categories =
          results[1] as List<Map<String, dynamic>>;

      // Use original category name for filtering.
      final selectedName =
          widget.categoryName.trim().toLowerCase();

      int? selectedCategoryId;

      for (final category in categories) {
        final name =
            category['name']
                    ?.toString()
                    .trim()
                    .toLowerCase() ??
                '';

        if (name == selectedName) {
          selectedCategoryId = int.tryParse(
            category['id']?.toString() ?? '',
          );

          break;
        }
      }

      final filtered = products.where((product) {
        final productCategoryName =
            _categoryName(product).toLowerCase();

        if (productCategoryName == selectedName) {
          return true;
        }

        final productCategoryId = int.tryParse(
          product['category_id']?.toString() ?? '',
        );

        if (selectedCategoryId != null &&
            productCategoryId == selectedCategoryId) {
          return true;
        }

        final categoryObject = product['category'];

        if (categoryObject is Map &&
            selectedCategoryId != null) {
          final nestedCategoryId = int.tryParse(
            categoryObject['id']?.toString() ?? '',
          );

          if (nestedCategoryId == selectedCategoryId) {
            return true;
          }
        }

        return false;
      }).toList();

      if (!mounted) return;

      setState(() {
        _products = filtered;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  // =====================================================
  // OPEN EXISTING PRODUCT DETAILS SCREEN
  // =====================================================

  void _openProductDetails(
    Map<String, dynamic> productData,
  ) {
    try {
      // Preserve the existing Laravel-to-Flutter model.
      final ProductModel product =
          ProductModel.fromLaravel(productData);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: product,
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_tr(
              'Unable to open product',
              'មិនអាចបើកផលិតផលបាន',
            )}: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =====================================================
  // PRODUCT IMAGE URL
  // =====================================================

  String _productImageUrl(
    Map<String, dynamic> product,
  ) {
    final value =
        (product['image_url'] ??
                product['image'] ??
                product['image_path'])
            ?.toString()
            .trim() ??
        '';

    if (value.isEmpty ||
        value.toLowerCase() == 'null') {
      return '';
    }

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    final path = value.replaceFirst(
      RegExp(r'^/+'),
      '',
    );

    if (path.startsWith('storage/')) {
      return 'http://10.0.2.2:8000/$path';
    }

    return 'http://10.0.2.2:8000/storage/$path';
  }

  // =====================================================
  // PRODUCT IMAGE
  // =====================================================

  Widget _buildProductImage(
    Map<String, dynamic> product,
  ) {
    final colors = Theme.of(context).colorScheme;

    final imageUrl = _productImageUrl(product);

    if (imageUrl.isEmpty) {
      return Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 36,
          color: colors.primary,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 36,
              color: colors.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // PRODUCT CARD
  // =====================================================

  Widget _buildProductCard(
    Map<String, dynamic> product,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final name =
        product['name']?.toString() ??
        _tr('Product', 'ផលិតផល');

    final price = double.tryParse(
          product['price']?.toString() ?? '',
        ) ??
        0;

    final description =
        product['description']?.toString() ?? '';

    final stock = int.tryParse(
          product['stock']?.toString() ?? '',
        ) ??
        0;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation:
          theme.brightness == Brightness.dark ? 0 : 2,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,

      // Tapping the card opens Product Details.
      child: InkWell(
        onTap: () => _openProductDetails(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: _buildProductImage(product),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // PRODUCT NAME
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // PRODUCT DESCRIPTION
                    if (description.isNotEmpty) ...[
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],

                    // PRODUCT PRICE
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // PRODUCT STOCK
                    Text(
                      stock > 0
                          ? _tr(
                              '$stock in stock',
                              'មានក្នុងស្តុក $stock',
                            )
                          : _tr(
                              'Out of stock',
                              'អស់ពីស្តុក',
                            ),
                      style: TextStyle(
                        fontSize: 12,
                        color: stock > 0
                            ? Colors.green
                            : colors.error,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // EMPTY CATEGORY
  // =====================================================

  Widget _buildEmptyState() {
    final colors = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 150),

          Icon(
            Icons.inventory_2_outlined,
            size: 70,
            color: colors.onSurfaceVariant,
          ),

          const SizedBox(height: 16),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                _tr(
                  'No products available in ${widget.categoryName}',
                  'មិនមានផលិតផលក្នុងប្រភេទ '
                      '${_translateCategory(widget.categoryName)} ទេ',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              _tr(
                'Pull down to refresh',
                'អូសចុះក្រោមដើម្បីផ្ទុកឡើងវិញ',
              ),
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState() {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 16),

            Text(
              '${_tr(
                'Unable to load products',
                'មិនអាចផ្ទុកផលិតផលបាន',
              )}:\n$_error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: Text(
                _tr(
                  'Try Again',
                  'ព្យាយាមម្តងទៀត',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // MAIN SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences.instance,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final isDark =
            theme.brightness == Brightness.dark;

        final backgroundColor = isDark
            ? theme.scaffoldBackgroundColor
            : const Color(0xFFFFF7F7);

        return Scaffold(
          backgroundColor: backgroundColor,

          appBar: AppBar(
            backgroundColor: backgroundColor,
            foregroundColor: colors.onSurface,
            centerTitle: true,
            title: Text(
              _translateCategory(
                widget.categoryName,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _error != null
                  ? _buildErrorState()
                  : _products.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadProducts,
                          child: ListView.builder(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              return _buildProductCard(
                                _products[index],
                              );
                            },
                          ),
                        ),
        );
      },
    );
  }
}