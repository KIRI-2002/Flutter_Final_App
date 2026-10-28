import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/bloc/product_event.dart';
import 'package:y3s1_final/bloc/product_state.dart';
import 'package:y3s1_final/models/cart_model.dart';

const _checkoutInk = Color(0xFF201B3D);
const _checkoutAccent = Color(0xFF6C4DD3);
const _checkoutBackground = Color(0xFFF8F7FB);

class CheckoutScreenCustomer extends StatefulWidget {
  const CheckoutScreenCustomer({super.key});

  @override
  State<CheckoutScreenCustomer> createState() => _CheckoutScreenCustomerState();
}

class _CheckoutScreenCustomerState extends State<CheckoutScreenCustomer> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(ProductState state) async {
    if (!_formKey.currentState!.validate()) return;

    final orderNumber = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);
    context.read<ProductBloc>().add(ClearCartEvent());

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE9FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: _checkoutAccent,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Order placed!',
                  style: TextStyle(
                    color: _checkoutInk,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thanks, ${_nameController.text.trim()}. Your order #$orderNumber is confirmed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _checkoutAccent,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Continue shopping'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _checkoutBackground,
      appBar: AppBar(
        backgroundColor: _checkoutBackground,
        foregroundColor: _checkoutInk,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.cartModel.isEmpty) {
            return _EmptyCheckout(
              onBack: () => Navigator.of(context).maybePop(),
            );
          }

          final itemSubtotal = state.cartModel.fold<double>(
            0,
            (total, item) => total + item.product.price * item.quantity,
          );
          const serviceFee = 1.0;
          final deliveryFee = itemSubtotal > 100 ? 0.0 : 2.0;
          final total = itemSubtotal + serviceFee + deliveryFee;

          return Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                    children: [
                      _SectionHeading(
                        icon: Icons.local_shipping_outlined,
                        title: 'Delivery details',
                        subtitle: 'Where should we send your order?',
                      ),
                      const SizedBox(height: 14),
                      _CheckoutCard(
                        child: Column(
                          children: [
                            _CheckoutField(
                              controller: _nameController,
                              label: 'Full name',
                              hint: 'Enter your name',
                              icon: Icons.person_outline_rounded,
                              validator:
                                  (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'Please enter your name'
                                          : null,
                            ),
                            const SizedBox(height: 14),
                            _CheckoutField(
                              controller: _phoneController,
                              label: 'Phone number',
                              hint: 'Enter your phone number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                final phone = value?.trim() ?? '';
                                if (phone.isEmpty)
                                  return 'Please enter your phone number';
                                if (phone.replaceAll(RegExp(r'\D'), '').length <
                                    8) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            _CheckoutField(
                              controller: _addressController,
                              label: 'Delivery address',
                              hint: 'Street, area, city',
                              icon: Icons.location_on_outlined,
                              maxLines: 2,
                              validator:
                                  (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'Please enter your delivery address'
                                          : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _SectionHeading(
                        icon: Icons.payments_outlined,
                        title: 'Payment method',
                        subtitle: 'Pay when your order arrives',
                      ),
                      const SizedBox(height: 14),
                      const _CheckoutCard(
                        child: Row(
                          children: [
                            _IconBadge(icon: Icons.money_rounded),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cash on delivery',
                                    style: TextStyle(
                                      color: _checkoutInk,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Pay in cash when you receive your items',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.check_circle, color: _checkoutAccent),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _SectionHeading(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Order summary',
                        subtitle: 'Review your items',
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
                              _OrderItemRow(item: state.cartModel[index]),
                              if (index < state.cartModel.length - 1)
                                const Divider(height: 22),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Divider(height: 1),
                            ),
                            _PriceRow(
                              label: 'Items subtotal',
                              value: itemSubtotal,
                            ),
                            const SizedBox(height: 10),
                            _PriceRow(label: 'Service fee', value: serviceFee),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Delivery'),
                                Text(
                                  deliveryFee == 0
                                      ? 'FREE'
                                      : '\$${deliveryFee.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color:
                                        deliveryFee == 0
                                            ? Colors.green.shade700
                                            : _checkoutInk,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    color: _checkoutInk,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: _checkoutAccent,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
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
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _placeOrder(state),
                      icon: const Icon(Icons.lock_outline_rounded, size: 18),
                      label: Text(
                        'Place order  ·  \$${total.toStringAsFixed(2)}',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _checkoutAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBadge(icon: icon),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _checkoutInk,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: _checkoutAccent, size: 21),
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEBF2)),
      ),
      child: child,
    );
  }
}

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _checkoutAccent, size: 20),
        filled: true,
        fillColor: const Color(0xFFFAF9FC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE8E5EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE8E5EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _checkoutAccent, width: 1.5),
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final CartModel item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.product.image,
            width: 62,
            height: 62,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  width: 62,
                  height: 62,
                  color: const Color(0xFFF0EFF5),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_outlined, color: Colors.grey),
                ),
          ),
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
                style: const TextStyle(
                  color: _checkoutInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.size} • ${item.color}  ·  Qty ${item.quantity}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
          style: const TextStyle(
            color: _checkoutInk,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: const TextStyle(
            color: _checkoutInk,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyCheckout extends StatelessWidget {
  const _EmptyCheckout({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 58,
              color: _checkoutAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                color: _checkoutInk,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a few items before checking out.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onBack,
              style: FilledButton.styleFrom(backgroundColor: _checkoutAccent),
              child: const Text('Back to cart'),
            ),
          ],
        ),
      ),
    );
  }
}
