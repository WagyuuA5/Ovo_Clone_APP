extension StringExt on String {
  /// Returns the initials of each word (up to 2 words).
  /// Example: 'Budi Santoso' → 'BS', 'Budi' → 'B'
  String get toInitials {
    final List<String> words =
        trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  /// Masks the middle portion of a phone number.
  /// Example: '081234567890' → '0812****7890'
  String get maskedPhone {
    if (length < 8) return this;
    final String start = substring(0, 4);
    final String end = substring(length - 4);
    return '$start****$end';
  }

  /// Capitalizes the first letter of the string.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Returns true if the string is a valid Indonesian phone number.
  bool get isValidPhone {
    final String digits = replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 &&
        digits.length <= 13 &&
        RegExp(r'^(08|628|\+628)').hasMatch(trim());
  }

  /// Returns true if the string matches a valid e-mail pattern.
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(trim());
  }

  /// Strips every character that is not a digit (0-9).
  String get removeNonDigits => replaceAll(RegExp(r'\D'), '');
}
