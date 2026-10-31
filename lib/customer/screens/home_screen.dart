import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/bloc/product_event.dart';
import 'package:y3s1_final/bloc/product_state.dart';

import 'package:y3s1_final/chatbot/screen/chat_screen.dart';

import 'package:y3s1_final/customer/screens/cart_screen.dart';
import 'package:y3s1_final/customer/screens/category_products_screen.dart';
import 'package:y3s1_final/customer/screens/detail_product.dart';
import 'package:y3s1_final/customer/screens/search_screen.dart';

import 'package:y3s1_final/models/product_model.dart';
import 'package:y3s1_final/services/app_preferences.dart';

const _navy = Color(0xFF1E1B4B);

// =====================================================
// TRANSLATION HELPER
// =====================================================

String _tr(String english, String khmer) {
  return AppPreferences.instance.translate(english, khmer);
}

// =====================================================
// BANNERS
// =====================================================

final List<String> banner = [
  'https://images.unsplash.com/photo-1511709081634-5f897ff02aa9?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=1200&q=85',
  'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=1200&q=85',
];

// =====================================================
// CUSTOMER HOME SCREEN
// =====================================================

class HomeScreenCustomer extends StatefulWidget {
  const HomeScreenCustomer({super.key});

  @override
  State<HomeScreenCustomer> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenCustomer> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences.instance,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<ProductBloc>();

                bloc.add(LoadProductsEvent());

                await bloc.stream.firstWhere(
                  (state) => !state.isLoading,
                );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: _TopBar(),
                  ),

                  const SliverToBoxAdapter(
                    child: _BannerCard(),
                  ),

                  const SliverToBoxAdapter(
                    child: _CategoryGrid(),
                  ),

                  const SliverToBoxAdapter(
                    child: _NovaAI(),
                  ),

                  SliverToBoxAdapter(
                    child: _SectionTitle(
                      _tr('Products', 'ផលិតផល'),
                    ),
                  ),

                  // Products loaded through ProductBloc.
                  BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state.isLoading &&
                          state.dataStore.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }

                      if (state.error != null &&
                          state.dataStore.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.wifi_off_rounded,
                                  size: 44,
                                  color: colors.onSurfaceVariant,
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  _tr(
                                    'Unable to load products',
                                    'មិនអាចផ្ទុកផលិតផលបានទេ',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  state.error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colors.error,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<ProductBloc>().add(
                                      LoadProductsEvent(),
                                    );
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: Text(
                                    _tr(
                                      'Retry',
                                      'ព្យាយាមម្តងទៀត',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final products = state.filteredProducts;

                      if (products.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              24,
                              28,
                              24,
                              36,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 48,
                                  color: colors.onSurfaceVariant,
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  state.selectedCategory == 'All'
                                      ? _tr(
                                          'No products available yet.',
                                          'មិនទាន់មានផលិតផលនៅឡើយទេ។',
                                        )
                                      : _tr(
                                          'No products in this category yet.',
                                          'មិនទាន់មានផលិតផលក្នុងប្រភេទនេះទេ។',
                                        ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                TextButton.icon(
                                  onPressed: () {
                                    context.read<ProductBloc>().add(
                                      LoadProductsEvent(),
                                    );
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: Text(
                                    _tr(
                                      'Refresh',
                                      'ផ្ទុកឡើងវិញ',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          24,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.68,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _ProductCard(
                                product: products[index],
                              );
                            },
                            childCount: products.length,
                          ),
                        ),
                      );
                    },
                  ),

                  const SliverToBoxAdapter(
                    child: _StoreBenefits(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// =====================================================
// STORE BENEFITS
// =====================================================

class _StoreBenefits extends StatelessWidget {
  const _StoreBenefits();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final benefits = [
      (
        icon: Icons.local_shipping_outlined,
        label: _tr(
          'Free delivery\nover \$100',
          'ដឹកជញ្ជូនឥតគិតថ្លៃ\nលើស \$100',
        ),
      ),
      (
        icon: Icons.verified_user_outlined,
        label: _tr(
          '2-year warranty',
          'ធានារយៈពេល ២ ឆ្នាំ',
        ),
      ),
      (
        icon: Icons.replay_rounded,
        label: _tr(
          '30-day easy\nreturns',
          'ប្តូរទំនិញងាយស្រួល\nក្នុង ៣០ ថ្ងៃ',
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (var index = 0; index < benefits.length; index++) ...[
            if (index > 0) const SizedBox(width: 10),

            Expanded(
              child: Container(
                height: 112,
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: dark
                      ? colors.surfaceContainerHigh
                      : const Color(0xFF1E2557),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: dark
                        ? colors.outlineVariant
                        : const Color(0xFF303656),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      benefits[index].icon,
                      color: dark
                          ? colors.onSurface
                          : Colors.white,
                      size: 27,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      benefits[index].label,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: TextStyle(
                        color: dark
                            ? colors.onSurface
                            : const Color(0xFFF4F3FF),
                        fontSize: AppPreferences.instance.isKhmer
                            ? 10
                            : 11,
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

// =====================================================
// TOP BAR
// =====================================================

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                'https://i.pinimg.com/736x/b5/03/ec/b503ecc77de7a2f3416592c48793305f.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Icon(
                    Icons.storefront_rounded,
                    color: colors.onPrimaryContainer,
                    size: 30,
                  );
                },
              ),
            ),
          ),

          const Flexible(
            child: Text(
              'SmartCommerce',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),

          Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.surfaceContainerHighest,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.search,
                    size: 25,
                    color: colors.onSurface,
                  ),
                ),
              ),

              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductCart(
                            check: true,
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.shopping_cart_outlined,
                      color: colors.onSurface,
                    ),
                  ),

                  Positioned(
                    right: 1,
                    top: 5,
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        final count = state.cartModel.length;

                        if (count == 0) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          height: 20,
                          width: 20,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            count.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onError,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
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

// =====================================================
// BANNER
// =====================================================

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
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 170,
              width: double.infinity,
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
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (
                      context,
                      child,
                      loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return Container(
                        color: colors.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colors.surfaceContainerHighest,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Banner unavailable',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banner.length,
              (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: currentPage == index ? 20 : 9,
                  height: 9,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? colors.primary
                        : colors.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// SECTION TITLE
// =====================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

// =====================================================
// PRODUCT CATEGORIES
// =====================================================

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  static const _categories = <({
    String name,
    String khmer,
    IconData icon,
  })>[
    (
      name: 'Phones',
      khmer: 'ទូរស័ព្ទ',
      icon: Icons.smartphone_rounded,
    ),
    (
      name: 'Laptops',
      khmer: 'កុំព្យូទ័រយួរដៃ',
      icon: Icons.laptop_mac_rounded,
    ),
    (
      name: 'Tablets',
      khmer: 'ថេប្លេត',
      icon: Icons.tablet_mac_rounded,
    ),
    (
      name: 'Audio',
      khmer: 'ឧបករណ៍សំឡេង',
      icon: Icons.headphones_rounded,
    ),
    (
      name: 'Watches',
      khmer: 'នាឡិកា',
      icon: Icons.watch_rounded,
    ),
    (
      name: 'Cameras',
      khmer: 'កាមេរ៉ា',
      icon: Icons.camera_alt_outlined,
    ),
    (
      name: 'Gaming',
      khmer: 'ហ្គេម',
      icon: Icons.gamepad_rounded,
    ),
    (
      name: 'Accessories',
      khmer: 'គ្រឿងបន្ថែម',
      icon: Icons.power_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _categories.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 8,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final category = _categories[index];

          return Semantics(
            button: true,
            label: _tr(category.name, category.khmer),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoryProductsScreen(
                      // Keep original category value for filtering.
                      categoryName: category.name,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: dark
                          ? colors.primaryContainer
                          : const Color(0xFF1E2557),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: dark
                            ? colors.outlineVariant
                            : const Color(0xFF303656),
                      ),
                    ),
                    child: Icon(
                      category.icon,
                      color: dark
                          ? colors.onPrimaryContainer
                          : Colors.white,
                      size: 29,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _tr(category.name, category.khmer),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: AppPreferences.instance.isKhmer
                          ? 9
                          : 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// =====================================================
// PRODUCT CARD
// IMPROVED DARK MODE TEXT READABILITY
// =====================================================

class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({
    required this.product,
  });

  Widget _buildProductImage() {
    final image = product.image.trim();

    if (image.isEmpty) {
      return const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 55,
          color: Colors.grey,
        ),
      );
    }

    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(
              Icons.inventory_2_outlined,
              size: 55,
              color: Colors.grey,
            ),
          );
        },
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const Center(
          child: Icon(
            Icons.inventory_2_outlined,
            size: 55,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final Color priceColor = dark
        ? colors.primary
        : const Color(0xFF3730A3);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: dark ? 0.18 : 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildProductImage(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              10,
              8,
              10,
              10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PRODUCT NAME
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                // PRODUCT RATING AND VIEWS
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Colors.amber,
                    ),

                    const SizedBox(width: 3),

                    // IMPROVED RATING TEXT
                    Text(
                      product.rate,
                      maxLines: 1,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        '${_tr('Views', 'ការមើល')} (${product.view})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // PRODUCT PRICE AND DETAILS BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: priceColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // OPEN PRODUCT DETAILS
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              product: product,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: colors.primary,
                        ),
                        child: Icon(
                          Icons.add,
                          color: colors.onPrimary,
                          size: 21,
                        ),
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

// =====================================================
// NOVA AI
// =====================================================

class _NovaAI extends StatelessWidget {
  const _NovaAI();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: dark
                ? [
                    colors.primaryContainer,
                    colors.surfaceContainerHighest,
                  ]
                : const [
                    Color(0xFF1E1B4B),
                    Color(0xFF4A3AB5),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/chatbot.png',
              height: 50,
              width: 50,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tr(
                      "Can't decide? Ask Nova",
                      'មិនទាន់សម្រេចចិត្ត? សួរ Nova',
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: dark
                          ? colors.onPrimaryContainer
                          : Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _tr(
                      'Compare phones and laptops for your budget.',
                      'ប្រៀបធៀបទូរស័ព្ទ និងកុំព្យូទ័រ '
                          'តាមថវិការបស់អ្នក។',
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: dark
                          ? colors.onPrimaryContainer
                          : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: dark
                    ? colors.surface
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.arrow_forward,
                  color: dark
                      ? colors.onSurface
                      : _navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}