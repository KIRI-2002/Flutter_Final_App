import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/bloc/product_event.dart';
import 'package:y3s1_final/bloc/product_state.dart';

import 'package:y3s1_final/customer/screens/cart_screen.dart';
import 'package:y3s1_final/data/data_store.dart';
import 'package:y3s1_final/models/product_model.dart';
import 'package:y3s1_final/services/app_preferences.dart';

// =====================================================
// TRANSLATION HELPER
// =====================================================

String _tr(String english, String khmer) {
  return AppPreferences.instance.translate(english, khmer);
}

// =====================================================
// PRODUCT DETAILS SCREEN
// =====================================================

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color _lightBackground = Color(0xFFFFF5F6);

  @override
  void initState() {
    super.initState();

    context.read<ProductBloc>().add(
      ResetQuantityEvent(),
    );
  }

  // =====================================================
  // CATEGORY TRANSLATION
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

      default:
        return category;
    }
  }

  // =====================================================
  // ADD TO CART
  // =====================================================

  bool addToCart() {
    final bloc = context.read<ProductBloc>();
    final quantity = bloc.state.quantity;

    if (quantity <= 0) {
      _showMessage(
        _tr(
          'Please select a valid quantity',
          'សូមជ្រើសរើសចំនួនឱ្យបានត្រឹមត្រូវ',
        ),
      );

      return false;
    }

    bloc.add(
      AddCartEvent(
        product: widget.product,
        color: '',
        quantity: quantity,
        size: '',
      ),
    );

    bloc.add(ResetQuantityEvent());

    _showMessage(
      _tr(
        '${widget.product.name} added to cart',
        'បានបន្ថែម ${widget.product.name} ទៅកន្ត្រក',
      ),
    );

    return true;
  }

  // =====================================================
  // BUY NOW
  // =====================================================

  void _buyNow() {
    if (!addToCart()) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProductCart(
          check: true,
        ),
      ),
    );
  }

  // =====================================================
  // OPEN CART
  // =====================================================

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProductCart(
          check: true,
        ),
      ),
    );
  }

  // =====================================================
  // SNACKBAR MESSAGE
  // =====================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
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
        final dark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: dark
              ? theme.scaffoldBackgroundColor
              : _lightBackground,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductImage(),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _buildCategoryAndRating(),

                              const SizedBox(height: 14),

                              _buildProductNameAndQuantity(),

                              const SizedBox(height: 18),

                              _buildPrice(),

                              const SizedBox(height: 26),

                              _buildDescription(),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildBottomButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // TOP BAR
  // =====================================================

  Widget _buildTopBar() {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: _tr('Back', 'ត្រឡប់ក្រោយ'),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: colors.onSurface,
            ),
          ),

          Expanded(
            child: Text(
              _tr(
                'Product Detail',
                'ព័ត៌មានលម្អិតផលិតផល',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // FAVORITES
          ValueListenableBuilder<Set<int>>(
            valueListenable: favoriteCodes,
            builder: (context, favorites, _) {
              final isFavorite = favorites.contains(
                widget.product.code,
              );

              return IconButton(
                tooltip: isFavorite
                    ? _tr(
                        'Remove from favorites',
                        'ដកចេញពីចំណូលចិត្ត',
                      )
                    : _tr(
                        'Add to favorites',
                        'បន្ថែមទៅចំណូលចិត្ត',
                      ),
                onPressed: () {
                  toggleFavorite(widget.product.code);
                },
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite
                      ? Colors.redAccent
                      : colors.onSurface,
                ),
              );
            },
          ),

          // CART BUTTON
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: _tr(
                  'Shopping Cart',
                  'កន្ត្រកទំនិញ',
                ),
                onPressed: _openCart,
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: colors.onSurface,
                ),
              ),

              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  final count = state.cartModel.length;

                  if (count == 0) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    right: 1,
                    top: 2,
                    child: Container(
                      height: 20,
                      width: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: colors.onError,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PRODUCT IMAGE
  // =====================================================

  Widget _buildProductImage() {
    final image = widget.product.image.trim();

    Widget imageWidget;

    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      imageWidget = Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imagePlaceholder();
        },
      );
    } else if (image.isNotEmpty) {
      imageWidget = Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imagePlaceholder();
        },
      );
    } else {
      imageWidget = _imagePlaceholder();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 50,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }

  // =====================================================
  // CATEGORY AND RATING
  // =====================================================

  Widget _buildCategoryAndRating() {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _translateCategory(widget.product.category),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 18,
                color: Colors.amber,
              ),

              const SizedBox(width: 4),

              Text(
                widget.product.rate,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // PRODUCT NAME AND QUANTITY
  // =====================================================

  Widget _buildProductNameAndQuantity() {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Text(
                  _tr('Quantity', 'ចំនួន'),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const Spacer(),

                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: colors.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: _tr(
                          'Decrease quantity',
                          'បន្ថយចំនួន',
                        ),
                        onPressed: state.quantity > 1
                            ? () {
                                context.read<ProductBloc>().add(
                                      DescrementEvent(),
                                    );
                              }
                            : null,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                        ),
                        color: colors.onSurface,
                      ),

                      SizedBox(
                        width: 32,
                        child: Text(
                          state.quantity.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      IconButton(
                        tooltip: _tr(
                          'Increase quantity',
                          'បន្ថែមចំនួន',
                        ),
                        onPressed: () {
                          context.read<ProductBloc>().add(
                                IncrementEvent(),
                              );
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                        ),
                        color: colors.onSurface,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // PRODUCT PRICE
  // =====================================================

  Widget _buildPrice() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final priceColor = dark
        ? colors.primary
        : const Color(0xFF3730A3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '\$${widget.product.price.toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: priceColor,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Text(
            '${widget.product.view}+ ${_tr('Sold', 'បានលក់')}',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PRODUCT DESCRIPTION
  // =====================================================

  Widget _buildDescription() {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tr(
            'Description',
            'ការពិពណ៌នា',
          ),
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          widget.product.description,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 14,
            height: 1.7,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BOTTOM BUTTONS
  // =====================================================

  Widget _buildBottomButtons() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: dark
            ? colors.surface
            : _lightBackground,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: addToCart,
                style: OutlinedButton.styleFrom(
                  backgroundColor: colors.surface,
                  foregroundColor: colors.onSurface,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  side: BorderSide(
                    color: colors.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  _tr(
                    'Add Cart',
                    'បន្ថែមទៅកន្ត្រក',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton(
                onPressed: _buyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _tr(
                    'Buy Now',
                    'ទិញឥឡូវនេះ',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}