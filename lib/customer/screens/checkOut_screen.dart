import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/bloc/product_event.dart';
import 'package:y3s1_final/bloc/product_state.dart';
import 'package:y3s1_final/services/commerce_api.dart';

const Color checkoutPurple = Color(0xFF6C4DD3);
const Color checkoutBackground = Color(0xFFF8F7FB);
const Color checkoutText = Color(0xFF201B3D);

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

  List<Map<String, dynamic>> _savedAddresses = [];

  bool _loadingAddresses = false;
  bool _placingOrder = false;

  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();

    final user = CommerceApi.instance.currentUser;

    _nameController.text = user?['name']?.toString() ?? '';
    _phoneController.text = user?['phone']?.toString() ?? '';

    _loadSavedAddresses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOAD SAVED SHIPPING ADDRESSES
  // =========================================================

  Future<void> _loadSavedAddresses() async {
    if (CommerceApi.instance.token == null) {
      return;
    }

    setState(() {
      _loadingAddresses = true;
    });

    try {
      final addresses = await CommerceApi.instance.customerAddresses();

      if (!mounted) return;

      setState(() {
        _savedAddresses = addresses;
      });

      if (addresses.isNotEmpty) {
        Map<String, dynamic> selected = addresses.first;

        for (final address in addresses) {
          if (address['is_default'] == true ||
              address['is_default'] == 1 ||
              address['is_default'] == '1') {
            selected = address;
            break;
          }
        }

        _selectAddress(selected);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load saved addresses: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingAddresses = false;
        });
      }
    }
  }

  // =========================================================
  // SELECT SHIPPING ADDRESS
  // =========================================================

  void _selectAddress(Map<String, dynamic> address) {
    final id = int.tryParse(address['id'].toString());

    final street = address['address']?.toString().trim() ?? '';

    final city = address['city']?.toString().trim() ?? '';

    setState(() {
      _selectedAddressId = id;

      _nameController.text = address['full_name']?.toString() ?? '';

      _phoneController.text = address['phone']?.toString() ?? '';

      _addressController.text = [
        street,
        city,
      ].where((value) => value.isNotEmpty).join(', ');
    });
  }

  // =========================================================
  // CHOOSE SAVED ADDRESS
  // =========================================================

  Future<void> _chooseSavedAddress() async {
    if (_savedAddresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved addresses found. Add one from your profile.'),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Shipping Address',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: checkoutText,
                  ),
                ),

                const SizedBox(height: 20),

                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _savedAddresses.length,
                    itemBuilder: (context, index) {
                      final address = _savedAddresses[index];

                      final id = int.tryParse(address['id'].toString());

                      final isSelected = id == _selectedAddressId;

                      return Card(
                        color:
                            isSelected ? const Color(0xFFF0EBFF) : Colors.white,
                        child: ListTile(
                          leading: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.location_on_outlined,
                            color: checkoutPurple,
                          ),

                          title: Text(
                            address['full_name']?.toString() ?? 'Customer',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Text(
                            '${address['address'] ?? ''}, '
                            '${address['city'] ?? ''}\n'
                            '${address['phone'] ?? ''}',
                          ),

                          isThreeLine: true,

                          onTap: () {
                            Navigator.pop(sheetContext, address);
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    _selectAddress(selected);
  }

  // =========================================================
  // PLACE ORDER
  // =========================================================

  Future<void> _placeOrder(ProductState state) async {
    if (_placingOrder) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (state.cartModel.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty.')));
      return;
    }

    if (CommerceApi.instance.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in before placing an order.')),
      );
      return;
    }

    setState(() {
      _placingOrder = true;
    });

    try {
      final items =
          state.cartModel.map((item) {
            return <String, dynamic>{
              'product_id': item.product.code,
              'quantity': item.quantity,
            };
          }).toList();

      final shippingAddress = [
        'Name: ${_nameController.text.trim()}',
        'Phone: ${_phoneController.text.trim()}',
        'Address: ${_addressController.text.trim()}',
      ].join('\n');

      // This sends the order to Laravel.
      // Cash on Delivery is the current payment method.

      final order = await CommerceApi.instance.checkout(
        shippingAddress,
        items,
        paymentMethod: 'cod',
      );

      if (!mounted) return;

      final orderId = order['id']?.toString();

      if (orderId == null || orderId.isEmpty) {
        throw Exception('Laravel did not return an order ID.');
      }

      // Clear the cart only after successful checkout.

      context.read<ProductBloc>().add(ClearCartEvent());

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFFEDE9FF),
                  child: Icon(
                    Icons.check_circle,
                    color: checkoutPurple,
                    size: 45,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Order Placed!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: checkoutText,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Thank you, ${_nameController.text.trim()}!',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Your order number is #$orderId',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Payment: Cash on Delivery',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: checkoutPurple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);

                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Continue Shopping'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to place order: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _placingOrder = false;
        });
      }
    }
  }

  // =========================================================
  // INPUT FIELD
  // =========================================================

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: checkoutPurple),
        filled: true,
        fillColor: checkoutBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }

        if (label == 'Phone Number' &&
            value.replaceAll(RegExp(r'\D'), '').length < 8) {
          return 'Enter a valid phone number';
        }

        return null;
      },
    );
  }

  // =========================================================
  // SECTION CARD
  // =========================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: checkoutPurple),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: checkoutText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  // =========================================================
  // CHECKOUT SCREEN
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: checkoutBackground,

      appBar: AppBar(
        backgroundColor: checkoutBackground,
        foregroundColor: checkoutText,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.cartModel.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(fontSize: 18, color: checkoutText),
              ),
            );
          }

          final subtotal = state.cartModel.fold<double>(
            0,
            (total, item) => total + item.product.price * item.quantity,
          );

          const serviceFee = 1.0;

          final deliveryFee = subtotal > 100 ? 0.0 : 2.0;

          final total = subtotal + serviceFee + deliveryFee;

          return Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      // =====================================
                      // SHIPPING ADDRESS
                      // =====================================
                      _sectionCard(
                        title: 'Delivery Details',
                        icon: Icons.local_shipping_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_loadingAddresses)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: LinearProgressIndicator(),
                              ),

                            if (_savedAddresses.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: OutlinedButton.icon(
                                  onPressed: _chooseSavedAddress,
                                  icon: const Icon(Icons.location_on_outlined),
                                  label: const Text('Choose Saved Address'),
                                ),
                              ),

                            _inputField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                            ),

                            const SizedBox(height: 14),

                            _inputField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 14),

                            _inputField(
                              controller: _addressController,
                              label: 'Delivery Address',
                              icon: Icons.location_on_outlined,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),

                      // =====================================
                      // PAYMENT METHOD
                      // =====================================
                      _sectionCard(
                        title: 'Payment Method',
                        icon: Icons.payments_outlined,
                        child: const Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFFEDE9FF),
                              child: Icon(Icons.money, color: checkoutPurple),
                            ),

                            SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cash on Delivery',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Pay when your order arrives',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(Icons.check_circle, color: checkoutPurple),
                          ],
                        ),
                      ),

                      // =====================================
                      // ORDER SUMMARY
                      // =====================================
                      _sectionCard(
                        title: 'Order Summary',
                        icon: Icons.shopping_bag_outlined,
                        child: Column(
                          children: [
                            for (final item in state.cartModel)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        item.product.image,
                                        width: 55,
                                        height: 55,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => const Icon(
                                              Icons.image_outlined,
                                              size: 45,
                                            ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text('Quantity: ${item.quantity}'),
                                        ],
                                      ),
                                    ),

                                    Text(
                                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const Divider(),

                            _priceRow('Subtotal', subtotal),

                            _priceRow('Service Fee', serviceFee),

                            _priceRow('Delivery Fee', deliveryFee),

                            const Divider(),

                            _priceRow('Total', total, bold: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ===========================================
              // PLACE ORDER BUTTON
              // ===========================================
              SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  color: Colors.white,
                  child: ElevatedButton.icon(
                    onPressed: _placingOrder ? null : () => _placeOrder(state),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: checkoutPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    icon:
                        _placingOrder
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(Icons.lock_outline),

                    label: Text(
                      _placingOrder
                          ? 'Placing Order...'
                          : 'Place Order - \$${total.toStringAsFixed(2)}',
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

  // =========================================================
  // PRICE ROW
  // =========================================================

  Widget _priceRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 17 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: bold ? checkoutPurple : checkoutText,
              fontSize: bold ? 19 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
