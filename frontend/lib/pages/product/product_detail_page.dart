import 'package:flutter/material.dart';

import '../../core/utils/price_formatter.dart';
import '../../models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جزئیات محصول')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (product.image != null && product.image!.isNotEmpty)
              SizedBox(
                height: 260,
                child: Image.network(
                  product.image!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.image_not_supported, size: 80),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              product.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(product.description),
            const SizedBox(height: 16),
            Text(
              '${PriceFormatter.format(product.effectivePrice)} تومان',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(product.stock > 0 ? 'موجودی: ${product.stock}' : 'ناموجود'),
            const SizedBox(height: 8),
            Text('امتیاز: ${product.rating}'),
          ],
        ),
      ),
    );
  }
}
