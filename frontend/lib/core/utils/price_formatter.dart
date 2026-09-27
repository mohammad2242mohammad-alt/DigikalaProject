class PriceFormatter {
  static String format(num value) {
    return value.round().toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );
  }
}
