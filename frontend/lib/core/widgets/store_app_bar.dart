import 'package:flutter/material.dart';
import '../constants/store_ui_constants.dart';

/// Shared header for every non-home page.
/// All visual values are centralized in StoreUi.
class StoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StoreAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: SizedBox(
        width: double.infinity,
        height: kToolbarHeight,
        child: Stack(
          textDirection: StoreUi.headerDirection,
          children: [
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: Row(
                textDirection: StoreUi.headerDirection,
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
            PositionedDirectional(
              end: StoreUi.headerHorizontalPadding,
              top: 0,
              bottom: 0,
              child: Center(
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
