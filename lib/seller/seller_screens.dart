import 'package:flutter/material.dart';
import 'seller_data.dart';
import 'seller_main.dart';

Widget heading(String title, String subtitle) => Padding(
  padding: const EdgeInsets.only(bottom: 18),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w800,
          color: navy,
        ),
      ),
      Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF626993), fontSize: 12),
      ),
    ],
  ),
);
Widget card({
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(14),
}) => Container(
  margin: const EdgeInsets.only(bottom: 9),
  padding: padding,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(17),
    boxShadow: [
      BoxShadow(
        color: navy.withValues(alpha: .04),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  ),
  child: child,
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
void info(BuildContext context, String message) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));

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
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
    children: [
      Row(
        children: [
          const CircleAvatar(
            backgroundColor: lavender,
            child: Icon(Icons.storefront_outlined, color: navy),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Seller dashboard',
                  style: TextStyle(fontSize: 11, color: navy),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => info(context, 'No new notifications'),
            icon: const Icon(Icons.notifications_none_rounded, color: navy),
          ),
        ],
      ),
      const SizedBox(height: 16),
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
                const Text(
                  "Today's sales",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                tag('↑ 12% vs yesterday', lavender),
              ],
            ),
            const Text(
              '\$1,284.50',
              style: TextStyle(
                fontSize: 29,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final height in [
                    28.0,
                    42.0,
                    25.0,
                    48.0,
                    35.0,
                    55.0,
                    40.0,
                  ])
                    Container(
                      width: 21,
                      height: height,
                      decoration: BoxDecoration(
                        color: lavender.withValues(
                          alpha: height == 40 ? 1 : .35,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final day in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                  Text(
                    day,
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 13),
      Row(
        children: [
          for (final stat in [
            ('12', 'New orders'),
            ('5', 'To ship'),
            ('3', 'Low stock'),
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
                        style: const TextStyle(
                          fontSize: 22,
                          color: navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        stat.$2,
                        style: const TextStyle(fontSize: 10, color: navy),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      Row(
        children: [
          _action(Icons.add, 'Add product', add),
          _action(
            Icons.local_offer_outlined,
            'Discounts',
            () => info(context, 'Discounts coming soon'),
          ),
          _action(
            Icons.chat_bubble_outline,
            'Messages',
            () => info(context, 'No new messages'),
          ),
        ],
      ),
      const SizedBox(height: 13),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent orders',
            style: TextStyle(fontWeight: FontWeight.bold, color: navy),
          ),
          TextButton(
            onPressed: () => navigate(2),
            child: const Text('See all'),
          ),
        ],
      ),
      for (final order in store.orders.take(3))
        card(
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: background,
                child: Icon(Icons.receipt_long_outlined, color: navy),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.id}',
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Customer: ${order.customer}',
                      style: const TextStyle(fontSize: 10, color: navy),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    money(order.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  tag(order.status, lavender),
                ],
              ),
            ],
          ),
        ),
    ],
  );
  Widget _action(IconData icon, String label, VoidCallback onTap) => Expanded(
    child: Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        child: card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: navy),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: navy,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

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
  @override
  Widget build(BuildContext context) {
    final products =
        widget.store.products
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 34, 15, 15),
      children: [
        heading(
          'My products',
          '${widget.store.products.length} listed in your store',
        ),
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search your products',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (products.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Text('No matching products'),
            ),
          ),
        for (final item in products)
          card(
            padding: const EdgeInsets.all(9),
            child: Row(
              children: [
                Container(
                  width: 57,
                  height: 57,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(item.icon, color: const Color(0xFF6770A1)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        money(item.price),
                        style: const TextStyle(
                          color: Color(0xFF514AC4),
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        children: [
                          tag(
                            item.stock == 0
                                ? 'Out of stock'
                                : item.stock <= 3
                                ? 'Low stock'
                                : 'Active',
                            item.stock == 0
                                ? const Color(0xFFFFDED5)
                                : item.stock <= 3
                                ? const Color(0xFFFFE7AF)
                                : const Color(0xFFD7F1E8),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${item.stock} in stock',
                              style: const TextStyle(color: navy, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => widget.edit(item),
                  icon: const Icon(Icons.edit_outlined, color: navy, size: 19),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class OrdersScreen extends StatefulWidget {
  final SellerStore store;
  final VoidCallback refresh;
  const OrdersScreen({super.key, required this.store, required this.refresh});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String status = 'New';
  @override
  Widget build(BuildContext context) {
    final orders =
        widget.store.orders.where((o) => o.status == status).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 15),
      children: [
        heading('Orders', 'Accept, pack and ship'),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E3EE),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              for (final s in ['New', 'To ship', 'Shipped'])
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => status = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: status == s ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '$s (${widget.store.orders.where((o) => o.status == s).length})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (orders.isEmpty)
          card(child: const Center(child: Text('No orders in this tab'))),
        for (final order in orders)
          card(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    Text(
                      order.time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B6DA4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: background,
                      child: Icon(Icons.inventory_2_outlined, color: navy),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.details,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: navy,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '[${order.customer}] · [${order.city}]',
                            style: const TextStyle(color: navy, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 23),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontSize: 10, color: navy),
                          ),
                          Text(
                            money(order.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: navy,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (status != 'Shipped') ...[
                      TextButton(
                        onPressed: () {
                          setState(() => order.status = 'Declined');
                          info(context, 'Order declined');
                        },
                        child: Text(status == 'New' ? 'Decline' : 'Cancel'),
                      ),
                      const SizedBox(width: 5),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: navy),
                        onPressed: () {
                          setState(
                            () =>
                                order.status =
                                    status == 'New' ? 'To ship' : 'Shipped',
                          );
                          info(context, 'Order updated');
                        },
                        child: Text(status == 'New' ? 'Accept' : 'Ship'),
                      ),
                    ] else
                      tag('Shipped', const Color(0xFFD7F1E8)),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class AddProductScreen extends StatefulWidget {
  final SellerStore store;
  final SellerProduct? existing;
  final VoidCallback done, back;
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
  final key = GlobalKey<FormState>();
  late final TextEditingController name, price, stock, description;
  String category = 'Phones';
  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    name = TextEditingController(text: p?.name ?? '');
    price = TextEditingController(text: p == null ? '' : p.price.toString());
    stock = TextEditingController(text: p == null ? '' : p.stock.toString());
    description = TextEditingController(text: p?.description ?? '');
    category = p?.category ?? 'Phones';
  }

  @override
  void dispose() {
    name.dispose();
    price.dispose();
    stock.dispose();
    description.dispose();
    super.dispose();
  }

  void save(bool draft) {
    if (!key.currentState!.validate()) return;
    final existing = widget.existing;
    if (existing == null) {
      widget.store.products.add(
        SellerProduct(
          name.text.trim(),
          double.parse(price.text),
          int.parse(stock.text),
          Icons.inventory_2_outlined,
          lavender,
          category: category,
          description: description.text,
        ),
      );
    } else {
      existing.name = name.text.trim();
      existing.price = double.parse(price.text);
      existing.stock = int.parse(stock.text);
      existing.category = category;
      existing.description = description.text;
    }
    info(
      context,
      draft ? 'Product saved locally' : 'Product published locally',
    );
    widget.done();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: key,
    child: Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.back,
                    icon: const Icon(Icons.arrow_back_ios_new, color: navy),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.existing == null ? 'Add product' : 'Edit product',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: Container(
                        height: 84,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: i == 0 ? background : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              i == 0
                                  ? Border.all(
                                    color: const Color(0xFF9C8BFF),
                                    style: BorderStyle.solid,
                                  )
                                  : null,
                        ),
                        child:
                            i == 0
                                ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      color: navy,
                                    ),
                                    Text(
                                      'Photo preview',
                                      style: TextStyle(
                                        color: navy,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                )
                                : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _label('Product name'),
              _input(
                name,
                'e.g. Wireless earbuds',
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Enter a product name'
                            : null,
              ),
              const SizedBox(height: 13),
              _label('Category'),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: _decoration('Category'),
                items:
                    ['Phones', 'Audio', 'Computers', 'Accessories', 'Other']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (v) => setState(() => category = v ?? 'Phones'),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Price (USD)'),
                        _input(
                          price,
                          '0.00',
                          keyboard: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator:
                              (v) =>
                                  double.tryParse(v ?? '') == null ||
                                          double.parse(v!) <= 0
                                      ? 'Enter valid price'
                                      : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Stock'),
                        _input(
                          stock,
                          '0',
                          keyboard: TextInputType.number,
                          validator:
                              (v) =>
                                  int.tryParse(v ?? '') == null ||
                                          int.parse(v!) < 0
                                      ? 'Enter valid stock'
                                      : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label('Description'),
                  TextButton.icon(
                    onPressed:
                        () => setState(
                          () =>
                              description.text =
                                  'High-quality ${name.text.isEmpty ? 'product' : name.text} designed for everyday use.',
                        ),
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('Write with Nova'),
                  ),
                ],
              ),
              TextFormField(
                controller: description,
                maxLines: 4,
                decoration: _decoration(
                  'Tell buyers what makes this product great',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sample data only. Photos are placeholders and products are not saved after restarting the app.',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => save(true),
                  child: const Text('Save draft'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: navy),
                  onPressed: () => save(false),
                  child: Text(
                    widget.existing == null
                        ? 'Publish product'
                        : 'Save changes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: navy,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(14),
    ),
  );
  Widget _input(
    TextEditingController c,
    String hint, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: c,
    keyboardType: keyboard,
    validator: validator,
    decoration: _decoration(hint),
  );
}

class ProfileScreen extends StatefulWidget {
  final SellerStore store;
  final VoidCallback refresh, customer;
  const ProfileScreen({
    super.key,
    required this.store,
    required this.refresh,
    required this.customer,
  });
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 26, 16, 12),
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          IconButton(
            onPressed: () => info(context, 'Using light theme'),
            icon: const Icon(Icons.light_mode_outlined, color: navy),
          ),
        ],
      ),
      Container(
        height: 95,
        decoration: const BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Icon(Icons.storefront_outlined, size: 47, color: Colors.white),
        ),
      ),
      card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tag('✓ Verified seller', const Color(0xFFD7F1E8)),
            const SizedBox(height: 7),
            Text(
              widget.store.name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: navy),
            ),
            const Text(
              '@store-handle · City',
              style: TextStyle(fontSize: 11, color: navy),
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat('24', 'Products'),
                _Stat('312', 'Orders'),
                _Stat('4.8 ★', 'Rating'),
              ],
            ),
          ],
        ),
      ),
      card(
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Store is open',
            style: TextStyle(color: navy, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'Customers can place orders',
            style: TextStyle(fontSize: 11),
          ),
          activeThumbColor: navy,
          value: widget.store.open,
          onChanged: (v) => setState(() => widget.store.open = v),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: lavender,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available balance',
                    style: TextStyle(color: navy, fontSize: 11),
                  ),
                  Text(
                    money(widget.store.balance),
                    style: const TextStyle(
                      color: navy,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: navy),
              onPressed:
                  () => info(
                    context,
                    'Demo only: withdrawals are not connected to a payment provider',
                  ),
              child: const Text('Withdraw'),
            ),
          ],
        ),
      ),
      card(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _tile(
              Icons.store_outlined,
              'Store information',
              'Name, logo, description',
              () => _rename(context),
            ),
            _tile(
              Icons.account_balance_wallet_outlined,
              'Payout account',
              'Where your earnings are sent',
              () => info(context, 'Demo payout account'),
            ),
            _tile(
              Icons.local_shipping_outlined,
              'Shipping and delivery',
              'Couriers, rates, pickup address',
              () => info(context, 'Demo shipping settings'),
            ),
            _tile(
              Icons.star_outline,
              'Customer reviews',
              'See and reply to feedback',
              () => info(context, 'No new reviews'),
            ),
            _tile(
              Icons.help_outline,
              'Help and support',
              'Seller guides and contact',
              () => info(context, 'Seller demo help'),
            ),
          ],
        ),
      ),
      TextButton(
        onPressed: widget.customer,
        child: const Text('Switch to Customer', style: TextStyle(color: navy)),
      ),
    ],
  );
  Widget _tile(IconData icon, String title, String sub, VoidCallback tap) =>
      ListTile(
        dense: true,
        leading: Icon(icon, color: navy),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: navy,
            fontSize: 12,
          ),
        ),
        subtitle: Text(sub, style: const TextStyle(fontSize: 10)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: tap,
      );
  Future<void> _rename(BuildContext context) async {
    final controller = TextEditingController(text: widget.store.name);
    final value = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Store name'),
            content: TextField(controller: controller, autofocus: true),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    controller.dispose();
    if (value != null && value.isNotEmpty) {
      setState(() => widget.store.name = value);
    }
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: navy,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 10, color: navy)),
    ],
  );
}
