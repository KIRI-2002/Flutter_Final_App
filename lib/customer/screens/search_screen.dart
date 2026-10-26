import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/bloc/product_state.dart';
import 'package:y3s1_final/customer/screens/detail_product.dart';
import 'package:y3s1_final/models/product_model.dart';

const _ink = Color(0xFF201B3D);
const _accent = Color(0xFF7C83FD);
const _canvas = Color(0xFFF8F7FB);

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 18),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    color: _ink,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Find your essentials',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _ink.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value.trim()),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search products, brands...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: const Icon(Icons.search_rounded, color: _accent),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 17),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _category = 'All'),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) => SizedBox(
                height: 42,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    final selected = category == _category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = category),
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : _ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: _ink,
                      side: BorderSide(
                        color: selected ? _ink : const Color(0xFFEAE8F0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  final query = _query.toLowerCase();
                  final products = state.dataStore.where((product) {
                    final matchesCategory =
                        _category == 'All' || product.category == _category;
                    final searchable =
                        '${product.name} ${product.category} ${product.description}'
                            .toLowerCase();
                    return matchesCategory && searchable.contains(query);
                  }).toList();

                  if (products.isEmpty) {
                    return _EmptySearch(
                      hasQuery: _query.isNotEmpty,
                      onClear: () {
                        _searchController.clear();
                        setState(() {
                          _query = '';
                          _category = 'All';
                        });
                      },
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Text(
                          _query.isEmpty
                              ? 'Popular products'
                              : '${products.length} ${products.length == 1 ? 'result' : 'results'} found',
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.69,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) =>
                              _SearchProductCard(product: products[index]),
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
  }
}

class _SearchProductCard extends StatelessWidget {
  const _SearchProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF0EFF5),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_outlined, size: 38),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '-${product.discount}%',
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      letterSpacing: 0.8,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFB547), size: 15),
                      const SizedBox(width: 2),
                      Text(product.rate,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.hasQuery, required this.onClear});

  final bool hasQuery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFEDEBFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: _accent, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              hasQuery ? 'No products found' : 'Nothing in this category yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              hasQuery
                  ? 'Try another keyword or browse a different category.'
                  : 'Choose another category to explore the collection.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
            if (hasQuery) ...[
              const SizedBox(height: 14),
              TextButton(onPressed: onClear, child: const Text('Clear search')),
            ],
          ],
        ),
      ),
    );
  }
}
