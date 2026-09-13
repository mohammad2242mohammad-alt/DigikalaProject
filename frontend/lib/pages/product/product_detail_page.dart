import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  late Future<Product> _productFuture;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _productFuture = _loadProduct();
  }

  Future<Product> _loadProduct() async {
    final response = await ref.read(apiClientProvider).get('/products/${widget.product.id}');
    if (response is! Map<String, dynamic> || response['data'] is! Map<String, dynamic>) {
      throw const FormatException('Invalid product response');
    }
    return Product.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> _addToCart(Product product) async {
    if (product.stock <= 0) return;

    final quantity = _quantity.clamp(1, product.stock);
    try {
      await ref.read(cartProvider.notifier).addItem(
            productId: product.id,
            quantity: quantity,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('محصول به سبد خرید اضافه شد')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('افزودن محصول به سبد خرید ناموفق بود')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جزئیات محصول')),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'خطا در دریافت محصول:\n${snapshot.error ?? 'اطلاعاتی دریافت نشد'}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final product = snapshot.data!;
          final hasDiscount = product.discountPrice != null &&
              product.discountPrice! < product.price;
          final canBuy = product.isActive && product.stock > 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (product.image != null && product.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    product.image!,
                    height: 280,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 280,
                      child: Icon(Icons.image_not_supported_outlined, size: 72),
                    ),
                  ),
                )
              else
                const SizedBox(
                  height: 280,
                  child: Icon(Icons.image_outlined, size: 72),
                ),
              const SizedBox(height: 20),
              Text(
                product.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star, size: 20, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('${product.rating}'),
                  const SizedBox(width: 16),
                  Text('بازدید: ${product.views}'),
                ],
              ),
              const SizedBox(height: 20),
              if (hasDiscount)
                Text(
                  '${product.price.toStringAsFixed(0)} تومان',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
              Text(
                '${product.effectivePrice.toStringAsFixed(0)} تومان',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                product.stock > 0 ? 'موجودی: ${product.stock}' : 'ناموجود',
                style: TextStyle(
                  color: product.stock > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              if (product.description.isNotEmpty) ...[
                const Text('توضیحات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(product.description, style: const TextStyle(fontSize: 16, height: 1.7)),
                const SizedBox(height: 24),
              ],
              if (canBuy)
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _quantity < product.stock
                                ? () => setState(() => _quantity++)
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                          Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _addToCart(product),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('افزودن به سبد خرید'),
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(
                  height: 48,
                  child: Center(child: Text('این محصول در حال حاضر قابل خرید نیست')),
                ),
            ],
          );
        },
      ),
    );
  }
}
