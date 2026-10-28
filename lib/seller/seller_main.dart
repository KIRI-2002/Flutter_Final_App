import 'package:flutter/material.dart';

import '../customer/main_customer.dart';
import 'seller_data.dart';
import 'seller_screens.dart';

const navy = Color(0xFF1D265B);
const lavender = Color(0xFFDDD8FF);
const background = Color(0xFFF0EFF6);

class SellerMain extends StatefulWidget {
  const SellerMain({super.key});

  @override
  State<SellerMain> createState() => _SellerMainState();
}

class _SellerMainState extends State<SellerMain> {
  final store = SellerStore();
  int tab = 0;
  bool adding = false;

  void navigate(int value) {
    setState(() {
      tab = value;
      adding = false;
    });
  }

  void add() => setState(() => adding = true);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(store: store, navigate: navigate, add: add),
      ProductsScreen(store: store, refresh: () => setState(() {}), edit: _edit),
      OrdersScreen(store: store, refresh: () => setState(() {})),
      ProfileScreen(
        store: store,
        refresh: () => setState(() {}),
        customer:
            () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainCustomer()),
            ),
      ),
    ];

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
        scaffoldBackgroundColor: background,
        fontFamily: 'Roboto',
      ),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: const Color(0xFFE0DFE8)),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child:
                            adding
                                ? AddProductScreen(
                                  store: store,
                                  done:
                                      () => setState(() {
                                        adding = false;
                                        tab = 1;
                                      }),
                                  back: () => setState(() => adding = false),
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
      ),
    );
  }

  void _edit(SellerProduct item) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder:
            (_) => Theme(
              data: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: navy),
              ),
              child: Scaffold(
                backgroundColor: background,
                body: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: AddProductScreen(
                        store: store,
                        existing: item,
                        back: () => Navigator.pop(context),
                        done: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .8),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final (index, icon, label) in [
                  (0, Icons.grid_view_rounded, 'Home'),
                  (1, Icons.inventory_2_outlined, 'Products'),
                  (2, Icons.receipt_long_outlined, 'Orders'),
                  (3, Icons.person_outline, 'Profile'),
                ])
                  InkWell(
                    onTap: () => onSelect(index),
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: selected == index ? 12 : 8,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color:
                            selected == index ? lavender : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Icon(icon, size: 20, color: navy),
                          if (selected == index) ...[
                            const SizedBox(width: 5),
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 12,
                                color: navy,
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
          backgroundColor: navy,
          foregroundColor: Colors.white,
          onPressed: onAdd,
          child: const Icon(Icons.add),
        ),
      ],
    ),
  );
}
