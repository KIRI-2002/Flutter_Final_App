import 'package:flutter/material.dart';

const _navy = Color(0xFF1E1B4B);
const _purple = Color(0xFF6C4DD3);

class HomeScreenCustomer extends StatefulWidget {
  const HomeScreenCustomer({super.key});

  @override
  State<HomeScreenCustomer> createState() => _HomeScreenCustomerState();
}

class _HomeScreenCustomerState extends State<HomeScreenCustomer> {
  final _bannerController = PageController();
  int _bannerIndex = 0;

  final _banners = const [
    _BannerData('Home Decor', 'Up to 40% off lamps & more', Icons.table_bar_outlined, Color(0xFFFCE8B8)),
    _BannerData('New Arrivals', 'Fresh styles just landed', Icons.checkroom_outlined, Color(0xFFFFD9C7)),
    _BannerData('Free Shipping', 'On orders over \$50', Icons.local_shipping_outlined, Color(0xFFD6CBFF)),
  ];

  final _products = [
    _Product('Canvas Tote', 24.00, 'New', Icons.shopping_bag_outlined,
        [Color(0xFFE4DCFF), Color(0xFFC9BCFF)]),
    _Product('Linen Shirt', 39.00, '-20%', Icons.checkroom_outlined,
        [Color(0xFFFFE6DA), Color(0xFFFFCDB8)]),
    _Product('Desk Lamp', 59.00, null, Icons.table_bar_outlined,
        [Color(0xFFD9F0FF), Color(0xFFBFE3FA)]),
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE4F1), Color(0xFFE8E1FF), Color(0xFFDDF6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildBanner(),
                const SizedBox(height: 24),
                _buildSectionTitle('Trending now'),
                const SizedBox(height: 12),
                _buildProducts(),
                const SizedBox(height: 24),
                _buildNovaCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFE0D8FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: _navy),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome Back,',
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
                Text('[Your name]',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: _navy)),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none, color: _navy),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: _purple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Search ----------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products, brands',
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.6),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ---------- Banner (under search bar) ----------
  Widget _buildBanner() {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (_, i) {
              final b = _banners[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: b.color,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(b.icon, size: 34, color: _navy),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.title,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: _navy)),
                          const SizedBox(height: 4),
                          Text(b.subtitle,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == _bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? _purple : _purple.withOpacity(0.25),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ---------- Trending ----------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: _navy)),
          TextButton(
            onPressed: () {},
            child: const Text('See all',
                style: TextStyle(color: _purple, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildProducts() {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _ProductCard(
          product: _products[i],
          onFav: () => setState(() => _products[i].fav = !_products[i].fav),
        ),
      ),
    );
  }

  // ---------- Nova AI card ----------
  Widget _buildNovaCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE4DCFF), Color(0xFFD2C6FF)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined, color: _navy),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Not sure what to buy?',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _navy)),
                  SizedBox(height: 4),
                  Text('Tell Nova your budget and get picks.',
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _navy,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= Models & small widgets =================

class _BannerData {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  const _BannerData(this.title, this.subtitle, this.icon, this.color);
}

class _Product {
  final String name;
  final double price;
  final String? badge;
  final IconData icon;
  final List<Color> colors;
  bool fav;
  _Product(this.name, this.price, this.badge, this.icon, this.colors,
      {this.fav = false});
}

class _ProductCard extends StatelessWidget {
  final _Product product;
  final VoidCallback onFav;
  const _ProductCard({required this.product, required this.onFav});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: product.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                children: [
                  Center(
                      child: Icon(product.icon, size: 48, color: Colors.black45)),
                  if (product.badge != null)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _navy,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(product.badge!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: GestureDetector(
                      onTap: onFav,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          product.fav ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: product.fav ? _purple : _navy,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: _navy)),
                const SizedBox(height: 2),
                Text('\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: _purple)),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}