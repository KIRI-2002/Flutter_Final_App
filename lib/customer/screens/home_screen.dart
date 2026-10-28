import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/bloc/product_event.dart';
import 'package:y3s1_final/bloc/product_state.dart';
import 'package:y3s1_final/chatbot/screen/chat_screen.dart';
import 'package:y3s1_final/customer/screens/cart_screen.dart';
import 'package:y3s1_final/customer/screens/detail_product.dart';
import 'package:y3s1_final/customer/screens/search_screen.dart';
import 'package:y3s1_final/models/product_model.dart';
import 'package:y3s1_final/util/app_text.dart';

const _navy = Color(0xFF1E1B4B);
const _purple = Color(0xFF6C4DD3);

class HomeScreenCustomer extends StatefulWidget {
  const HomeScreenCustomer({super.key});

  @override
  State<HomeScreenCustomer> createState() => _HomeScreenState();
}

final List<String> banner = [
  "https://i.pinimg.com/1200x/91/01/4d/91014d88d8ff324dda302f8bd746cc15.jpg",
  "https://i.pinimg.com/1200x/bb/84/9e/bb849eb4de975c14ace8448af06a54f1.jpg",
  "https://i.pinimg.com/1200x/c5/96/ec/c596eccecc3f7c802e9104362da03049.jpg",
  "https://i.pinimg.com/1200x/2c/c8/27/2cc8272c1fdb090e843771fb0850abbc.jpg",
];

class _HomeScreenState extends State<HomeScreenCustomer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _TopBar()),
            const SliverToBoxAdapter(child: _BannerCard()),
            const SliverToBoxAdapter(child: _CategoryGrid()),
            const SliverToBoxAdapter(child: _NovaAI()),
            const SliverToBoxAdapter(child: _SectionTitle('  Product')),
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                final products = state.filteredProducts;
                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 28, 24, 36),
                      child: Center(
                        child: Text(
                          'No products in this category yet.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.68,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _ProductCard(product: products[index]),
                      childCount: products.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: _StoreBenefits()),
          ],
        ),
      ),
    );
  }
}

class _StoreBenefits extends StatelessWidget {
  const _StoreBenefits();

  static const _benefits = <({IconData icon, String label})>[
    (icon: Icons.local_shipping_outlined, label: 'Free delivery\nover \$100'),
    (icon: Icons.verified_user_outlined, label: '2-year warranty'),
    (icon: Icons.replay_rounded, label: '30-day easy\nreturns'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // color: const Color(0xFF101426),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (var index = 0; index < _benefits.length; index++) ...[
            if (index > 0) SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 112,
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 30, 37, 87),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFF303656)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _benefits[index].icon,
                      color: Color.fromARGB(255, 252, 252, 252),
                      size: 27,
                    ),
                    SizedBox(height: 10),
                    Text(
                      _benefits[index].label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF4F3FF),
                        fontSize: 11,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo placeholder - swap for your brand mark asset.
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                'https://i.pinimg.com/736x/b5/03/ec/b503ecc77de7a2f3416592c48793305f.jpg',
              ),
            ),
          ),
          Text(
            'Name For Store',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),

          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white70,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SearchScreen()),
                    );
                  },
                  icon: Icon(Icons.search, size: 25),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductCart(check: true),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                  BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      return Positioned(
                        right: 1,
                        top: 5,
                        child: Container(
                          height: 20,
                          width: 20,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            textAlign: TextAlign.center,
                            state.cartModel.length.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatefulWidget {
  const _BannerCard();

  @override
  State<_BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends State<_BannerCard> {
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 170,
              child: PageView.builder(
                controller: _controller,
                itemCount: banner.length,
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    banner[index],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          color: Color(0xFFF5F5F7),
                          alignment: Alignment.center,
                          child: Icon(Icons.image_outlined),
                        ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banner.length,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: currentPage == index ? 18 : 9,
                height: 9,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color:
                      currentPage == index
                          ? Colors.blueAccent
                          : Color.fromARGB(255, 215, 215, 215),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  static const _categories = <({String name, IconData icon})>[
    (name: 'Phones', icon: Icons.smartphone_rounded),
    (name: 'Laptops', icon: Icons.laptop_mac_rounded),
    (name: 'Tablets', icon: Icons.tablet_mac_rounded),
    (name: 'Audio', icon: Icons.headphones_rounded),
    (name: 'Watches', icon: Icons.watch_rounded),
    (name: 'Cameras', icon: Icons.camera_alt_outlined),
    (name: 'Gaming', icon: Icons.gamepad_rounded),
    (name: 'Accessories', icon: Icons.power_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder:
          (context, state) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = category.name == state.selectedCategory;
                return Semantics(
                  button: true,
                  selected: selected,
                  label: category.name,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap:
                        () => context.read<ProductBloc>().add(
                          SelectCategory(selected ? 'All' : category.name),
                        ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 180),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color:
                                selected
                                    ? Color.fromARGB(255, 30, 37, 87)
                                    : Color.fromARGB(255, 30, 37, 87),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? _purple : Color(0xFF303656),
                              width: selected ? 1.6 : 1,
                            ),
                          ),
                          child: Icon(
                            category.icon,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 29,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color.fromARGB(255, 5, 5, 5),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color.fromARGB(255, 192, 192, 192)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Color.fromARGB(255, 240, 238, 238),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    AppText(text: product.rate, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'View(${product.view})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: "\$${product.price.toStringAsFixed(2)}",
                      size: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.blue,
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NovaAI extends StatelessWidget {
  const _NovaAI();

  @override
  // ---------- Nova AI card ----------
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF4A3AB5)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Image.asset(height: 50, width: 50, 'assets/images/chatbot.png'),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Can't decide? Ask Nova",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Compare phones and laptops for your budget.',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatScreen()),
                    );
                  },
                  icon: Icon(Icons.arrow_forward, color: _navy),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
