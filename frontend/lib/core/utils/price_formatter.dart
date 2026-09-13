class PriceFormatter {
  const PriceFormatter._();

  static String format(num value) {
    final text = value % 1 == 0 ? value.toInt().toString() : value.toString();
    final parts = text.split('.');
    final integerPart = parts.first;
    final sign = integerPart.startsWith('-') ? '-' : '';
    final digits = sign.isEmpty ? integerPart : integerPart.substring(1);

    final buffer = StringBuffer(sign);
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }

    if (parts.length > 1) {
      buffer
        ..write('.')
        ..write(parts[1]);
    }

    return buffer.toString();
  }
}
