import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.decimalPattern('id');

  /// Formats an integer amount to Indonesian Rupiah string.
  /// Example: 850000 → 'Rp 850.000'
  static String format(int amount) {
    return 'Rp ${_formatter.format(amount)}';
  }

  /// Formats large amounts in compact form.
  /// Example: 850000 → 'Rp 850rb', 1500000 → 'Rp 1,5jt'
  static String formatCompact(int amount) {
    if (amount >= 1000000000) {
      final double value = amount / 1000000000;
      final String str =
          value == value.truncateToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
      return 'Rp ${str}M';
    } else if (amount >= 1000000) {
      final double value = amount / 1000000;
      final String str =
          value == value.truncateToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
      return 'Rp ${str}jt';
    } else if (amount >= 1000) {
      final double value = amount / 1000;
      final String str =
          value == value.truncateToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
      return 'Rp ${str}rb';
    }
    return format(amount);
  }

  /// Parses a formatted Rupiah string back to an integer.
  /// Example: 'Rp 850.000' → 850000
  static int parse(String formatted) {
    // Remove currency symbol, spaces, and dots used as thousand separators
    final String cleaned = formatted
        .replaceAll('Rp', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    return int.tryParse(cleaned) ?? 0;
  }

  /// Formats an integer to OVO Points display string.
  /// Example: 1250 → '1.250 Points'
  static String formatPoints(int points) {
    return '${_formatter.format(points)} Points';
  }
}
