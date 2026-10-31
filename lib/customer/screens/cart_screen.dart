import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/bloc/product_event.dart';
import 'package:y3s1_final/bloc/product_state.dart';

import 'package:y3s1_final/customer/screens/check_out_screen.dart';
import 'package:y3s1_final/models/cart_model.dart';
import 'package:y3s1_final/services/app_preferences.dart';

// =====================================================
// TRANSLATION HELPER
// =====================================================

String _tr(String english, String khmer) {
  return AppPreferences.instance.translate(english, khmer);
}

// =====================================================
// CART SCREEN
// =====================================================

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProductCart();
  }
}

// =====================================================
// PRODUCT CART
// =====================================================

class ProductCart extends StatelessWidget {
  final bool check;

  const ProductCart({
    super.key,
    this.check = false,
  });

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
          appBar: AppBar(
            automaticallyImplyLeading: check,
            backgroundColor: backgroundColor,
            foregroundColor: colors.onSurface,
            elevation: 0,
            centerTitle: true,
            title: Text(
              check
                  ? _tr('Your Cart', 'កន្ត្រករបស់អ្នក')
                  : _tr('Shopping Cart', 'កន្ត្រកទំនិញ'),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
                fontSize: 20,
              ),
            ),
          ),

          // CART CONTENT
          body: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state.cartModel.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _tr(
                            'Your cart is empty',
                            'កន្ត្រកទំនិញរបស់អ្នកនៅទទេ',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _tr(
                            'Add products to start shopping.',
                            'បន្ថែមផលិតផលដើម្បីចាប់ផ្តើមទិញទំនិញ។',
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

              // CART WITH PRODUCTS
              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        12,
                      ),
                      itemCount: state.cartModel.length,
                      separatorBuilder: (_, __) {
                        return const SizedBox(height: 12);
                      },
                      itemBuilder: (context, index) {
                        return _CartItem(
                          item: state.cartModel[index],
                        );
                      },
                    ),
                  ),

                  // TOTAL AND CHECKOUT
                  SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        16,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border(
                          top: BorderSide(
                            color: colors.outlineVariant,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _tr('Total', 'សរុប'),
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '\$${state.subtotal().toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isDark
                                      ? colors.primary
                                      : const Color(0xFF3730A3),
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const CheckoutScreenCustomer(),
                                  ),
                                );
                              },
                              child: Text(
                                _tr(
                                  'Continue to checkout',
                                  'បន្តទៅការទូទាត់ប្រាក់',
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// =====================================================
// CART PRODUCT ITEM
// =====================================================

class _CartItem extends StatelessWidget {
  final CartModel item;

  const _CartItem({
    required this.item,
  });

  // =====================================================
  // PRODUCT IMAGE
  // =====================================================

  Widget _buildProductImage(BuildContext context) {
    final image = item.product.image.trim();
    final colors = Theme.of(context).colorScheme;

    if (image.isEmpty) {
      return _imagePlaceholder(colors);
    }

    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return Image.network(
        image,
        width: 82,
        height: 82,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imagePlaceholder(colors);
        },
      );
    }

    return Image.asset(
      image,
      width: 82,
      height: 82,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _imagePlaceholder(colors);
      },
    );
  }

  Widget _imagePlaceholder(ColorScheme colors) {
    return Container(
      width: 82,
      height: 82,
      alignment: Alignment.center,
      color: colors.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colors.onSurfaceVariant,
        size: 30,
      ),
    );
  }

  // =====================================================
  // CART ITEM UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProductBloc>();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final unitPrice = item.product.price;

    return Card(
      color: colors.surface,
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colors.outlineVariant,
          width: isDark ? 1 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildProductImage(context),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRODUCT NAME
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 7),

                  // PRODUCT PRICE
                  Text(
                    '\$${unitPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isDark
                          ? colors.primary
                          : const Color(0xFF3730A3),
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // QUANTITY CONTROLS
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
                          visualDensity: VisualDensity.compact,
                          onPressed: item.quantity > 1
                              ? () {
                                  bloc.add(
                                    UpdateQuantityEvent(
                                      cartModel: item,
                                      quantity: item.quantity - 1,
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(
                            Icons.remove_circle_outline,
                          ),
                          color: colors.onSurface,
                        ),

                        Text(
                          '${item.quantity}',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),

                        IconButton(
                          tooltip: _tr(
                            'Increase quantity',
                            'បន្ថែមចំនួន',
                          ),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            bloc.add(
                              UpdateQuantityEvent(
                                cartModel: item,
                                quantity: item.quantity + 1,
                              ),
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
            ),

            // REMOVE PRODUCT
            IconButton(
              tooltip: _tr(
                'Remove item',
                'លុបផលិតផល',
              ),
              onPressed: () {
                bloc.add(
                  RemoveCartEvent(
                    removeCart: item,
                    code: item.product.code,
                  ),
                );
              },
              icon: Icon(
                Icons.delete_outline,
                color: colors.error,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}