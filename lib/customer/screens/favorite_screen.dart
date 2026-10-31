import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/bloc/product_state.dart';
import 'package:y3s1_final/customer/screens/detail_product.dart';
import 'package:y3s1_final/data/data_store.dart';
import 'package:y3s1_final/services/app_preferences.dart';

// =====================================================
// CUSTOMER FAVORITE SCREEN
// DARK MODE + ENGLISH / KHMER
// =====================================================

class FavoriteScreenCustomer extends StatefulWidget {
  const FavoriteScreenCustomer({super.key});

  @override
  State<FavoriteScreenCustomer> createState() =>
      _FavoriteScreenCustomerState();
}

class _FavoriteScreenCustomerState extends State<FavoriteScreenCustomer> {
  // =====================================================
  // TRANSLATION HELPER
  // =====================================================

  String _tr(String english, String khmer) {
    return AppPreferences.instance.translate(english, khmer);
  }

  // =====================================================
  // TRANSLATE PRODUCT CATEGORY
  // =====================================================

  String _translateCategory(String category) {
    switch (category.toLowerCase().trim()) {
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
  // PRODUCT IMAGE
  // =====================================================

  Widget _buildProductImage(
    BuildContext context,
    String image,
  ) {
    final colors = Theme.of(context).colorScheme;
    final imagePath = image.trim();

    Widget placeholder() {
      return Container(
        width: 90,
        height: 90,
        alignment: Alignment.center,
        color: colors.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colors.onSurfaceVariant,
          size: 32,
        ),
      );
    }

    if (imagePath.isEmpty) {
      return placeholder();
    }

    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return placeholder();
        },
      );
    }

    return Image.asset(
      imagePath,
      width: 90,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return placeholder();
      },
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
        final isDark = theme.brightness == Brightness.dark;

        final backgroundColor = isDark
            ? theme.scaffoldBackgroundColor
            : const Color(0xFFFFF7F7);

        return Scaffold(
          backgroundColor: backgroundColor,

          // =====================================================
          // APP BAR
          // =====================================================

          appBar: AppBar(
            backgroundColor: backgroundColor,
            foregroundColor: colors.onSurface,
            elevation: 0,
            centerTitle: true,
            title: Text(
              _tr(
                'Wishlist',
                'បញ្ជីចំណូលចិត្ត',
              ),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // =====================================================
          // FAVORITE PRODUCTS
          // =====================================================

          body: ValueListenableBuilder<Set<int>>(
            valueListenable: favoriteCodes,
            builder: (context, favorites, _) {
              return BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  // Preserve products loaded through BLoC/Laravel.
                  final items = state.dataStore.where((product) {
                    return favorites.contains(product.code);
                  }).toList();

                  // =====================================================
                  // EMPTY WISHLIST
                  // =====================================================

                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite_border_rounded,
                                size: 58,
                                color: colors.onPrimaryContainer,
                              ),
                            ),

                            const SizedBox(height: 22),

                            Text(
                              _tr(
                                'No favorites yet',
                                'មិនទាន់មានផលិតផលដែលចូលចិត្តទេ',
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              _tr(
                                'Products you like will appear here.',
                                'ផលិតផលដែលអ្នកចូលចិត្តនឹងបង្ហាញនៅទីនេះ។',
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // =====================================================
                  // WISHLIST WITH PRODUCTS
                  // =====================================================

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      110,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) {
                      return const SizedBox(height: 14);
                    },
                    itemBuilder: (context, index) {
                      final product = items[index];

                      return Card(
                        color: colors.surface,
                        elevation: isDark ? 0 : 2,
                        shadowColor: Colors.black.withValues(
                          alpha: 0.08,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: colors.outlineVariant,
                            width: isDark ? 1 : 0.5,
                          ),
                        ),

                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),

                          // OPEN PRODUCT DETAILS
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(
                                  product: product,
                                ),
                              ),
                            );
                          },

                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // PRODUCT IMAGE
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: _buildProductImage(
                                    context,
                                    product.image,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                // PRODUCT INFORMATION
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // PRODUCT NAME
                                      Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colors.onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          height: 1.3,
                                        ),
                                      ),

                                      const SizedBox(height: 7),

                                      // PRODUCT CATEGORY
                                      Text(
                                        _translateCategory(
                                          product.category,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colors.onSurfaceVariant,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // PRODUCT PRICE
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isDark
                                              ? colors.primary
                                              : const Color(0xFF3730A3),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 6),

                                // REMOVE FROM WISHLIST
                                IconButton(
                                  tooltip: _tr(
                                    'Remove from wishlist',
                                    'ដកចេញពីបញ្ជីចំណូលចិត្ត',
                                  ),
                                  onPressed: () {
                                    toggleFavorite(product.code);
                                  },
                                  icon: Icon(
                                    Icons.favorite_rounded,
                                    color: colors.error,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}