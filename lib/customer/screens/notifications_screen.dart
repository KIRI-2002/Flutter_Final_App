import 'package:flutter/material.dart';

import 'package:y3s1_final/services/app_preferences.dart';
import 'package:y3s1_final/services/commerce_api.dart';

// =====================================================
// TRANSLATION HELPER
// =====================================================

String _tr(String english, String khmer) {
  return AppPreferences.instance.translate(english, khmer);
}

// =====================================================
// NOTIFICATIONS SCREEN
// =====================================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color purple = Color(0xFF6C4DD3);
  static const Color lightBackground = Color(0xFFF8F7FB);

  List<Map<String, dynamic>> _orders = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // =====================================================
  // LOAD NOTIFICATIONS FROM LARAVEL
  // =====================================================

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Preserve the existing Laravel API.
      final orders = await CommerceApi.instance.myOrders();

      if (!mounted) return;

      setState(() {
        _orders = orders;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // =====================================================
  // NOTIFICATION TITLE
  // =====================================================

  String _notificationTitle(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return _tr(
          'Order Placed',
          'បានបញ្ជាទិញ',
        );

      case 'processing':
        return _tr(
          'Order Confirmed',
          'បានបញ្ជាក់ការបញ្ជាទិញ',
        );

      case 'packed':
        return _tr(
          'Order Packed',
          'បានវេចខ្ចប់ទំនិញ',
        );

      case 'shipped':
        return _tr(
          'Order Shipped',
          'បានដឹកជញ្ជូនទំនិញចេញ',
        );

      case 'delivered':
        return _tr(
          'Order Delivered',
          'បានដឹកជញ្ជូនទំនិញដល់',
        );

      case 'completed':
        return _tr(
          'Order Completed',
          'ការបញ្ជាទិញបានបញ្ចប់',
        );

      case 'cancelled':
        return _tr(
          'Order Cancelled',
          'ការបញ្ជាទិញត្រូវបានលុបចោល',
        );

      default:
        return _tr(
          'Order Update',
          'ព័ត៌មានថ្មីអំពីការបញ្ជាទិញ',
        );
    }
  }

  // =====================================================
  // NOTIFICATION MESSAGE
  // =====================================================

  String _notificationMessage(
    String status,
    dynamic orderId,
  ) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return _tr(
          'Your order #$orderId has been placed successfully.',
          'ការបញ្ជាទិញលេខ #$orderId របស់អ្នកបានជោគជ័យ។',
        );

      case 'processing':
        return _tr(
          'The seller confirmed your order #$orderId.',
          'អ្នកលក់បានបញ្ជាក់ការបញ្ជាទិញលេខ #$orderId របស់អ្នក។',
        );

      case 'packed':
        return _tr(
          'Your order #$orderId has been packed.',
          'ការបញ្ជាទិញលេខ #$orderId របស់អ្នកត្រូវបានវេចខ្ចប់រួចហើយ។',
        );

      case 'shipped':
        return _tr(
          'Your order #$orderId is on the way.',
          'ការបញ្ជាទិញលេខ #$orderId របស់អ្នកកំពុងដឹកជញ្ជូន។',
        );

      case 'delivered':
        return _tr(
          'Your order #$orderId has been delivered.',
          'ការបញ្ជាទិញលេខ #$orderId របស់អ្នកបានដឹកដល់ហើយ។',
        );

      case 'completed':
        return _tr(
          'You confirmed receiving order #$orderId.',
          'អ្នកបានបញ្ជាក់ថាបានទទួលការបញ្ជាទិញលេខ #$orderId។',
        );

      case 'cancelled':
        return _tr(
          'Your order #$orderId was cancelled.',
          'ការបញ្ជាទិញលេខ #$orderId របស់អ្នកត្រូវបានលុបចោល។',
        );

      default:
        return _tr(
          'There is an update for your order #$orderId.',
          'មានព័ត៌មានថ្មីសម្រាប់ការបញ្ជាទិញលេខ #$orderId របស់អ្នក។',
        );
    }
  }

  // =====================================================
  // NOTIFICATION ICON
  // =====================================================

  IconData _notificationIcon(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return Icons.shopping_bag_outlined;

      case 'processing':
        return Icons.check_circle_outline;

      case 'packed':
        return Icons.inventory_2_outlined;

      case 'shipped':
        return Icons.local_shipping_outlined;

      case 'delivered':
        return Icons.home_outlined;

      case 'completed':
        return Icons.verified_outlined;

      case 'cancelled':
        return Icons.cancel_outlined;

      default:
        return Icons.notifications_outlined;
    }
  }

  // =====================================================
  // STATUS COLOR
  // =====================================================

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'completed':
      case 'delivered':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      case 'shipped':
        return Colors.blue;

      default:
        return purple;
    }
  }

  // =====================================================
  // NOTIFICATION CARD
  // =====================================================

  Widget _buildNotification(
    Map<String, dynamic> order,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final orderId = order['id'] ?? '';

    final status =
        order['status']?.toString() ?? 'pending';

    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STATUS ICON
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              _notificationIcon(status),
              color: color,
            ),
          ),

          const SizedBox(width: 14),

          // NOTIFICATION INFORMATION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                Text(
                  _notificationTitle(status),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // MESSAGE
                Text(
                  _notificationMessage(status, orderId),
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 10),

                // ORDER NUMBER
                Text(
                  '${_tr(
                    'Order',
                    'ការបញ្ជាទិញ',
                  )} #$orderId',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? colors.primary
                        : color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // LOADING STATE
  // =====================================================

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
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
              size: 48,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 12),

            Text(
              '${_tr(
                'Unable to load notifications.',
                'មិនអាចផ្ទុកការជូនដំណឹងបាន។',
              )}\n$_error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loadNotifications,
              child: Text(
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
  // EMPTY STATE
  // =====================================================

  Widget _buildEmptyState() {
    final colors = Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 150),

        Icon(
          Icons.notifications_none,
          size: 70,
          color: colors.onSurfaceVariant,
        ),

        const SizedBox(height: 16),

        Center(
          child: Text(
            _tr(
              'No notifications yet',
              'មិនទាន់មានការជូនដំណឹងទេ',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _tr(
                'Your order updates will appear here.',
                'ព័ត៌មានថ្មីអំពីការបញ្ជាទិញរបស់អ្នកនឹងបង្ហាញនៅទីនេះ។',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
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
            : lightBackground;

        return Scaffold(
          backgroundColor: backgroundColor,

          // APP BAR
          appBar: AppBar(
            title: Text(
              _tr(
                'Notifications',
                'ការជូនដំណឹង',
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            backgroundColor: colors.surface,
            foregroundColor: colors.onSurface,
            elevation: 0,
          ),

          // BODY
          body: _loading
              ? _buildLoadingState()
              : _error != null
                  ? _buildErrorState()
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: colors.primary,
                      child: _orders.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                return _buildNotification(
                                  _orders[index],
                                );
                              },
                            ),
                    ),
        );
      },
    );
  }
}