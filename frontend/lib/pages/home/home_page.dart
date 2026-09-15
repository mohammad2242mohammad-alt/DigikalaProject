import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../account/account_page.dart';
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
          titleSpacing: 12,
          title: Row(
            children: [
              const Text(
                'دیجی‌کالا',
                style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchPage())),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F2F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 10),
                        Text('نام محصول را جستجو کنید'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
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
            IconButton(
              tooltip: 'حساب کاربری',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountPage())),
              icon: const Icon(Icons.account_circle_outlined),
            ),
            PopupMenuButton<String>(
              tooltip: 'دسترسی سریع',
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'admin') {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminPage()));
                } else if (value == 'seller') {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SellerPanelPage()));
                } else if (value == 'orders') {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrdersPage()));
                } else if (value == 'logout') {
                  await ref.read(authProvider.notifier).logout();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem<String>(enabled: false, value: 'user', child: Text(user?.name ?? 'کاربر')),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'orders',
                  child: Row(children: [Icon(Icons.receipt_long_outlined), SizedBox(width: 8), Text('سفارش‌های من')]),
                ),
                const PopupMenuItem<String>(
                  value: 'seller',
                  child: Row(children: [Icon(Icons.storefront_outlined), SizedBox(width: 8), Text('پنل فروشندگی')]),
                ),
                if (user?.isAdmin == true)
                  const PopupMenuItem<String>(
                    value: 'admin',
                    child: Row(children: [Icon(Icons.admin_panel_settings_outlined), SizedBox(width: 8), Text('پنل مدیریت')]),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = (constraints.maxWidth / 240).floor().clamp(2, 5);

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: product.image != null && product.image!.isNotEmpty
                                      ? Image.network(
                                          product.image!,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 48),
                                        )
                                      : const Center(child: Icon(Icons.image_outlined, size: 56)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('⭐ ${product.rating}'),
                                    Flexible(
                                      child: Text(
                                        '${PriceFormatter.format(product.effectivePrice)} تومان',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
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
          },
        ),
      ),
    );
  }
}
