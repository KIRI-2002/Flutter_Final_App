import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/bloc/product_state.dart';
import 'package:y3s1_final/customer/screens/detail_product.dart';
import 'package:y3s1_final/models/product_model.dart';
import 'package:y3s1_final/services/app_preferences.dart';

// =====================================================
// TRANSLATION HELPERS
// =====================================================

String _tr(String english, String khmer) {
  return AppPreferences.instance.translate(english, khmer);
}

String _translateCategory(String category) {
  switch (category.toLowerCase().trim()) {
    case 'all':
      return _tr('All', 'ទាំងអស់');
    case 'phones':
      return _tr('Phones', 'ទូរស័ព្ទ');
    case 'laptops':
      return _tr('Laptops', 'កុំព្យូទ័រយួរដៃ');
    case 'tablets':
      return _tr('Tablets', 'ថេប្លេត');
    case 'audio':
      return _tr('Audio', 'ឧបករណ៍សំឡេង');
    case 'watches':
      return _tr('Watches', 'នាឡិកា');
    case 'cameras':
      return _tr('Cameras', 'កាមេរ៉ា');
    case 'gaming':
      return _tr('Gaming', 'ហ្គេម');
    case 'accessories':
      return _tr('Accessories', 'គ្រឿងបន្ថែម');
    case 'other':
      return _tr('Other', 'ផ្សេងៗ');
    default:
      return category;
  }
}

// =====================================================
// SEARCH SCREEN
// =====================================================

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String _category = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _query = '';
      _category = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences.instance,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark
              ? theme.scaffoldBackgroundColor
              : const Color(0xFFF8F7FB),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // HEADER
                // ==========================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 20, 18),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: _tr('Back', 'ត្រឡប់ក្រោយ'),
                        onPressed: () {
                          Navigator.maybePop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _tr(
                            'Find your essentials',
                            'ស្វែងរកទំនិញដែលអ្នកត្រូវការ',
                          ),
                          maxLines: 2,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ==========================================
                // SEARCH FIELD
                // ==========================================

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.outlineVariant,
                        width: 1.2,
                      ),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      cursorColor: colors.primary,
                      onChanged: (value) {
                        setState(() {
                          _query = value.trim();
                        });
                      },
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: _tr(
                          'Search products, brands...',
                          'ស្វែងរកផលិតផល ម៉ាក...',
                        ),
                        hintStyle: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colors.primary,
                          size: 25,
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: _tr(
                                  'Clear search',
                                  'លុបការស្វែងរក',
                                ),
                                onPressed: () {
                                  _searchController.clear();

                                  setState(() {
                                    _query = '';
                                  });
                                },
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: colors.onSurface,
                                ),
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 17,
                          horizontal: 8,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ==========================================
                // CATEGORY HEADER
                // ==========================================

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _tr('Categories', 'ប្រភេទផលិតផល'),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _category = 'All';
                          });
                        },
                        child: Text(
                          _tr('Reset', 'កំណត់ឡើងវិញ'),
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // ==========================================
                // CATEGORY FILTERS
                // ==========================================

                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    return SizedBox(
                      height: 46,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.categories.length,
                        separatorBuilder: (_, __) {
                          return const SizedBox(width: 9);
                        },
                        itemBuilder: (context, index) {
                          final category = state.categories[index];
                          final selected = category == _category;

                          return ChoiceChip(
                            label: Text(
                              _translateCategory(category),
                            ),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                // Keep the original category value
                                // for product filtering.
                                _category = category;
                              });
                            },
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              color: selected
                                  ? colors.onPrimary
                                  : colors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            backgroundColor: colors.surface,
                            selectedColor: colors.primary,
                            side: BorderSide(
                              color: selected
                                  ? colors.primary
                                  : colors.outlineVariant,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),

                // ==========================================
                // SEARCH RESULTS
                // ==========================================

                Expanded(
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      final query = _query.toLowerCase();

                      // Products still come from ProductBloc.
                      // Preserve existing Laravel-loaded data.
                      final products = state.dataStore.where((product) {
                        final matchesCategory =
                            _category == 'All' ||
                            product.category == _category;

                        final searchable = [
                          product.name,
                          product.category,
                          product.description,
                        ].join(' ').toLowerCase();

                        return matchesCategory &&
                            searchable.contains(query);
                      }).toList();

                      if (products.isEmpty) {
                        return _EmptySearch(
                          hasQuery: _query.isNotEmpty,
                          onClear: _clearSearch,
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              12,
                            ),
                            child: Text(
                              _query.isEmpty
                                  ? _tr(
                                      'Popular products',
                                      'ផលិតផលពេញនិយម',
                                    )
                                  : _tr(
                                      '${products.length} '
                                          '${products.length == 1 ? 'result' : 'results'} found',
                                      'រកឃើញ ${products.length} ផលិតផល',
                                    ),
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final crossAxisCount =
                                    constraints.maxWidth >= 700 ? 3 : 2;

                                return GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    24,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    mainAxisExtent: 285,
                                  ),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    return _SearchProductCard(
                                      product: products[index],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =====================================================
// SEARCH PRODUCT CARD
// =====================================================

class _SearchProductCard extends StatelessWidget {
  final ProductModel product;

  const _SearchProductCard({
    required this.product,
  });

  Widget _imagePlaceholder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: colors.onSurfaceVariant,
        size: 42,
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final image = product.image.trim();

    if (image.isEmpty) {
      return _imagePlaceholder(context);
    }

    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return Image.network(
        image,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imagePlaceholder(context);
        },
      );
    }

    return Image.asset(
      image,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _imagePlaceholder(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final priceColor = isDark
        ? colors.primary
        : const Color(0xFF3730A3);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // PRODUCT IMAGE
              // ==========================================

              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(context),

                    // Preserve the existing discount badge.
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colors.surfaceContainerHighest
                              : Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '-${product.discount}%',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==========================================
              // PRODUCT INFORMATION
              // ==========================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  11,
                  12,
                  13,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CATEGORY
                    Text(
                      _translateCategory(product.category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // PRODUCT NAME
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // PRICE AND RATING
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: priceColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),

                        const SizedBox(width: 5),

                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB547),
                          size: 18,
                        ),

                        const SizedBox(width: 3),

                        Text(
                          product.rate,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 13,
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
    );
  }
}

// =====================================================
// EMPTY SEARCH RESULTS
// =====================================================

class _EmptySearch extends StatelessWidget {
  final bool hasQuery;
  final VoidCallback onClear;

  const _EmptySearch({
    required this.hasQuery,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: colors.onPrimaryContainer,
                size: 42,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              hasQuery
                  ? _tr(
                      'No products found',
                      'រកមិនឃើញផលិតផល',
                    )
                  : _tr(
                      'Nothing in this category yet',
                      'មិនទាន់មានផលិតផលក្នុងប្រភេទនេះទេ',
                    ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              hasQuery
                  ? _tr(
                      'Try another keyword or browse a different category.',
                      'សាកល្បងពាក្យផ្សេង ឬជ្រើសរើសប្រភេទផ្សេង។',
                    )
                  : _tr(
                      'Choose another category to explore the collection.',
                      'សូមជ្រើសរើសប្រភេទផ្សេងដើម្បីមើលផលិតផល។',
                    ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            if (hasQuery) ...[
              const SizedBox(height: 18),

              FilledButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  _tr(
                    'Clear search',
                    'លុបការស្វែងរក',
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}