import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/product_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'دیجی‌کالا',
          style: TextStyle(
            color: Colors.red,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'خطا در دریافت اطلاعات:\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text('محصولی وجود ندارد', style: TextStyle(fontSize: 20)),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(productsProvider.future),
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text('${product.effectivePrice} تومان'),
                    trailing: Text('⭐ ${product.rating}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
