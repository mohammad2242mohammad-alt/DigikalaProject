import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../admin/admin_page.dart';
import '../cart/cart_page.dart';
import '../category/categories_page.dart';
import '../checkout/checkout_page.dart';
import '../orders/orders_page.dart';
import '../product/product_detail_page.dart';
import '../search/search_page.dart';
import '../seller/seller_panel_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final cartAsync = ref.watch(cartProvider);
    final cartCount = cartAsync.asData?.value.itemsCount ?? 0;
    final user = ref.watch(authProvider).asData?.value;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'دیجی‌کالا',
            style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              tooltip: 'جستجو',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchPage())),
              icon: const Icon(Icons.search),
            ),
            IconButton(
              tooltip: 'دسته‌بندی‌ها',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesPage())),
              icon: const Icon(Icons.category_outlined),
            ),
            IconButton(
              tooltip: 'سفارش‌ها',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrdersPage())),
              icon: const Icon(Icons.receipt_long),
            ),
            Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: IconButton(
                tooltip: 'سبد خرید',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartPage())),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
            IconButton(
              tooltip: 'تکمیل سفارش',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckoutPage())),
              icon: const Icon(Icons.shopping_cart_checkout),
            ),
            PopupMenuButton<String>(
              tooltip: 'حساب کاربری',
              icon: const Icon(Icons.account_circle_outlined),
              onSelected: (value) async {
                if (value == 'admin') {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminPage()));
                } else if (value == 'seller') {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SellerPanelPage()));
                } else if (value == 'logout') {
                  await ref.read(authProvider.notifier).logout();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem<String>(enabled: false, value: 'user', child: Text(user?.name ?? 'کاربر')),
                if (user?.isAdmin == true) ...[
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'admin',
                    child: Row(children: [Icon(Icons.admin_panel_settings_outlined), SizedBox(width: 8), Text('پنل مدیریت')]),
                  ),
                ],
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'seller',
                  child: Row(children: [Icon(Icons.storefront_outlined), SizedBox(width: 8), Text('پنل فروشندگی')]),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(value: 'logout', child: Text('خروج از حساب')),
              ],
            ),
          ],
        ),
        body: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('خطا در دریافت اطلاعات:\n$error', textAlign: TextAlign.center),
            ),
          ),
          data: (products) {
            if (products.isEmpty) return const Center(child: Text('محصولی وجود ندارد', style: TextStyle(fontSize: 20)));
            return RefreshIndicator(
              onRefresh: () => ref.refresh(productsProvider.future),
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      leading: product.image != null && product.image!.isNotEmpty
                          ? Image.network(product.image!, width: 64, height: 64, fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported))
                          : const Icon(Icons.image_outlined, size: 48),
                      title: Text(product.name),
                      subtitle: Text('${PriceFormatter.format(product.effectivePrice)} تومان'),
                      trailing: Text('⭐ ${product.rating}'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
