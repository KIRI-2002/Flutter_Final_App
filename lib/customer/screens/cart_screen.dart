import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/bloc/product_event.dart';
import 'package:y3s1_final/bloc/product_state.dart';
import 'package:y3s1_final/customer/screens/check_out_screen.dart';
import 'package:y3s1_final/models/cart_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) => const ProductCart();
}

class ProductCart extends StatelessWidget {
  final bool check;

  const ProductCart({super.key, this.check = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(248, 255, 247, 247),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(248, 255, 247, 247),
        title: Text(
          check ? 'Your Cart' : 'Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.cartModel.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.cartModel.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder:
                      (context, index) =>
                          _CartItem(item: state.cartModel[index]),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total'),
                          Text('\$${state.subtotal().toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => const CheckoutScreenCustomer(),
                                ),
                              ),
                          child: const Text('Continue to checkout'),
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
  }
}

class _CartItem extends StatelessWidget {
  final CartModel item;

  const _CartItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProductBloc>();
    final unitPrice = item.product.price;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.image,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const SizedBox(
                      width: 76,
                      height: 76,
                      child: Icon(Icons.image_not_supported_outlined),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${item.size} · ${item.color}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text('\$${unitPrice.toStringAsFixed(2)}'),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed:
                            item.quantity > 1
                                ? () => bloc.add(
                                  UpdateQuantityEvent(
                                    cartModel: item,
                                    quantity: item.quantity - 1,
                                  ),
                                )
                                : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed:
                            () => bloc.add(
                              UpdateQuantityEvent(
                                cartModel: item,
                                quantity: item.quantity + 1,
                              ),
                            ),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove item',
              onPressed:
                  () => bloc.add(
                    RemoveCartEvent(removeCart: item, code: item.product.code),
                  ),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
