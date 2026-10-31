import 'package:flutter/material.dart';

import 'package:y3s1_final/login_form.dart';
import 'package:y3s1_final/services/app_preferences.dart';

import '../services/commerce_api.dart';
import 'seller_data.dart';
import 'seller_screens.dart';

// Keep these constants because seller_screens.dart uses them.
const navy = Color(0xFF1D265B);
const lavender = Color(0xFFDDD8FF);
const background = Color(0xFFF0EFF6);

class SellerMain extends StatefulWidget {
  const SellerMain({super.key});

  @override
  State<SellerMain> createState() => _SellerMainState();
}

class _SellerMainState extends State<SellerMain> {
  final SellerStore store = SellerStore();

  int tab = 0;
  bool adding = false;
  bool _loading = true;
  bool _refreshing = false;
  bool _confirmingOrder = false;

  String? _error;

  String tr(String english, String khmer) {
    return AppPreferences.instance.translate(english, khmer);
  }

  @override
  void initState() {
    super.initState();
    _initializeSeller();
  }

  // =====================================================
  // INITIALIZE SELLER
  // =====================================================

  Future<void> _initializeSeller() async {
    if (CommerceApi.instance.token == null) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = tr(
          'Please log in with your seller account first.',
          'សូមចូលគណនីអ្នកលក់ជាមុនសិន។',
        );
      });

      return;
    }

    try {
      await _loadAll();

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  // =====================================================
  // LOAD SELLER DATA FROM LARAVEL
  // =====================================================

  Future<void> _loadAll() async {
    final results = await Future.wait<dynamic>([
      CommerceApi.instance.sellerProducts(),
      CommerceApi.instance.sellerOrders(),
      CommerceApi.instance.sellerDashboard(),
    ]);

    if (!mounted) return;

    final productRows = results[0] as List<Map<String, dynamic>>;
    final orderRows = results[1] as List<Map<String, dynamic>>;
    final dashboard = results[2] as Map<String, dynamic>;

    setState(() {
      store.products.clear();

      for (final row in productRows) {
        store.products.add(
          SellerProduct(
            row['name']?.toString() ?? '',
            double.tryParse(row['price']?.toString() ?? '') ?? 0,
            int.tryParse(row['stock']?.toString() ?? '') ?? 0,
            Icons.inventory_2_outlined,
            lavender,
            category: row['category']?.toString() ?? 'Other',
            description: row['description']?.toString() ?? '',
            id: int.tryParse(row['id']?.toString() ?? ''),
            imageUrl: row['image_url']?.toString(),
          ),
        );
      }

      store.orders.clear();

      for (final row in orderRows) {
        store.orders.add(SellerOrder.fromJson(row));
      }

      store.updateDashboard(dashboard);
    });
  }

  // =====================================================
  // REFRESH SELLER DATA
  // =====================================================

  Future<void> _refreshAll() async {
    if (_refreshing) return;

    if (mounted) {
      setState(() {
        _refreshing = true;
      });
    }

    try {
      await _loadAll();
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }

  // =====================================================
  // ERROR MESSAGE
  // =====================================================

  void _showError(Object error) {
    if (!mounted) return;

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // =====================================================
  // SUCCESS MESSAGE
  // =====================================================

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // =====================================================
  // NAVIGATION
  // =====================================================

  void navigate(int value) {
    if (value < 0 || value > 3) return;

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      tab = value;
      adding = false;
    });

    _refreshAll();
  }

  // =====================================================
  // ADD PRODUCT
  // =====================================================

  void add() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      adding = true;
    });
  }

  // =====================================================
  // CONFIRM SELLER ORDER
  // =====================================================

  Future<void> _updateOrder(
    SellerOrder order,
    String newStatus,
  ) async {
    if (_confirmingOrder) return;

    final currentStatus = order.status.trim().toLowerCase();

    final isPending =
        currentStatus == 'pending' || currentStatus == 'new';

    // Sellers only confirm orders.
    // Warehouse handles packing and shipping.
    if (newStatus != 'processing' || !isPending) {
      _showError(
        tr(
          'Only new orders can be confirmed. '
              'Warehouse handles packing and shipping.',
          'អាចបញ្ជាក់បានតែការបញ្ជាទិញថ្មីប៉ុណ្ណោះ។ '
              'ឃ្លាំងទទួលខុសត្រូវលើការវេចខ្ចប់ និងដឹកជញ្ជូន។',
        ),
      );
      return;
    }

    // Mixed-seller orders remain blocked by Laravel.
    if (!order.canUpdate) {
      _showError(
        tr(
          'This order cannot be confirmed by this seller. '
              'Mixed-seller orders require separate confirmation.',
          'អ្នកលក់នេះមិនអាចបញ្ជាក់ការបញ្ជាទិញនេះបានទេ។ '
              'ការបញ្ជាទិញពីអ្នកលក់ច្រើនត្រូវការការបញ្ជាក់ដាច់ដោយឡែក។',
        ),
      );
      return;
    }

    final orderId = int.tryParse(order.id);

    if (orderId == null) {
      _showError(
        tr(
          'Invalid order ID.',
          'លេខសម្គាល់ការបញ្ជាទិញមិនត្រឹមត្រូវ។',
        ),
      );
      return;
    }

    setState(() {
      _confirmingOrder = true;
    });

    try {
      await CommerceApi.instance.updateSellerOrder(
        orderId,
        'processing',
      );

      if (!mounted) return;

      await _loadAll();

      if (!mounted) return;

      _showSuccess(
        tr(
          'Order #$orderId confirmed successfully.',
          'ការបញ្ជាទិញលេខ $orderId បានបញ្ជាក់ដោយជោគជ័យ។',
        ),
      );
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) {
        setState(() {
          _confirmingOrder = false;
        });
      }
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> _logout() async {
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await CommerceApi.instance.logout();
    } catch (error) {
      debugPrint('Logout error: $error');
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginForm(),
      ),
      (route) => false,
    );
  }

  // =====================================================
  // MAIN SELLER SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final screenBackground = theme.scaffoldBackgroundColor;

    final contentBackground = dark
        ? colors.surface
        : background;

    final borderColor = dark
        ? colors.outlineVariant
        : const Color(0xFFE0DFE8);

    if (_loading) {
      return Scaffold(
        backgroundColor: screenBackground,
        body: Center(
          child: CircularProgressIndicator(
            color: colors.primary,
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: screenBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    tr(
                      'Unable to load seller dashboard',
                      'មិនអាចផ្ទុកផ្ទាំងគ្រប់គ្រងអ្នកលក់បានទេ',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 20),

                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });

                      _initializeSeller();
                    },
                    child: Text(
                      tr(
                        'Try Again',
                        'ព្យាយាមម្តងទៀត',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final pages = <Widget>[
      DashboardScreen(
        store: store,
        navigate: navigate,
        add: add,
      ),

      ProductsScreen(
        store: store,
        refresh: _refreshAll,
        edit: _edit,
      ),

      OrdersScreen(
        store: store,
        refresh: _refreshAll,
        updateOrder: _updateOrder,
      ),

      ProfileScreen(
        store: store,
        refresh: _refreshAll,
        logout: _logout,
      ),
    ];

    return Scaffold(
      backgroundColor: screenBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 520,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: contentBackground,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    if (_refreshing)
                      LinearProgressIndicator(
                        minHeight: 2,
                        color: colors.primary,
                      ),

                    Expanded(
                      child: adding
                          ? AddProductScreen(
                              store: store,
                              done: () {
                                setState(() {
                                  adding = false;
                                  tab = 1;
                                });

                                _refreshAll();
                              },
                              back: () {
                                setState(() {
                                  adding = false;
                                });
                              },
                            )
                          : pages[tab],
                    ),

                    if (!adding)
                      SellerNav(
                        selected: tab,
                        onSelect: navigate,
                        onAdd: add,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // EDIT PRODUCT
  // =====================================================

  void _edit(SellerProduct item) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (routeContext) {
          final theme = Theme.of(routeContext);

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 520,
                  ),
                  child: AddProductScreen(
                    store: store,
                    existing: item,
                    back: () {
                      Navigator.pop(routeContext);
                    },
                    done: () {
                      Navigator.pop(routeContext);
                      _refreshAll();
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =====================================================
// SELLER BOTTOM NAVIGATION
// DARK MODE + KHMER LANGUAGE
// =====================================================

class SellerNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  const SellerNav({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final settings = AppPreferences.instance;

    final navBackground = dark
        ? colors.surfaceContainerHigh
        : Colors.white.withValues(alpha: 0.8);

    final activeBackground = dark
        ? colors.primaryContainer
        : lavender;

    final inactiveColor = dark
        ? colors.onSurface
        : navy;

    final activeColor = dark
        ? colors.onPrimaryContainer
        : navy;

    final navigationItems = [
      (
        0,
        Icons.grid_view_rounded,
        settings.translate(
          'Home',
          'ទំព័រដើម',
        ),
      ),
      (
        1,
        Icons.inventory_2_outlined,
        settings.translate(
          'Products',
          'ផលិតផល',
        ),
      ),
      (
        2,
        Icons.receipt_long_outlined,
        settings.translate(
          'Orders',
          'ការបញ្ជាទិញ',
        ),
      ),
      (
        3,
        Icons.person_outline,
        settings.translate(
          'Profile',
          'គណនី',
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        4,
        12,
        16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: navBackground,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  for (final (index, icon, label)
                      in navigationItems)
                    InkWell(
                      onTap: () => onSelect(index),
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: selected == index ? 9 : 8,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: selected == index
                              ? activeBackground
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 20,
                              color: selected == index
                                  ? activeColor
                                  : inactiveColor,
                            ),

                            if (selected == index) ...[
                              const SizedBox(width: 5),

                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: settings.isKhmer
                                      ? 11
                                      : 12,
                                  color: activeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 9),

          FloatingActionButton.small(
            heroTag: 'sellerAdd',
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            onPressed: onAdd,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}