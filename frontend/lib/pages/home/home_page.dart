import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../account/account_page.dart';
import '../admin/admin_page.dart';
import '../cart/cart_page.dart';
import '../category/categories_page.dart';
import '../orders/orders_page.dart';
import '../product/product_detail_page.dart';
import '../search/search_page.dart';
import '../seller/seller_panel_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cartAsync = ref.watch(cartProvider);
    final cartCount = cartAsync.asData?.value.itemsCount ?? 0;
    final user = ref.watch(authProvider).asData?.value;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F8),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(76),
          child: Material(
            color: Colors.white,
            elevation: 1,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text(
                        'دیجی‌کالا',
                        style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchPage())),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F3F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search, color: Colors.black54),
                              SizedBox(width: 10),
                              Text('نام محصول را جستجو کنید', style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'دسته‌بندی‌ها',
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesPage())),
                      icon: const Icon(Icons.category_outlined),
                    ),
                    IconButton(
                      tooltip: 'سفارش‌ها',
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrdersPage())),
                      icon: const Icon(Icons.receipt_long_outlined),
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
              ),
            ),
          ),
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

            final categories = categoriesAsync.asData?.value ?? const <CategoryModel>[];
            final popularCategories = categories.take(6).toList();

            return RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  ref.refresh(productsProvider.future),
                  ref.refresh(categoriesProvider.future),
                ]);
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF394E), Color(0xFFB71C3A)],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('خریدی ساده‌تر و سریع‌تر', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  Text('محصولات موردنیازت را پیدا کن و با خیال راحت سفارش بده.', style: TextStyle(color: Colors.white70, fontSize: 15)),
                                ],
                              ),
                            ),
                            const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 72),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (popularCategories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('دسته‌بندی‌های محبوب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 112,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: popularCategories.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 10),
                                itemBuilder: (context, index) => _HomeCategoryCard(
                                  category: popularCategories[index],
                                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesPage())),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('محصولات فروشگاه', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchPage())),
                            child: const Text('مشاهده همه'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final columns = width >= 1200 ? 5 : width >= 900 ? 4 : width >= 600 ? 3 : 2;
                        return SliverGrid.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
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
                                      Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('⭐ ${product.rating}'),
                                          Flexible(
                                            child: Text('${PriceFormatter.format(product.effectivePrice)} تومان', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeCategoryCard extends StatelessWidget {
  const _HomeCategoryCard({required this.category, required this.onTap});

  final CategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text(category.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
