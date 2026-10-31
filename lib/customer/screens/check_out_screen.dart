import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/bloc/product_event.dart';
import 'package:y3s1_final/bloc/product_state.dart';
import 'package:y3s1_final/models/cart_model.dart';
import 'package:y3s1_final/services/app_preferences.dart';
import 'package:y3s1_final/services/commerce_api.dart';

// =====================================================
// TRANSLATION
// =====================================================

String _tr(String english, String khmer) {
  return AppPreferences.instance.translate(english, khmer);
}

// =====================================================
// CUSTOMER CHECKOUT SCREEN
// =====================================================

class CheckoutScreenCustomer extends StatefulWidget {
  const CheckoutScreenCustomer({super.key});

  @override
  State<CheckoutScreenCustomer> createState() =>
      _CheckoutScreenCustomerState();
}

class _CheckoutScreenCustomerState
    extends State<CheckoutScreenCustomer> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _placingOrder = false;

  @override
  void initState() {
    super.initState();

    final user = CommerceApi.instance.currentUser;

    _nameController.text = user?['name']?.toString() ?? '';
    _phoneController.text = user?['phone']?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // =====================================================
  // PLACE ORDER - LARAVEL API
  // =====================================================

  Future<void> _placeOrder(ProductState state) async {
    if (_placingOrder) return;

    if (!_formKey.currentState!.validate()) return;

    if (state.cartModel.isEmpty) {
      _showMessage(
        _tr(
          'Your cart is empty.',
          'កន្ត្រកទំនិញរបស់អ្នកនៅទទេ។',
        ),
      );
      return;
    }

    if (CommerceApi.instance.token == null) {
      _showMessage(
        _tr(
          'Please log in before placing an order.',
          'សូមចូលគណនីមុនពេលបញ្ជាទិញ។',
        ),
      );
      return;
    }

    setState(() {
      _placingOrder = true;
    });

    try {
      // Preserve the existing Laravel API payload.
      final items = state.cartModel.map((item) {
        return <String, dynamic>{
          'product_id': item.product.code,
          'quantity': item.quantity,
        };
      }).toList();

      final order = await CommerceApi.instance.checkout(
        _addressController.text.trim(),
        items,
      );

      if (!mounted) return;

      final orderNumber = order['id']?.toString();

      if (orderNumber == null || orderNumber.isEmpty) {
        throw Exception('Laravel did not return an order ID.');
      }

      // Clear the cart only after Laravel confirms the order.
      context.read<ProductBloc>().add(ClearCartEvent());

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          final colors = Theme.of(dialogContext).colorScheme;

          return AlertDialog(
            backgroundColor: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: colors.onPrimaryContainer,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  _tr(
                    'Order placed!',
                    'បានបញ្ជាទិញដោយជោគជ័យ!',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _tr(
                    'Thanks, ${_nameController.text.trim()}. '
                        'Your order #$orderNumber is confirmed.',
                    'សូមអរគុណ ${_nameController.text.trim()}។ '
                        'ការបញ្ជាទិញលេខ #$orderNumber '
                        'របស់អ្នកត្រូវបានបញ្ជាក់។',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();

                      if (mounted) {
                        Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      _tr(
                        'Continue shopping',
                        'បន្តទិញទំនិញ',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        '${_tr(
          'Unable to place order',
          'មិនអាចបញ្ជាទិញបាន',
        )}: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _placingOrder = false;
        });
      }
    }
  }

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
        duration: Duration(
          seconds: isError ? 5 : 3,
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
        final dark = theme.brightness == Brightness.dark;

        final backgroundColor = dark
            ? theme.scaffoldBackgroundColor
            : const Color(0xFFF8F7FB);

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            foregroundColor: colors.onSurface,
            elevation: 0,
            centerTitle: true,
            title: Text(
              _tr('Checkout', 'ការទូទាត់ប្រាក់'),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          body: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state.cartModel.isEmpty) {
                return _EmptyCheckout(
                  onBack: () {
                    Navigator.of(context).maybePop();
                  },
                );
              }

              // Keep the existing checkout calculations.
              final itemSubtotal = state.cartModel.fold<double>(
                0,
                (total, item) {
                  return total +
                      item.product.price * item.quantity;
                },
              );

              const serviceFee = 1.0;

              final deliveryFee =
                  itemSubtotal > 100 ? 0.0 : 2.0;

              final total =
                  itemSubtotal + serviceFee + deliveryFee;

              return Column(
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          8,
                          18,
                          24,
                        ),
                        children: [
                          // DELIVERY DETAILS
                          _SectionHeading(
                            icon: Icons.local_shipping_outlined,
                            title: _tr(
                              'Delivery details',
                              'ព័ត៌មានដឹកជញ្ជូន',
                            ),
                            subtitle: _tr(
                              'Where should we send your order?',
                              'តើយើងគួរដឹកទំនិញទៅទីណា?',
                            ),
                          ),

                          const SizedBox(height: 14),

                          _CheckoutCard(
                            child: Column(
                              children: [
                                _CheckoutField(
                                  controller: _nameController,
                                  label: _tr(
                                    'Full name',
                                    'ឈ្មោះពេញ',
                                  ),
                                  hint: _tr(
                                    'Enter your name',
                                    'បញ្ចូលឈ្មោះរបស់អ្នក',
                                  ),
                                  icon: Icons.person_outline_rounded,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return _tr(
                                        'Please enter your name',
                                        'សូមបញ្ចូលឈ្មោះរបស់អ្នក',
                                      );
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                _CheckoutField(
                                  controller: _phoneController,
                                  label: _tr(
                                    'Phone number',
                                    'លេខទូរស័ព្ទ',
                                  ),
                                  hint: _tr(
                                    'Enter your phone number',
                                    'បញ្ចូលលេខទូរស័ព្ទ',
                                  ),
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    final phone =
                                        value?.trim() ?? '';

                                    if (phone.isEmpty) {
                                      return _tr(
                                        'Please enter your phone number',
                                        'សូមបញ្ចូលលេខទូរស័ព្ទ',
                                      );
                                    }

                                    final digits = phone.replaceAll(
                                      RegExp(r'\D'),
                                      '',
                                    );

                                    if (digits.length < 8) {
                                      return _tr(
                                        'Enter a valid phone number',
                                        'សូមបញ្ចូលលេខទូរស័ព្ទត្រឹមត្រូវ',
                                      );
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                _CheckoutField(
                                  controller: _addressController,
                                  label: _tr(
                                    'Delivery address',
                                    'អាសយដ្ឋានដឹកជញ្ជូន',
                                  ),
                                  hint: _tr(
                                    'Street, area, city',
                                    'ផ្លូវ តំបន់ ទីក្រុង',
                                  ),
                                  icon: Icons.location_on_outlined,
                                  maxLines: 2,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return _tr(
                                        'Please enter your delivery address',
                                        'សូមបញ្ចូលអាសយដ្ឋានដឹកជញ្ជូន',
                                      );
                                    }

                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 26),

                          // PAYMENT METHOD
                          _SectionHeading(
                            icon: Icons.payments_outlined,
                            title: _tr(
                              'Payment method',
                              'វិធីសាស្ត្រទូទាត់',
                            ),
                            subtitle: _tr(
                              'Pay when your order arrives',
                              'ទូទាត់ពេលទទួលទំនិញ',
                            ),
                          ),

                          const SizedBox(height: 14),

                          _CheckoutCard(
                            child: Row(
                              children: [
                                const _IconBadge(
                                  icon: Icons.money_rounded,
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _tr(
                                          'Cash on delivery',
                                          'បង់ប្រាក់ពេលទទួលទំនិញ',
                                        ),
                                        style: TextStyle(
                                          color: colors.onSurface,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        _tr(
                                          'Pay in cash when you receive your items',
                                          'បង់ប្រាក់សុទ្ធនៅពេលទទួលទំនិញ',
                                        ),
                                        style: TextStyle(
                                          color: colors.onSurfaceVariant,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Icon(
                                  Icons.check_circle,
                                  color: colors.primary,
                                  size: 25,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 26),

                          // ORDER SUMMARY
                          _SectionHeading(
                            icon: Icons.shopping_bag_outlined,
                            title: _tr(
                              'Order summary',
                              'សង្ខេបការបញ្ជាទិញ',
                            ),
                            subtitle: _tr(
                              'Review your items',
                              'ពិនិត្យទំនិញរបស់អ្នក',
                            ),
                          ),

                          const SizedBox(height: 14),

                          _CheckoutCard(
                            child: Column(
                              children: [
                                for (
                                  var index = 0;
                                  index < state.cartModel.length;
                                  index++
                                ) ...[
                                  _OrderItemRow(
                                    item: state.cartModel[index],
                                  ),

                                  if (index <
                                      state.cartModel.length - 1)
                                    const Divider(height: 24),
                                ],

                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  child: Divider(height: 1),
                                ),

                                _PriceRow(
                                  label: _tr(
                                    'Items subtotal',
                                    'សរុបតម្លៃទំនិញ',
                                  ),
                                  value: itemSubtotal,
                                ),

                                const SizedBox(height: 12),

                                _PriceRow(
                                  label: _tr(
                                    'Service fee',
                                    'ថ្លៃសេវាកម្ម',
                                  ),
                                  value: serviceFee,
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _tr(
                                        'Delivery',
                                        'ការដឹកជញ្ជូន',
                                      ),
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    Text(
                                      deliveryFee == 0
                                          ? _tr(
                                              'FREE',
                                              'ឥតគិតថ្លៃ',
                                            )
                                          : '\$${deliveryFee.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: deliveryFee == 0
                                            ? (dark
                                                ? Colors.greenAccent
                                                : Colors.green.shade700)
                                            : colors.onSurface,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  child: Divider(height: 1),
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _tr('Total', 'សរុប'),
                                      style: TextStyle(
                                        color: colors.onSurface,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),

                                    Text(
                                      '\$${total.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: dark
                                            ? colors.primary
                                            : const Color(0xFF3730A3),
                                        fontSize: 23,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // PLACE ORDER BUTTON
                  SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        12,
                        18,
                        12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border(
                          top: BorderSide(
                            color: colors.outlineVariant,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _placingOrder
                              ? null
                              : () => _placeOrder(state),
                          icon: _placingOrder
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 19,
                                ),
                          label: Text(
                            _placingOrder
                                ? _tr(
                                    'Placing order...',
                                    'កំពុងបញ្ជាទិញ...',
                                  )
                                : '${_tr(
                                    'Place order',
                                    'បញ្ជាទិញ',
                                  )} · \$${total.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 17,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
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
// SECTION HEADING
// =====================================================

class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        _IconBadge(icon: icon),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =====================================================
// ICON BADGE
// =====================================================

class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: colors.onPrimaryContainer,
        size: 23,
      ),
    );
  }
}

// =====================================================
// CHECKOUT CARD
// =====================================================

class _CheckoutCard extends StatelessWidget {
  final Widget child;

  const _CheckoutCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant,
        ),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: child,
    );
  }
}

// =====================================================
// CHECKOUT INPUT FIELD
// =====================================================

class _CheckoutField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final int maxLines;

  const _CheckoutField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        color: colors.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: colors.onSurfaceVariant,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: colors.onSurfaceVariant,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: colors.primary,
          size: 22,
        ),
        filled: true,
        fillColor: colors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colors.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colors.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// ORDER ITEM ROW
// =====================================================

class _OrderItemRow extends StatelessWidget {
  final CartModel item;

  const _OrderItemRow({
    required this.item,
  });

  Widget _imagePlaceholder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 64,
      height: 64,
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: colors.onSurfaceVariant,
        size: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final image = item.product.image.trim();

    Widget productImage;

    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      productImage = Image.network(
        image,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imagePlaceholder(context);
        },
      );
    } else if (image.isNotEmpty) {
      productImage = Image.asset(
        image,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imagePlaceholder(context);
        },
      );
    } else {
      productImage = _imagePlaceholder(context);
    }

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: productImage,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                '${_tr('Qty', 'ចំនួន')}: ${item.quantity}',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Text(
          '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
          style: TextStyle(
            color: dark
                ? colors.primary
                : const Color(0xFF3730A3),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// PRICE ROW
// =====================================================

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;

  const _PriceRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// EMPTY CHECKOUT
// =====================================================

class _EmptyCheckout extends StatelessWidget {
  final VoidCallback onBack;

  const _EmptyCheckout({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 56,
                color: colors.onPrimaryContainer,
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
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              _tr(
                'Add a few items before checking out.',
                'សូមបន្ថែមទំនិញមុនពេលទូទាត់ប្រាក់។',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            FilledButton(
              onPressed: onBack,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: Text(
                _tr(
                  'Back to cart',
                  'ត្រឡប់ទៅកន្ត្រក',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}