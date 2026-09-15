import 'package:flutter/material.dart';

/// Shared UI values for the store pages.
/// Change these values here instead of editing individual pages.
class StoreUi {
  StoreUi._();

  static const String storeName = 'دیجی‌کالا';

  // Physical header layout: back button/title on the left, store name on the right.
  static const TextDirection headerDirection = TextDirection.ltr;
  static const TextDirection contentDirection = TextDirection.rtl;

  static const IconData backIcon = Icons.arrow_back;
  static const IconData expandIcon = Icons.keyboard_arrow_down;
  static const IconData collapseIcon = Icons.keyboard_arrow_up;
  static const IconData childIcon = Icons.chevron_left;
  static const IconData allProductsIcon = Icons.apps_outlined;

  static const double headerTitleSize = 20;
  static const double headerHorizontalPadding = 16;
  static const double categoryIconSize = 26;
  static const double categoryHorizontalPadding = 16;
  static const double categoryVerticalPadding = 14;
  static const double categorySpacing = 12;
}
