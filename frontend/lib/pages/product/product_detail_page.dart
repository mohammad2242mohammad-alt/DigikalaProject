import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/product_provider.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _quantity = 1;

  Future<void> _addToCart(Product product) async {
    if (product.stock <= 0) return;
    final quantity = _quantity.clamp(1, product.stock);
    try {
      await ref.read(cartProvider.notifier).addItem(productId: product.id, quantity: quantity);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('محصول به سبد خرید اضافه شد')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('افزودن محصول به سبد خرید ناموفق بود')));
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    final current = ref.read(favoritesProvider).asData?.value ?? const <Product>[];
    final isFavorite = current.any((item) => item.id == product.id);
    try {
      if (isFavorite) {
        await ref.read(favoritesProvider.notifier).remove(product.id);
      } else {
        await ref.read(favoritesProvider.notifier).add(product.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isFavorite ? 'از علاقه‌مندی‌ها حذف شد' : 'به علاقه‌مندی‌ها اضافه شد')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تغییر علاقه‌مندی ناموفق بود')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.product.id));
    final favoriteProducts = ref.watch(favoritesProvider).asData?.value ?? const <Product>[];
    final isFavorite = favoriteProducts.any((item) => item.id == widget.product.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات محصول'),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'حذف از علاقه‌مندی‌ها' : 'افزودن به علاقه‌مندی‌ها',
            onPressed: () => _toggleFavorite(widget.product),
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : null),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: productAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('خطا در دریافت محصول:\n$error', textAlign: TextAlign.center))),
          data: (product) {
            final hasDiscount = product.discountPrice != null && product.discountPrice! < product.price;
            final discountPercent = hasDiscount ? ((product.price - product.discountPrice!) / product.price * 100).round() : 0;
            final canBuy = product.isActive && product.stock > 0;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 280,
                      child: product.image != null && product.image!.isNotEmpty
                          ? Image.network(product.image!, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported_outlined, size: 72)))
                          : const Center(child: Icon(Icons.image_outlined, size: 72)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4)),
                const SizedBox(height: 10),
                Row(children: [const Icon(Icons.star, size: 20, color: Colors.amber), const SizedBox(width: 4), Text('${product.rating}'), const SizedBox(width: 16), const Icon(Icons.visibility_outlined, size: 19), const SizedBox(width: 4), Text('${product.views} بازدید')]),
                if (product.sellerName != null && product.sellerName!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.store_outlined)),
                      title: const Text('فروشنده', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(product.sellerName!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                      trailing: product.sellerStatus == 'approved'
                          ? const Icon(Icons.verified, color: Colors.green)
                          : null,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (hasDiscount) ...[
                        Row(children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text('$discountPercent٪ تخفیف', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 10),
                          Text('${PriceFormatter.format(product.price)} تومان', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                        ]),
                        const SizedBox(height: 8),
                      ],
                      Text('${PriceFormatter.format(product.effectivePrice)} تومان', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(children: [Icon(product.stock > 0 ? Icons.check_circle_outline : Icons.cancel_outlined, size: 20, color: product.stock > 0 ? Colors.green : Colors.red), const SizedBox(width: 6), Text(product.stock > 0 ? 'موجودی: ${product.stock} عدد' : 'ناموجود', style: TextStyle(color: product.stock > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.w600))]),
                    ]),
                  ),
                ),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('توضیحات محصول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(product.description, style: const TextStyle(fontSize: 16, height: 1.8)),
                ],
                const SizedBox(height: 24),
                if (canBuy)
                  Row(children: [
                    Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)), child: Row(textDirection: TextDirection.ltr, children: [IconButton(onPressed: _quantity < product.stock ? () => setState(() => _quantity++) : null, icon: const Icon(Icons.add)), Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove))])),
                    const SizedBox(width: 12),
                    Expanded(child: FilledButton.icon(onPressed: () => _addToCart(product), icon: const Icon(Icons.add_shopping_cart), label: const Text('افزودن به سبد خرید'))),
                  ])
                else
                  Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('این محصول در حال حاضر قابل خرید نیست'))),
              ],
            );
          },
        ),
      ),
    );
  }
}
