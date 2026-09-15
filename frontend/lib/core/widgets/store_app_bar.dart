import 'package:flutter/material.dart';
import '../constants/store_ui_constants.dart';

/// Shared header for every non-home page.
/// Physical positions are explicit so RTL cannot swap the sides.
class StoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StoreAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
      elevation: theme.appBarTheme.elevation ?? 4,
      child: SizedBox(
        width: double.infinity,
        height: kToolbarHeight,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: StoreUi.headerHorizontalPadding,
                ),
                child: Directionality(
                  textDirection: StoreUi.contentDirection,
                  child: const Text(
                    StoreUi.storeName,
                    style: TextStyle(
                      fontSize: StoreUi.headerTitleSize,
                      fontWeight: FontWeight.bold,
                    ),
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
