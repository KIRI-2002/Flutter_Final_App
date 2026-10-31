import 'package:flutter/material.dart';

import 'package:y3s1_final/services/app_preferences.dart';
import 'package:y3s1_final/services/commerce_api.dart';

// =====================================================
// TRANSLATION
// =====================================================

String _tr(String english, String khmer) {
  return AppPreferences.instance.translate(english, khmer);
}

// =====================================================
// CUSTOMER ORDERS SCREEN
// =====================================================

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() =>
      _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  int? _confirmingOrderId;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // =====================================================
  // LOAD ORDERS FROM LARAVEL
  // =====================================================

  void _loadOrders() {
    _ordersFuture = CommerceApi.instance.myOrders();
  }

  Future<void> _refresh() async {
    setState(_loadOrders);

    try {
      await _ordersFuture;
    } catch (error) {
      debugPrint('Unable to refresh orders: $error');
    }
  }

  // =====================================================
  // SHOW MESSAGE
  // =====================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // =====================================================
  // CONFIRM ORDER RECEIVED
  // =====================================================

  Future<void> _confirmReceived(int orderId) async {
    if (_confirmingOrderId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            _tr(
              'Confirm Received',
              'បញ្ជាក់ការទទួលទំនិញ',
            ),
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            _tr(
              'Have you received your order?',
              'តើអ្នកបានទទួលទំនិញរបស់អ្នកហើយឬនៅ?',
            ),
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                _tr('Cancel', 'បោះបង់'),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              child: Text(
                _tr(
                  'Yes, Received',
                  'បាទ/ចាស បានទទួលហើយ',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _confirmingOrderId = orderId;
    });

    try {
      // Preserve the existing Laravel API request.
      await CommerceApi.instance.confirmOrderReceived(orderId);

      if (!mounted) return;

      _showMessage(
        _tr(
          'Order marked as received!',
          'បានបញ្ជាក់ថាទទួលទំនិញរួចហើយ!',
        ),
      );

      await _refresh();
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        '${_tr(
          'Unable to confirm order',
          'មិនអាចបញ្ជាក់ការបញ្ជាទិញបាន',
        )}: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _confirmingOrderId = null;
        });
      }
    }
  }

  // =====================================================
  // ORDER STATUS COLORS
  // =====================================================

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'completed':
        return const Color(0xFF16803D);

      case 'shipped':
      case 'delivered':
        return const Color(0xFF2563EB);

      case 'processing':
      case 'packed':
        return const Color(0xFFB45309);

      case 'cancelled':
        return const Color(0xFFDC2626);

      default:
        return const Color(0xFF6C4DD3);
    }
  }

  // =====================================================
  // TRANSLATE ORDER STATUS
  // =====================================================

  String _translateStatus(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return _tr('PENDING', 'កំពុងរង់ចាំ');

      case 'processing':
        return _tr('PROCESSING', 'កំពុងដំណើរការ');

      case 'packed':
        return _tr('PACKED', 'បានវេចខ្ចប់');

      case 'shipped':
        return _tr('SHIPPED', 'បានដឹកចេញ');

      case 'delivered':
        return _tr('DELIVERED', 'បានដឹកដល់');

      case 'completed':
        return _tr('COMPLETED', 'បានបញ្ចប់');

      case 'cancelled':
        return _tr('CANCELLED', 'បានលុបចោល');

      default:
        return status.toUpperCase();
    }
  }

  // =====================================================
  // STATUS BADGE
  // =====================================================

  Widget _buildStatusBadge(String status) {
    final statusColor = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _translateStatus(status),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState(Object? error) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: colors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 46,
                color: colors.onErrorContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _tr(
                'Unable to load orders',
                'មិនអាចផ្ទុកការបញ្ជាទិញបាន',
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
              error?.toString() ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
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
  // EMPTY ORDERS
  // =====================================================

  Widget _buildEmptyState() {
    final colors = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(26),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 105,
                          height: 105,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 52,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          _tr(
                            'No orders yet',
                            'មិនទាន់មានការបញ្ជាទិញទេ',
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
                            'Your orders will appear here after checkout.',
                            'ការបញ្ជាទិញរបស់អ្នកនឹងបង្ហាញនៅទីនេះបន្ទាប់ពីទូទាត់ប្រាក់។',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _tr(
                            'Pull down to refresh',
                            'អូសចុះក្រោមដើម្បីផ្ទុកឡើងវិញ',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =====================================================
  // ORDER PRODUCT ROW
  // =====================================================

  Widget _buildOrderItem(Map rawItem) {
    final colors = Theme.of(context).colorScheme;

    final product = rawItem['product'];

    String productName = _tr('Product', 'ផលិតផល');

    if (product is Map) {
      final name = product['name']?.toString().trim();

      if (name != null && name.isNotEmpty) {
        productName = name;
      }
    }

    final quantity = rawItem['quantity'] ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: colors.onPrimaryContainer,
              size: 18,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              productName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.4,
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '× $quantity',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ORDER CARD
  // =====================================================

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final id = int.tryParse(
      order['id']?.toString() ?? '',
    );

    final status = order['status']?.toString() ?? 'pending';
    final normalizedStatus = status.toLowerCase().trim();

    final total = double.tryParse(
          order['total']?.toString() ?? '',
        ) ??
        0.0;

    final date = order['created_at']?.toString() ?? '';

    // Preserve the original order confirmation rules.
    final canConfirm =
        normalizedStatus == 'shipped' ||
        normalizedStatus == 'delivered';

    final isConfirming =
        id != null && _confirmingOrderId == id;

    final rawItems = order['items'];
    final items = rawItems is List ? rawItems : [];

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ORDER NUMBER
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: colors.onPrimaryContainer,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_tr('Order', 'ការបញ្ជាទិញ')} #${id ?? '-'}',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // ORDER STATUS
          Align(
            alignment: Alignment.centerLeft,
            child: _buildStatusBadge(status),
          ),

          // ORDER DATE
          if (date.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    date.length >= 10
                        ? date.substring(0, 10)
                        : date,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // ORDER ITEMS
          if (items.isNotEmpty) ...[
            Text(
              _tr(
                'Order items',
                'ទំនិញក្នុងការបញ្ជាទិញ',
              ),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final rawItem in items)
              if (rawItem is Map)
                _buildOrderItem(rawItem),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // ORDER TOTAL
          Row(
            children: [
              Expanded(
                child: Text(
                  _tr('Total', 'សរុប'),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isDark
                      ? colors.primary
                      : const Color(0xFF3730A3),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          // CONFIRM RECEIVED BUTTON
          if (canConfirm && id != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _confirmingOrderId != null
                    ? null
                    : () => _confirmReceived(id),
                icon: isConfirming
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onPrimary,
                        ),
                      )
                    : const Icon(
                        Icons.check_circle_outline_rounded,
                      ),
                label: Text(
                  isConfirming
                      ? _tr(
                          'Confirming...',
                          'កំពុងបញ្ជាក់...',
                        )
                      : _tr(
                          'Confirm Received',
                          'បញ្ជាក់ការទទួលទំនិញ',
                        ),
                  textAlign: TextAlign.center,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],

          // COMPLETED ORDER MESSAGE
          if (normalizedStatus == 'completed') ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: colors.onPrimaryContainer,
                    size: 22,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _tr(
                        'Received and completed',
                        'បានទទួល និងបញ្ចប់ការបញ្ជាទិញ',
                      ),
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark
              ? theme.scaffoldBackgroundColor
              : const Color(0xFFFFF7F7),
          appBar: AppBar(
            backgroundColor: isDark
                ? theme.scaffoldBackgroundColor
                : const Color(0xFFFFF7F7),
            foregroundColor: colors.onSurface,
            elevation: 0,
            centerTitle: true,
            title: Text(
              _tr(
                'My Orders',
                'ការបញ្ជាទិញរបស់ខ្ញុំ',
              ),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(
                    color: colors.primary,
                  ),
                );
              }

              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error);
              }

              final orders = snapshot.data ?? [];

              if (orders.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    30,
                  ),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) {
                    return const SizedBox(height: 14);
                  },
                  itemBuilder: (context, index) {
                    return _buildOrderCard(orders[index]);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}