import '../utils/currency_formatter.dart';

extension NumExt on num {
  /// Formats the number as an Indonesian Rupiah string.
  /// Example: 850000 → 'Rp 850.000'
  String get toRupiah => CurrencyFormatter.format(toInt());

  /// Formats the number as OVO Points string.
  /// Example: 1250 → '1.250 Points'
  String get toPoints => CurrencyFormatter.formatPoints(toInt());
}

extension IntExt on int {
  /// Formats the integer as an Indonesian Rupiah string.
  /// Example: 850000 → 'Rp 850.000'
  String get toRupiah => CurrencyFormatter.format(this);

  /// Formats the integer as OVO Points string.
  /// Example: 1250 → '1.250 Points'
  String get toPoints => CurrencyFormatter.formatPoints(this);

  /// Returns true if this value is a positive balance (greater than zero).
  bool get isValidBalance => this > 0;
}
