import 'package:flutter/material.dart';
import '../constants/store_ui_constants.dart';

/// Centralized top bar for all non-home pages.
/// Header direction, store name, icons and sizes are defined in StoreUi.
class StoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StoreAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Directionality(
        textDirection: StoreUi.headerDirection,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(StoreUi.backIcon),
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: 'بازگشت',
            ),
            Directionality(
              textDirection: StoreUi.contentDirection,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: StoreUi.headerTitleSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            if (actions != null) ...actions!,
            Directionality(
              textDirection: StoreUi.contentDirection,
              child: const Padding(
                padding: EdgeInsetsDirectional.only(
                  end: StoreUi.headerHorizontalPadding,
                ),
                child: Text(
                  StoreUi.storeName,
                  style: TextStyle(
                    fontSize: StoreUi.headerTitleSize,
                    fontWeight: FontWeight.bold,
                  ),
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
