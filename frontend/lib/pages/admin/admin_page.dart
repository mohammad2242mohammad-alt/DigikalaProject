import 'package:flutter/material.dart';

import '../../core/widgets/store_app_bar.dart';
import 'admin_categories_page.dart';
import 'admin_orders_page.dart';
import 'admin_products_page.dart';
import 'admin_sellers_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const StoreAppBar(title: 'مدیریت فروشگاه'),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AdminTile(icon: Icons.storefront_outlined, title: 'مدیریت فروشندگان', subtitle: 'بررسی، تأیید، رد و تعلیق فروشندگان', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminSellersPage()))),
            _AdminTile(icon: Icons.inventory_2_outlined, title: 'مدیریت محصولات', subtitle: 'افزودن، ویرایش، حذف و فعال/غیرفعال‌سازی', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminProductsPage()))),
            _AdminTile(icon: Icons.category_outlined, title: 'مدیریت دسته‌بندی‌ها', subtitle: 'افزودن، ویرایش و حذف دسته‌ها', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminCategoriesPage()))),
            _AdminTile(icon: Icons.receipt_long_outlined, title: 'مدیریت سفارش‌ها', subtitle: 'مشاهده سفارش‌ها و تغییر وضعیت', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminOrdersPage()))),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(contentPadding: const EdgeInsets.all(16), leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_left), onTap: onTap));
}
