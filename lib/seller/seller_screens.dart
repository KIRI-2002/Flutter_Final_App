import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:y3s1_final/services/app_preferences.dart';
import 'package:y3s1_final/screens/appearance_language_screen.dart';
import 'package:y3s1_final/seller/seller_profile_settings.dart';
import 'package:y3s1_final/seller/seller_support_screen.dart';

import 'seller_data.dart';
import '../services/commerce_api.dart';
import 'seller_main.dart';

// =====================================================
// COMMON WIDGETS
// =====================================================

// Translates Seller interface labels using the saved app language.
String sellerTr(String english, String khmer) =>
    AppPreferences.instance.translate(english, khmer);

// Theme-aware shared Seller heading.
Widget heading(String title, String subtitle) => Builder(
  builder: (context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  },
);

// Shared card follows the global light/dark theme.
Widget card({
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(14),
}) => Builder(
  builder: (context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border:
            dark ? Border.all(color: theme.colorScheme.outlineVariant) : null,
        boxShadow:
            dark
                ? null
                : [
                  BoxShadow(
                    color: navy.withValues(alpha: .04),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
      ),
      child: child,
    );
  },
);

Widget tag(String text, Color bg) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      color: navy,
      fontWeight: FontWeight.w600,
    ),
  ),
);

String money(num value) => '\$${value.toStringAsFixed(2)}';

void info(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

// =====================================================
// SELLER DASHBOARD
// =====================================================
class DashboardScreen extends StatelessWidget {
  final SellerStore store;
  final ValueChanged<int> navigate;
  final VoidCallback add;

  const DashboardScreen({
    super.key,
    required this.store,
    required this.navigate,
    required this.add,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = colors.onSurface;
    final secondaryText = colors.onSurfaceVariant;
    final accentColor = isDark ? colors.primary : navy;

    final maxSales = store.dailySales.fold<double>(
      0,
      (max, day) => day.sales > max ? day.sales : max,
    );

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      children: [
        // =====================================================
        // SELLER HEADER
        // =====================================================
        Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primaryContainer,
              child: Icon(
                Icons.storefront_outlined,
                color: colors.onPrimaryContainer,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  Text(
                    sellerTr('Seller dashboard', 'ផ្ទាំងគ្រប់គ្រងអ្នកលក់'),
                    style: TextStyle(fontSize: 11, color: secondaryText),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () {
                info(
                  context,
                  sellerTr('No new notifications', 'មិនមានការជូនដំណឹងថ្មីទេ'),
                );
              },
              icon: Icon(Icons.notifications_none_rounded, color: primaryText),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // =====================================================
        // SALES CARD
        // =====================================================
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [navy, Color(0xFF403F9B)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sellerTr("Today's sales", 'ការលក់ថ្ងៃនេះ'),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),

                  tag(sellerTr('Laravel data', 'ទិន្នន័យ Laravel'), lavender),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                money(store.todaySales),
                style: const TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                '${sellerTr('Total sales', 'ការលក់សរុប')}: ${money(store.totalSales)}',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),

              const SizedBox(height: 18),

              // =====================================================
              // SEVEN-DAY SALES CHART
              // =====================================================
              SizedBox(
                height: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final day in store.dailySales)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height:
                                    maxSales == 0
                                        ? 4
                                        : 55 * day.sales / maxSales + 4,
                                decoration: BoxDecoration(
                                  color: lavender,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),

                              const SizedBox(height: 7),

                              Text(
                                day.day,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 13),

        // =====================================================
        // DASHBOARD STATISTICS
        // =====================================================
        Row(
          children: [
            for (final stat in [
              ('${store.newOrders}', sellerTr('New orders', 'ការបញ្ជាទិញថ្មី')),
              ('${store.toShipOrders}', sellerTr('Warehouse', 'ឃ្លាំង')),
              ('${store.lowStockProducts}', sellerTr('Low stock', 'ស្តុកតិច')),
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.$1,
                          style: TextStyle(
                            fontSize: 22,
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          stat.$2,
                          style: TextStyle(fontSize: 10, color: secondaryText),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),

        // =====================================================
        // QUICK ACTIONS
        // =====================================================
        Row(
          children: [
            _action(
              context,
              Icons.add,
              sellerTr('Add product', 'បន្ថែមផលិតផល'),
              add,
            ),

            _action(
              context,
              Icons.local_offer_outlined,
              sellerTr('Discounts', 'ការបញ្ចុះតម្លៃ'),
              () {
                info(
                  context,
                  sellerTr(
                    'Discounts coming soon',
                    'មុខងារបញ្ចុះតម្លៃនឹងមានឆាប់ៗនេះ',
                  ),
                );
              },
            ),

            _action(
              context,
              Icons.chat_bubble_outline,
              sellerTr('Messages', 'សារ'),
              () {
                info(
                  context,
                  sellerTr('Messages coming soon', 'មុខងារសារនឹងមានឆាប់ៗនេះ'),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 13),

        // =====================================================
        // RECENT ORDERS
        // =====================================================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sellerTr('Recent orders', 'ការបញ្ជាទិញថ្មីៗ'),
              style: TextStyle(fontWeight: FontWeight.bold, color: primaryText),
            ),

            TextButton(
              onPressed: () => navigate(2),
              child: Text(sellerTr('See all', 'មើលទាំងអស់')),
            ),
          ],
        ),

        if (store.orders.isEmpty)
          card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  sellerTr('No orders available', 'មិនមានការបញ្ជាទិញទេ'),
                  style: TextStyle(color: secondaryText),
                ),
              ),
            ),
          ),

        for (final order in store.orders.take(3))
          card(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: colors.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.id}',
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        '${sellerTr('Customer', 'អតិថិជន')}: ${order.customer}',
                        style: TextStyle(fontSize: 10, color: secondaryText),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      money(order.total),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),

                    tag(_translateDashboardStatus(order.status), lavender),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // =====================================================
  // TRANSLATE ORDER STATUS
  // =====================================================

  String _translateDashboardStatus(String status) {
    switch (status.toLowerCase()) {
      case 'new':
      case 'pending':
        return sellerTr('New', 'ថ្មី');

      case 'processing':
        return sellerTr('Processing', 'កំពុងដំណើរការ');

      case 'to ship':
      case 'packed':
        return sellerTr('Warehouse', 'ឃ្លាំង');

      case 'shipped':
        return sellerTr('Shipped', 'បានដឹកចេញ');

      case 'delivered':
        return sellerTr('Delivered', 'បានដឹកដល់');

      case 'completed':
        return sellerTr('Completed', 'បានបញ្ចប់');

      case 'cancelled':
        return sellerTr('Cancelled', 'បានលុបចោល');

      default:
        return status;
    }
  }

  // =====================================================
  // QUICK ACTION BUTTON
  // =====================================================

  Widget _action(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: colors.primary),

                const SizedBox(height: 12),

                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// SELLER PRODUCTS SCREEN
// Dark Mode + English / Khmer
// =====================================================

class ProductsScreen extends StatefulWidget {
  final SellerStore store;
  final VoidCallback refresh;
  final ValueChanged<SellerProduct> edit;

  const ProductsScreen({
    super.key,
    required this.store,
    required this.refresh,
    required this.edit,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String query = '';

  // =====================================================
  // TRANSLATE STOCK STATUS
  // =====================================================

  String _stockStatus(int stock) {
    if (stock == 0) {
      return sellerTr(
        'Out of stock',
        'អស់ស្តុក',
      );
    }

    if (stock <= 3) {
      return sellerTr(
        'Low stock',
        'ស្តុកតិច',
      );
    }

    return sellerTr(
      'Active',
      'កំពុងលក់',
    );
  }

  // =====================================================
  // STOCK STATUS COLOR
  // =====================================================

  Color _stockColor(int stock) {
    if (stock == 0) {
      return const Color(0xFFFFDED5);
    }

    if (stock <= 3) {
      return const Color(0xFFFFE7AF);
    }

    return const Color(0xFFD7F1E8);
  }

  // =====================================================
  // PRODUCT CARD
  // =====================================================

  Widget _buildProductCard(
    SellerProduct item,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = colors.onSurface;
    final secondaryText = colors.onSurfaceVariant;
    final accentColor = isDark ? colors.primary : const Color(0xFF514AC4);

    return card(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // =====================================================
          // PRODUCT IMAGE
          // =====================================================

          Container(
            width: 57,
            height: 57,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(13),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imageUrl != null &&
                    item.imageUrl!.trim().isNotEmpty
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        item.icon,
                        color: const Color(0xFF6770A1),
                      );
                    },
                  )
                : Icon(
                    item.icon,
                    color: const Color(0xFF6770A1),
                  ),
          ),

          const SizedBox(width: 12),

          // =====================================================
          // PRODUCT INFORMATION
          // =====================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PRODUCT NAME
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                // PRODUCT PRICE
                Text(
                  money(item.price),
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                // STOCK STATUS
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    tag(
                      _stockStatus(item.stock),
                      _stockColor(item.stock),
                    ),

                    Text(
                      sellerTr(
                        '${item.stock} in stock',
                        'នៅសល់ ${item.stock} ក្នុងស្តុក',
                      ),
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // =====================================================
          // EDIT PRODUCT BUTTON
          // =====================================================

          IconButton(
            tooltip: sellerTr(
              'Edit product',
              'កែប្រែផលិតផល',
            ),
            onPressed: () {
              hideKeyboard();

              // Preserve existing edit navigation.
              widget.edit(item);
            },
            icon: Icon(
              Icons.edit_outlined,
              color: colors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // MAIN SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Preserve the existing product search.
    final products = widget.store.products
        .where(
          (product) => product.name
              .toLowerCase()
              .contains(query.trim().toLowerCase()),
        )
        .toList();

    return ListView(
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(15, 34, 15, 15),
      children: [
        // =====================================================
        // HEADER
        // =====================================================

        heading(
          sellerTr(
            'My products',
            'ផលិតផលរបស់ខ្ញុំ',
          ),
          sellerTr(
            '${widget.store.products.length} listed in your store',
            'មានផលិតផល ${widget.store.products.length} ក្នុងហាងរបស់អ្នក',
          ),
        ),

        // =====================================================
        // SEARCH PRODUCTS
        // =====================================================

        TextField(
          onChanged: (value) {
            setState(() {
              query = value;
            });
          },
          onTapOutside: (_) => hideKeyboard(),
          onSubmitted: (_) => hideKeyboard(),
          textInputAction: TextInputAction.search,
          style: TextStyle(
            color: colors.onSurface,
          ),
          cursorColor: colors.primary,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: colors.onSurfaceVariant,
            ),
            suffixIcon: IconButton(
              tooltip: sellerTr(
                'Hide keyboard',
                'លាក់ក្តារចុច',
              ),
              onPressed: hideKeyboard,
              icon: Icon(
                Icons.keyboard_hide_outlined,
                color: colors.onSurfaceVariant,
              ),
            ),
            hintText: sellerTr(
              'Search your products',
              'ស្វែងរកផលិតផលរបស់អ្នក',
            ),
            hintStyle: TextStyle(
              color: colors.onSurfaceVariant,
            ),
            filled: true,
            fillColor: colors.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // =====================================================
        // EMPTY PRODUCTS
        // =====================================================

        if (products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 60,
              horizontal: 20,
            ),
            child: Column(
              children: [
                Icon(
                  query.trim().isEmpty
                      ? Icons.inventory_2_outlined
                      : Icons.search_off_outlined,
                  size: 64,
                  color: colors.onSurfaceVariant,
                ),

                const SizedBox(height: 16),

                Text(
                  query.trim().isEmpty
                      ? sellerTr(
                          'No products yet',
                          'មិនទាន់មានផលិតផលទេ',
                        )
                      : sellerTr(
                          'No matching products',
                          'រកមិនឃើញផលិតផលដែលត្រូវគ្នា',
                        ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  query.trim().isEmpty
                      ? sellerTr(
                          'Add a product to start selling.',
                          'បន្ថែមផលិតផលដើម្បីចាប់ផ្តើមលក់។',
                        )
                      : sellerTr(
                          'Try searching with another name.',
                          'សាកល្បងស្វែងរកដោយឈ្មោះផ្សេង។',
                        ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

        // =====================================================
        // PRODUCT LIST
        // =====================================================

        for (final item in products)
          _buildProductCard(item),
      ],
    );
  }
}

// =====================================================
// SELLER ORDERS SCREEN
// Dark Mode + English / Khmer
// =====================================================

class OrdersScreen extends StatefulWidget {
  final SellerStore store;
  final VoidCallback refresh;

  final Future<void> Function(SellerOrder, String) updateOrder;

  const OrdersScreen({
    super.key,
    required this.store,
    required this.refresh,
    required this.updateOrder,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Keep original status values for Laravel filtering.
  String status = 'New';

  String? updatingOrderId;

  // =====================================================
  // TRANSLATE ORDER STATUS
  // =====================================================

  String _translateStatus(String value) {
    switch (value.toLowerCase().trim()) {
      case 'new':
        return sellerTr(
          'New',
          'ថ្មី',
        );

      case 'to ship':
        return sellerTr(
          'Warehouse',
          'ឃ្លាំង',
        );

      case 'shipped':
        return sellerTr(
          'Shipped',
          'បានដឹកចេញ',
        );

      case 'processing':
        return sellerTr(
          'Processing',
          'កំពុងដំណើរការ',
        );

      case 'packed':
        return sellerTr(
          'Packed',
          'បានវេចខ្ចប់',
        );

      case 'delivered':
        return sellerTr(
          'Delivered',
          'បានដឹកដល់',
        );

      case 'completed':
        return sellerTr(
          'Completed',
          'បានបញ្ចប់',
        );

      case 'cancelled':
        return sellerTr(
          'Cancelled',
          'បានលុបចោល',
        );

      default:
        return value;
    }
  }

  // =====================================================
  // UPDATE ORDER STATUS
  // =====================================================

  Future<void> _changeStatus(
    SellerOrder order,
    String nextStatus,
  ) async {
    if (updatingOrderId != null) {
      return;
    }

    setState(() {
      updatingOrderId = order.id;
    });

    try {
      // Preserve existing Laravel order update.
      await widget.updateOrder(order, nextStatus);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${sellerTr(
              'Unable to update order',
              'មិនអាចកែប្រែការបញ្ជាទិញបាន',
            )}: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          updatingOrderId = null;
        });
      }
    }
  }

  // =====================================================
  // ORDER STATUS TAB
  // =====================================================

  Widget _buildStatusTab(
    String selectedStatus,
  ) {
    final colors = Theme.of(context).colorScheme;

    final isSelected = status == selectedStatus;

    final count = widget.store.orders
        .where(
          (order) => order.status == selectedStatus,
        )
        .length;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            status = selectedStatus;
          });
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '${_translateStatus(selectedStatus)} ($count)',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isSelected
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // ORDER CARD
  // =====================================================

  Widget _buildOrderCard(SellerOrder order) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = colors.onSurface;
    final secondaryText = colors.onSurfaceVariant;

    final isUpdating = updatingOrderId == order.id;

    return card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // ORDER ID AND TIME
          // =====================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.id}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                  fontSize: 14,
                ),
              ),

              const SizedBox(width: 8),

              Flexible(
                child: Text(
                  order.time,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 10,
                    color: secondaryText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // =====================================================
          // ORDER DETAILS
          // =====================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: colors.onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.details,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      order.customer,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 11,
                      ),
                    ),

                    if (order.city.isNotEmpty) ...[
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: secondaryText,
                          ),

                          const SizedBox(width: 3),

                          Expanded(
                            child: Text(
                              order.city,
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // =====================================================
          // MIXED SELLER ORDER WARNING
          // =====================================================

          if (!order.canUpdate && status == 'New')
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF493020)
                    : const Color(0xFFFFF0E4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.deepOrange,
                    size: 18,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      sellerTr(
                        'Mixed-seller order: confirmation is blocked until per-seller confirmation is supported.',
                        'ការបញ្ជាទិញនេះមានផលិតផលពីអ្នកលក់ច្រើន។ មិនអាចបញ្ជាក់បានទេ រហូតដល់ប្រព័ន្ធគាំទ្រការបញ្ជាក់តាមអ្នកលក់នីមួយៗ។',
                      ),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFFFD2B4)
                            : const Color(0xFF8A390A),
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 24),

          // =====================================================
          // ORDER TOTAL AND ACTION
          // =====================================================

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellerTr(
                        'Total',
                        'សរុប',
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryText,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      money(order.total),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              if (status == 'New')
                Flexible(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onPressed:
                        !order.canUpdate || updatingOrderId != null
                            ? null
                            : () => _changeStatus(
                                  order,
                                  'processing',
                                ),
                    child: isUpdating
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onPrimary,
                                ),
                              ),

                              const SizedBox(width: 7),

                              Flexible(
                                child: Text(
                                  sellerTr(
                                    'Confirming...',
                                    'កំពុងបញ្ជាក់...',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            sellerTr(
                              'Confirm Order',
                              'បញ្ជាក់ការបញ្ជាទិញ',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                )
              else
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status == 'To ship'
                          ? sellerTr(
                              'Warehouse fulfillment',
                              'កំពុងរៀបចំទំនិញក្នុងឃ្លាំង',
                            )
                          : sellerTr(
                              'Shipped / Delivered',
                              'បានដឹកចេញ / ដឹកដល់',
                            ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // MAIN SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Preserve the original status filtering.
    final orders = widget.store.orders
        .where(
          (order) => order.status == status,
        )
        .toList();

    return ListView(
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 15),
      children: [
        // =====================================================
        // HEADER
        // =====================================================

        heading(
          sellerTr(
            'Orders',
            'ការបញ្ជាទិញ',
          ),
          sellerTr(
            'Confirm orders and track warehouse fulfillment',
            'បញ្ជាក់ការបញ្ជាទិញ និងតាមដានការរៀបចំទំនិញក្នុងឃ្លាំង',
          ),
        ),

        // =====================================================
        // ORDER STATUS TABS
        // =====================================================

        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              _buildStatusTab('New'),
              _buildStatusTab('To ship'),
              _buildStatusTab('Shipped'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // =====================================================
        // EMPTY ORDERS
        // =====================================================

        if (orders.isEmpty)
          card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 35,
                horizontal: 12,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 46,
                    color: colors.onSurfaceVariant,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    sellerTr(
                      'No orders in this tab',
                      'មិនមានការបញ្ជាទិញក្នុងផ្ទាំងនេះទេ',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // =====================================================
        // ORDER LIST
        // =====================================================

        for (final order in orders)
          _buildOrderCard(order),
      ],
    );
  }
}
// =====================================================
// ADD / EDIT PRODUCT SCREEN
// Dark Mode + English / Khmer
// =====================================================

class AddProductScreen extends StatefulWidget {
  final SellerStore store;
  final SellerProduct? existing;
  final VoidCallback done;
  final VoidCallback back;

  const AddProductScreen({
    super.key,
    required this.store,
    required this.done,
    required this.back,
    this.existing,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController name;
  late final TextEditingController price;
  late final TextEditingController stock;
  late final TextEditingController description;

  String category = 'Phones';
  bool saving = false;
  XFile? selectedImage;

  List<Map<String, dynamic>> remoteCategories = [];

  // =====================================================
  // INITIALIZE FORM
  // =====================================================

  @override
  void initState() {
    super.initState();

    final product = widget.existing;

    name = TextEditingController(
      text: product?.name ?? '',
    );

    price = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );

    stock = TextEditingController(
      text: product == null ? '' : product.stock.toString(),
    );

    description = TextEditingController(
      text: product?.description ?? '',
    );

    category = product?.category ?? 'Phones';

    _loadCategories();
  }

  @override
  void dispose() {
    name.dispose();
    price.dispose();
    stock.dispose();
    description.dispose();
    super.dispose();
  }

  // =====================================================
  // CATEGORY TRANSLATION
  // =====================================================

  String _translateCategory(String value) {
    switch (value.toLowerCase().trim()) {
      case 'phones':
        return sellerTr('Phones', 'ទូរស័ព្ទ');

      case 'audio':
        return sellerTr('Audio', 'ឧបករណ៍សំឡេង');

      case 'laptops':
        return sellerTr('Laptops', 'កុំព្យូទ័រយួរដៃ');

      case 'tablets':
        return sellerTr('Tablets', 'ថេប្លេត');

      case 'watches':
        return sellerTr('Watches', 'នាឡិកា');

      case 'cameras':
        return sellerTr('Cameras', 'កាមេរ៉ា');

      case 'gaming':
        return sellerTr('Gaming', 'ឧបករណ៍ហ្គេម');

      case 'accessories':
        return sellerTr('Accessories', 'គ្រឿងបន្លាស់');

      case 'other':
        return sellerTr('Other', 'ផ្សេងៗ');

      default:
        // Custom category names from Laravel stay unchanged.
        return value;
    }
  }

  // =====================================================
  // LOAD CATEGORIES FROM LARAVEL
  // =====================================================

  Future<void> _loadCategories() async {
    try {
      final categories = await CommerceApi.instance.categories();

      if (!mounted) return;

      setState(() {
        remoteCategories = categories;
      });
    } catch (_) {
      // Keep the form usable when categories cannot load.
    }
  }

  // =====================================================
  // PICK PRODUCT IMAGE
  // =====================================================

  Future<void> pickProductImage() async {
    if (saving) return;

    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (image == null || !mounted) return;

      setState(() {
        selectedImage = image;
      });
    } catch (error) {
      if (!mounted) return;

      info(
        context,
        '${sellerTr(
          'Could not select image',
          'មិនអាចជ្រើសរើសរូបភាពបាន',
        )}: $error',
      );
    }
  }

  // =====================================================
  // SAVE PRODUCT TO LARAVEL
  // =====================================================

  Future<void> save(bool draft) async {
    hideKeyboard();

    if (saving || !formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      // Match the original category name from Laravel.
      final matches = remoteCategories.where(
        (item) => item['name']?.toString() == category,
      );

      final categoryId = matches.isEmpty
          ? null
          : matches.first['id'];

      // Keep Laravel field names and values unchanged.
      final payload = <String, dynamic>{
        'name': name.text.trim(),
        'description': description.text.trim(),
        'price': double.parse(price.text.trim()),
        'stock': int.parse(stock.text.trim()),
        'status': draft ? 'inactive' : 'active',
      };

      if (categoryId != null) {
        payload['category_id'] = categoryId;
      } else {
        payload['category'] = category;
      }

      // Preserve existing image upload functionality.
      if (selectedImage != null) {
        await CommerceApi.instance.saveProductWithImage(
          payload,
          imagePath: selectedImage!.path,
          id: widget.existing?.id,
        );
      } else {
        await CommerceApi.instance.saveProduct(
          payload,
          id: widget.existing?.id,
        );
      }

      if (!mounted) return;

      info(
        context,
        draft
            ? sellerTr(
                'Draft saved to Laravel',
                'បានរក្សាទុកសេចក្តីព្រាងទៅ Laravel',
              )
            : sellerTr(
                'Product saved to Laravel',
                'បានរក្សាទុកផលិតផលទៅ Laravel',
              ),
      );

      widget.done();
    } catch (error) {
      if (!mounted) return;

      info(
        context,
        '${sellerTr(
          'Could not save product',
          'មិនអាចរក្សាទុកផលិតផលបាន',
        )}: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  // =====================================================
  // PRODUCT IMAGE SELECTOR
  // =====================================================

  Widget _buildImageSelector() {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: saving ? null : pickProductImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.primary,
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: selectedImage != null
            ? Image.file(
                File(selectedImage!.path),
                fit: BoxFit.cover,
              )
            : widget.existing?.imageUrl != null &&
                    widget.existing!.imageUrl!.trim().isNotEmpty
                ? Image.network(
                    widget.existing!.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colors.onSurfaceVariant,
                          size: 42,
                        ),
                      );
                    },
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 42,
                        color: colors.primary,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        sellerTr(
                          'Choose Product Image',
                          'ជ្រើសរើសរូបភាពផលិតផល',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        sellerTr(
                          'Tap to select from gallery',
                          'ចុចដើម្បីជ្រើសរើសពីវិចិត្រសាល',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  // =====================================================
  // FORM LABEL
  // =====================================================

  Widget _label(String text) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =====================================================
  // INPUT DECORATION
  // =====================================================

  InputDecoration _decoration(String hint) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13,
        color: colors.onSurfaceVariant,
      ),
      filled: true,
      fillColor: colors.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colors.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colors.primary,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colors.error,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colors.error,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  // =====================================================
  // INPUT FIELD
  // =====================================================

  Widget _input(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboard,
    TextInputAction? action,
    String? Function(String?)? validator,
  }) {
    final colors = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      enabled: !saving,
      keyboardType: keyboard,
      textInputAction: action,
      validator: validator,
      style: TextStyle(
        color: colors.onSurface,
      ),
      cursorColor: colors.primary,
      onTapOutside: (_) {
        hideKeyboard();
      },
      onFieldSubmitted: (_) {
        hideKeyboard();
      },
      decoration: _decoration(hint).copyWith(
        suffixIcon: IconButton(
          tooltip: sellerTr(
            'Hide keyboard',
            'លាក់ក្តារចុច',
          ),
          onPressed: hideKeyboard,
          icon: Icon(
            Icons.keyboard_hide_outlined,
            size: 19,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // MAIN SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Preserve category values for Laravel.
    final categories = <String>{
      'Phones',
      'Audio',
      'Laptops',
      'Tablets',
      'Watches',
      'Cameras',
      'Gaming',
      'Accessories',
      'Other',
      category,
      ...remoteCategories.map(
        (item) => item['name']?.toString() ?? 'Other',
      ),
    }.toList();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: hideKeyboard,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  16,
                  22,
                  16,
                  8,
                ),
                children: [
                  // =====================================================
                  // HEADER
                  // =====================================================

                  Row(
                    children: [
                      IconButton(
                        tooltip: sellerTr(
                          'Back',
                          'ត្រឡប់ក្រោយ',
                        ),
                        onPressed: saving
                            ? null
                            : () {
                                hideKeyboard();
                                widget.back();
                              },
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: colors.onSurface,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          widget.existing == null
                              ? sellerTr(
                                  'Add product',
                                  'បន្ថែមផលិតផល',
                                )
                              : sellerTr(
                                  'Edit product',
                                  'កែប្រែផលិតផល',
                                ),
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // PRODUCT PHOTO
                  // =====================================================

                  _buildImageSelector(),

                  const SizedBox(height: 16),

                  // =====================================================
                  // PRODUCT NAME
                  // =====================================================

                  _label(
                    sellerTr(
                      'Product name',
                      'ឈ្មោះផលិតផល',
                    ),
                  ),

                  _input(
                    name,
                    sellerTr(
                      'e.g. Wireless earbuds',
                      'ឧ. កាសឥតខ្សែ',
                    ),
                    keyboard: TextInputType.text,
                    action: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return sellerTr(
                          'Enter a product name',
                          'សូមបញ្ចូលឈ្មោះផលិតផល',
                        );
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 13),

                  // =====================================================
                  // CATEGORY
                  // =====================================================

                  _label(
                    sellerTr(
                      'Category',
                      'ប្រភេទ',
                    ),
                  ),

                  DropdownButtonFormField<String>(
                    value: category,
                    isExpanded: true,
                    decoration: _decoration(
                      sellerTr(
                        'Category',
                        'ប្រភេទ',
                      ),
                    ),
                    dropdownColor: colors.surfaceContainer,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 14,
                    ),
                    items: categories.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          _translateCategory(item),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: saving
                        ? null
                        : (value) {
                            if (value == null) return;

                            hideKeyboard();

                            setState(() {
                              category = value;
                            });
                          },
                  ),

                  const SizedBox(height: 13),

                  // =====================================================
                  // PRICE AND STOCK
                  // =====================================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(
                              sellerTr(
                                'Price (USD)',
                                'តម្លៃ (ដុល្លារ)',
                              ),
                            ),

                            _input(
                              price,
                              '0.00',
                              keyboard:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              action: TextInputAction.done,
                              validator: (value) {
                                final parsed = double.tryParse(
                                  value?.trim() ?? '',
                                );

                                if (parsed == null || parsed <= 0) {
                                  return sellerTr(
                                    'Enter valid price',
                                    'សូមបញ្ចូលតម្លៃត្រឹមត្រូវ',
                                  );
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(
                              sellerTr(
                                'Stock',
                                'ស្តុក',
                              ),
                            ),

                            _input(
                              stock,
                              '0',
                              keyboard: TextInputType.number,
                              action: TextInputAction.done,
                              validator: (value) {
                                final parsed = int.tryParse(
                                  value?.trim() ?? '',
                                );

                                if (parsed == null || parsed < 0) {
                                  return sellerTr(
                                    'Enter valid stock',
                                    'សូមបញ្ចូលចំនួនស្តុកត្រឹមត្រូវ',
                                  );
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // =====================================================
                  // DESCRIPTION
                  // =====================================================

                  _label(
                    sellerTr(
                      'Description',
                      'ការពិពណ៌នា',
                    ),
                  ),

                  TextFormField(
                    controller: description,
                    enabled: !saving,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(
                      color: colors.onSurface,
                    ),
                    cursorColor: colors.primary,
                    onTapOutside: (_) => hideKeyboard(),
                    decoration: _decoration(
                      sellerTr(
                        'Tell buyers what makes this product great',
                        'ពិពណ៌នាអំពីលក្ខណៈពិសេសរបស់ផលិតផល',
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =====================================================
                  // LARAVEL INFORMATION
                  // =====================================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 17,
                        color: colors.onSurfaceVariant,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          sellerTr(
                            'Products and selected photos are sent to Laravel.',
                            'ព័ត៌មានផលិតផល និងរូបភាពដែលបានជ្រើសរើសនឹងត្រូវផ្ញើទៅ Laravel។',
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // =====================================================
            // SAVE BUTTONS
            // =====================================================

            Container(
              padding: const EdgeInsets.fromLTRB(
                14,
                10,
                14,
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
              child: Row(
                children: [
                  // SAVE DRAFT
                  Expanded(
                    child: OutlinedButton(
                      onPressed: saving
                          ? null
                          : () => save(true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(
                          color: colors.primary,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      child: Text(
                        sellerTr(
                          'Save draft',
                          'រក្សាទុកព្រាង',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // PUBLISH / SAVE CHANGES
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: saving
                          ? null
                          : () => save(false),
                      child: saving
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.onPrimary,
                              ),
                            )
                          : Text(
                              widget.existing == null
                                  ? sellerTr(
                                      'Publish product',
                                      'បោះពុម្ពផ្សាយផលិតផល',
                                    )
                                  : sellerTr(
                                      'Save changes',
                                      'រក្សាទុកការកែប្រែ',
                                    ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// =====================================================
// SELLER PROFILE SCREEN
// Dark Mode + English / Khmer
// =====================================================

class ProfileScreen extends StatefulWidget {
  final SellerStore store;
  final VoidCallback refresh;
  final VoidCallback logout;

  const ProfileScreen({
    super.key,
    required this.store,
    required this.refresh,
    required this.logout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _description = '';
  bool _loadingSettings = false;
  bool _savingSettings = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  bool _asBool(dynamic value) {
    return value == true ||
        value == 1 ||
        value == '1' ||
        value == 'true';
  }

  // =====================================================
  // LOAD STORE SETTINGS FROM LARAVEL
  // =====================================================

  Future<void> _loadSettings() async {
    if (_loadingSettings) return;

    setState(() {
      _loadingSettings = true;
    });

    try {
      final store =
          await CommerceApi.instance.sellerStoreSettings();

      if (!mounted) return;

      setState(() {
        widget.store.name =
            (store['store_name'] ?? widget.store.name)
                .toString();

        _description =
            (store['description'] ?? '').toString();

        widget.store.open = _asBool(store['is_open']);
      });
    } catch (error) {
      if (!mounted) return;

      info(
        context,
        '${sellerTr(
          'Could not load store settings',
          'មិនអាចផ្ទុកការកំណត់ហាងបាន',
        )}: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingSettings = false;
        });
      }
    }
  }

  // =====================================================
  // SAVE STORE SETTINGS TO LARAVEL
  // =====================================================

  Future<void> _saveSettings({
    String? name,
    String? description,
    bool? isOpen,
  }) async {
    if (_savingSettings || _loadingSettings) return;

    setState(() {
      _savingSettings = true;
    });

    try {
      final store =
          await CommerceApi.instance.updateSellerStoreSettings(
        storeName: name ?? widget.store.name,
        description: description ?? _description,
        isOpen: isOpen ?? widget.store.open,
      );

      if (!mounted) return;

      setState(() {
        widget.store.name =
            (store['store_name'] ?? widget.store.name)
                .toString();

        _description =
            (store['description'] ?? '').toString();

        widget.store.open = _asBool(store['is_open']);
      });

      info(
        context,
        sellerTr(
          'Store settings saved successfully',
          'បានរក្សាទុកការកំណត់ហាងដោយជោគជ័យ',
        ),
      );

      widget.refresh();
    } catch (error) {
      if (!mounted) return;

      info(
        context,
        '${sellerTr(
          'Could not save store settings',
          'មិនអាចរក្សាទុកការកំណត់ហាងបាន',
        )}: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingSettings = false;
        });
      }
    }
  }

  // =====================================================
  // EDIT STORE INFORMATION
  // =====================================================

  Future<void> _rename() async {
    final nameController =
        TextEditingController(text: widget.store.name);

    final descriptionController =
        TextEditingController(text: _description);

    final result = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            sellerTr(
              'Store Information',
              'ព័ត៌មានហាង',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: sellerTr(
                      'Store Name',
                      'ឈ្មោះហាង',
                    ),
                    prefixIcon:
                        const Icon(Icons.store),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: sellerTr(
                      'Store Description',
                      'ការពិពណ៌នាហាង',
                    ),
                    prefixIcon:
                        const Icon(Icons.description),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                sellerTr(
                  'Cancel',
                  'បោះបង់',
                ),
              ),
            ),

            FilledButton(
              onPressed: () {
                final name =
                    nameController.text.trim();

                if (name.isEmpty) return;

                Navigator.pop(
                  dialogContext,
                  (
                    name,
                    descriptionController.text.trim(),
                  ),
                );
              },
              child: Text(
                sellerTr(
                  'Save',
                  'រក្សាទុក',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      nameController.dispose();
      descriptionController.dispose();
      return;
    }

    if (result != null) {
      await _saveSettings(
        name: result.$1,
        description: result.$2,
      );
    }

    nameController.dispose();
    descriptionController.dispose();
  }

  // =====================================================
  // PROFILE MENU ITEM
  // =====================================================

  Widget _tile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 2,
      ),
      leading: Icon(
        icon,
        color: colors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
          fontSize: 12,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 10,
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 18,
        color: colors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  // =====================================================
  // STATISTIC WIDGET
  // =====================================================

  Widget _profileStat(
    String value,
    String label,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PROFILE UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        16,
        26,
        16,
        12,
      ),
      children: [
        // =====================================================
        // PROFILE HEADER
        // =====================================================

        Text(
          sellerTr(
            'Profile',
            'គណនី',
          ),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 18),

        // =====================================================
        // STORE BANNER
        // =====================================================

        Container(
          height: 95,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.storefront_outlined,
              size: 47,
              color: colors.onPrimary,
            ),
          ),
        ),

        // =====================================================
        // STORE DETAILS
        // =====================================================

        card(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              tag(
                sellerTr(
                  'Seller account',
                  'គណនីអ្នកលក់',
                ),
                const Color(0xFFD7F1E8),
              ),

              const SizedBox(height: 10),

              Text(
                widget.store.name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),

              if (_description.trim().isNotEmpty) ...[
                const SizedBox(height: 6),

                Text(
                  _description,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  _profileStat(
                    '${widget.store.totalProducts}',
                    sellerTr(
                      'Products',
                      'ផលិតផល',
                    ),
                  ),

                  _profileStat(
                    '${widget.store.orders.length}',
                    sellerTr(
                      'Orders',
                      'ការបញ្ជាទិញ',
                    ),
                  ),

                  _profileStat(
                    'N/A',
                    sellerTr(
                      'Rating',
                      'ការវាយតម្លៃ',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // =====================================================
        // TOTAL SALES
        // =====================================================

        card(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                sellerTr(
                  'Total sales',
                  'ការលក់សរុប',
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                money(widget.store.totalSales),
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                sellerTr(
                  'Sales value is not the same as withdrawable balance.',
                  'តម្លៃលក់មិនដូចនឹងប្រាក់ដែលអាចដកបានទេ។',
                ),
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // =====================================================
        // STORE OPEN / CLOSED
        // =====================================================

        card(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              sellerTr(
                'Store is open',
                'ហាងកំពុងបើក',
              ),
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              _loadingSettings
                  ? sellerTr(
                      'Loading settings...',
                      'កំពុងផ្ទុកការកំណត់...',
                    )
                  : _savingSettings
                      ? sellerTr(
                          'Saving settings...',
                          'កំពុងរក្សាទុកការកំណត់...',
                        )
                      : sellerTr(
                          'Saved to Laravel database',
                          'បានរក្សាទុកក្នុងមូលដ្ឋានទិន្នន័យ Laravel',
                        ),
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
            value: widget.store.open,
            activeTrackColor: colors.primaryContainer,
            activeColor: colors.primary,
            onChanged:
                _loadingSettings || _savingSettings
                    ? null
                    : (value) {
                        _saveSettings(
                          isOpen: value,
                        );
                      },
          ),
        ),

        // =====================================================
        // AVAILABLE BALANCE
        // =====================================================

        Container(
          padding: const EdgeInsets.all(14),
          margin:
              const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius:
                BorderRadius.circular(17),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellerTr(
                        'Available balance',
                        'សមតុល្យដែលអាចប្រើបាន',
                      ),
                      style: TextStyle(
                        color:
                            colors.onPrimaryContainer,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      sellerTr(
                        'Not available',
                        'មិនទាន់មាន',
                      ),
                      style: TextStyle(
                        color:
                            colors.onPrimaryContainer,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                ),
                onPressed: () {
                  info(
                    context,
                    sellerTr(
                      'Withdrawals are not connected to a payment provider.',
                      'មុខងារដកប្រាក់មិនទាន់ភ្ជាប់ជាមួយសេវាទូទាត់ទេ។',
                    ),
                  );
                },
                child: Text(
                  sellerTr(
                    'Withdraw',
                    'ដកប្រាក់',
                  ),
                ),
              ),
            ],
          ),
        ),

        // =====================================================
        // SELLER SETTINGS MENU
        // =====================================================

        card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _tile(
                Icons.store_outlined,
                sellerTr(
                  'Store information',
                  'ព័ត៌មានហាង',
                ),
                sellerTr(
                  'Name, logo, description',
                  'ឈ្មោះ រូបសញ្ញា ការពិពណ៌នា',
                ),
                _rename,
              ),

              _tile(
                Icons.dark_mode_outlined,
                sellerTr(
                  'Appearance & Language',
                  'រូបរាង និងភាសា',
                ),
                sellerTr(
                  'Dark mode and Khmer language',
                  'របៀបងងឹត និងភាសាខ្មែរ',
                ),
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const AppearanceLanguageScreen(),
                    ),
                  );
                },
              ),

              _tile(
                Icons.account_balance_wallet_outlined,
                sellerTr(
                  'Payout account',
                  'គណនីទទួលប្រាក់',
                ),
                sellerTr(
                  'Manage payout information',
                  'គ្រប់គ្រងព័ត៌មានទទួលប្រាក់',
                ),
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const SellerPayoutScreen(),
                    ),
                  );
                },
              ),

              _tile(
                Icons.local_shipping_outlined,
                sellerTr(
                  'Shipping and delivery',
                  'ការដឹកជញ្ជូន',
                ),
                sellerTr(
                  'Couriers, rates, pickup address',
                  'អ្នកដឹកជញ្ជូន តម្លៃ និងអាសយដ្ឋាន',
                ),
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const SellerShippingScreen(),
                    ),
                  );
                },
              ),

              _tile(
                Icons.star_outline,
                sellerTr(
                  'Customer reviews',
                  'ការវាយតម្លៃអតិថិជន',
                ),
                sellerTr(
                  'See and reply to feedback',
                  'មើល និងឆ្លើយតបមតិ',
                ),
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const SellerReviewsScreen(),
                    ),
                  );
                },
              ),

              _tile(
                Icons.help_outline,
                sellerTr(
                  'Help and support',
                  'ជំនួយ និងការគាំទ្រ',
                ),
                sellerTr(
                  'Contact Admin and view replies',
                  'ទាក់ទងអ្នកគ្រប់គ្រង និងមើលចម្លើយ',
                ),
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const SellerSupportScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // =====================================================
        // LOGOUT
        // =====================================================

        Container(
          margin:
              const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton.icon(
            onPressed: () {
              hideKeyboard();
              widget.logout();
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            label: Text(
              sellerTr(
                'Logout',
                'ចាកចេញ',
              ),
              style: const TextStyle(
                color: Colors.red,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize:
                  const Size(double.infinity, 52),
              side: const BorderSide(
                color: Colors.red,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
