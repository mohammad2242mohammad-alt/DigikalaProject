import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../address/address_page.dart';
import '../admin/admin_page.dart';
import '../favorites/favorites_page.dart';
import '../orders/orders_page.dart';
import '../seller/seller_panel_page.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).asData?.value;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('حساب کاربری'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'بازگشت',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 30, child: Icon(Icons.person_outline, size: 34)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.name ?? 'کاربر', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(user?.email ?? ''),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _AccountTile(icon: Icons.receipt_long_outlined, title: 'سفارش‌های من', subtitle: 'مشاهده سفارش‌ها و وضعیت پرداخت و ارسال', onTap: () => _open(context, const OrdersPage())),
            _AccountTile(icon: Icons.location_on_outlined, title: 'آدرس‌های من', subtitle: 'مدیریت آدرس‌های ارسال', onTap: () => _open(context, const AddressPage())),
            _AccountTile(icon: Icons.favorite_border, title: 'علاقه‌مندی‌ها', subtitle: 'محصولات موردعلاقه شما', onTap: () => _open(context, const FavoritesPage())),
            const Divider(height: 32),
            _AccountTile(icon: Icons.storefront_outlined, title: 'پنل فروشندگی', subtitle: 'مدیریت فروشگاه و سفارش‌های فروشنده', onTap: () => _open(context, const SellerPanelPage())),
            if (user?.isAdmin == true)
              _AccountTile(icon: Icons.admin_panel_settings_outlined, title: 'پنل مدیریت', subtitle: 'مدیریت فروشگاه، محصولات، دسته‌بندی‌ها و سفارش‌ها', onTap: () => _open(context, const AdminPage())),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: () => _logout(context, ref), icon: const Icon(Icons.logout), label: const Text('خروج از حساب')),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
