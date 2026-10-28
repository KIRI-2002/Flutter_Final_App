import 'package:flutter/material.dart';
import 'package:y3s1_final/customer/screens/detail_product.dart';
import 'package:y3s1_final/data/data_store.dart';
import 'package:y3s1_final/util/app_text.dart';

class FavoriteScreenCustomer extends StatefulWidget {
  const FavoriteScreenCustomer({super.key});

  @override
  State<FavoriteScreenCustomer> createState() => _FavoriteScreenCustomerState();
}

class _FavoriteScreenCustomerState extends State<FavoriteScreenCustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(248, 255, 247, 247),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(248, 255, 247, 247),
        title: const AppText(text: "Favorite"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Set<int>>(
        valueListenable: favoriteCodes,
        builder: (context, favorites, _) {
          final items =
              DataStore().products
                  .where((p) => favorites.contains(p.code))
                  .toList();
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  AppText(text: "No favorites yet"),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = items[index];
              final price = p.oldprice - (p.oldprice * p.discount / 100);

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: p),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            p.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Icon(Icons.image_not_supported),
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.category,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    "\$${price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "\$${p.oldprice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () => toggleFavorite(p.code),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
