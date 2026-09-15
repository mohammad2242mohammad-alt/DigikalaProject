import 'package:flutter/material.dart';

/// Centralized top bar for all non-home pages.
/// Change [storeName] here once to rename the store everywhere.
class StoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StoreAppBar({super.key, required this.title, this.storeName = 'دیجی‌کالا'});

  final String title;
  final String storeName;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: 'بازگشت',
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            const Spacer(),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: Text(
                  storeName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
