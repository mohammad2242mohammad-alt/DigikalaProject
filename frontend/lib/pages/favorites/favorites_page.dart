import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../../models/product_model.dart';
import '../../providers/favorite_provider.dart';
import '../product/product_detail_page.dart';
import '../../core/widgets/store_app_bar.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: const StoreAppBar(title: 'علاقه‌مندی‌های من'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: favorites.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('خطا در دریافت علاقه‌مندی‌ها:\n$error', textAlign: TextAlign.center)),
          data: (products) {
            if (products.isEmpty) return const Center(child: Text('هنوز محصولی به علاقه‌مندی‌ها اضافه نکرده‌اید.'));
            return RefreshIndicator(
              onRefresh: () => ref.refresh(favoritesProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: products.length,
                itemBuilder: (context, index) => _FavoriteCard(product: products[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FavoriteCard extends ConsumerWidget {
  const _FavoriteCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: product.image != null && product.image!.isNotEmpty
            ? Image.network(product.image!, width: 64, height: 64, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported))
            : const Icon(Icons.image_outlined, size: 48),
        title: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.sellerName != null && product.sellerName!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.storefront_outlined, size: 15),
                  const SizedBox(width: 4),
                  Expanded(child: Text('فروشنده: ${product.sellerName}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (product.sellerStatus == 'approved') const Icon(Icons.verified, size: 15),
                ],
              ),
            Text('${PriceFormatter.format(product.effectivePrice)} تومان'),
          ],
        ),
        trailing: IconButton(
          tooltip: 'حذف از علاقه‌مندی‌ها',
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () async => ref.read(favoritesProvider.notifier).remove(product.id),
        ),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
      ),
    );
  }
}
