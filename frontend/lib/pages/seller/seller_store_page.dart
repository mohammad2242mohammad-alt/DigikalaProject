import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../../core/widgets/store_app_bar.dart';
import '../../models/product_model.dart';
import '../../providers/seller_store_provider.dart';
import '../product/product_detail_page.dart';

class SellerStorePage extends ConsumerWidget {
  const SellerStorePage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(sellerStoreProvider(slug));

    return Scaffold(
      appBar: const StoreAppBar(title: 'فروشگاه فروشنده'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: storeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'خطا در دریافت فروشگاه:\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (storeData) {
            final seller = storeData.seller;
            final products = storeData.products;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: seller.logo != null && seller.logo!.isNotEmpty
                                  ? NetworkImage(seller.logo!)
                                  : null,
                              child: seller.logo == null || seller.logo!.isEmpty
                                  ? const Icon(Icons.store_outlined, size: 32)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          seller.storeName,
                                          style: const TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (seller.status == 'approved')
                                        const Icon(Icons.verified, color: Colors.green),
                                    ],
                                  ),
                                  if (seller.description.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      seller.description,
                                      style: const TextStyle(height: 1.6),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text('${products.length} محصول'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: products.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: Text('این فروشگاه محصولی ندارد')),
                          ),
                        )
                      : SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _SellerProductCard(product: products[index]),
                            childCount: products.length,
                          ),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 260,
                            mainAxisExtent: 330,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SellerProductCard extends StatelessWidget {
  const _SellerProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final image = product.image;
    final price = product.effectivePrice;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: image != null && image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, size: 56),
                        )
                      : const Icon(Icons.image_outlined, size: 56),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                '${PriceFormatter.format(price)} تومان',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
