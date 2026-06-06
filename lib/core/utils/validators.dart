import '../../core/constants/app_constants.dart';

class Validators {
  Validators._();

  // ---------------------------------------------------------------------------
  // Phone
  // ---------------------------------------------------------------------------

  /// Returns an error message string or null if the phone number is valid.
  /// Valid: 10–13 digits, optionally starting with '+62' or '0'.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 13) {
      return 'Nomor telepon harus 10–13 digit';
    }
    if (!RegExp(r'^(08|628|\+628)').hasMatch(value.trim())) {
      return 'Nomor telepon harus diawali 08 atau +628';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // PIN
  // ---------------------------------------------------------------------------

  /// Returns an error message or null if the PIN is exactly 6 digits.
  static String? validatePin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN tidak boleh kosong';
    }
    if (value.length != AppConstants.pinLength) {
      return 'PIN harus ${AppConstants.pinLength} digit';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'PIN hanya boleh berisi angka';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Amount
  // ---------------------------------------------------------------------------

  /// Returns an error message or null.
  /// Validates that [value] (as a numeric string) is within [10.000, balance].
  static String? validateAmount(String? value, int balance) {
    if (value == null || value.trim().isEmpty) {
      return 'Jumlah tidak boleh kosong';
    }
    final String cleaned = value.replaceAll(RegExp(r'\D'), '');
    final int? amount = int.tryParse(cleaned);
    if (amount == null) {
      return 'Jumlah tidak valid';
    }
    if (amount < AppConstants.minTransferAmount) {
      return 'Jumlah minimal Rp 10.000';
    }
    if (amount > balance) {
      return 'Saldo tidak mencukupi';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Name
  // ---------------------------------------------------------------------------

  /// Returns an error message or null.
  /// Valid: at least 2 non-whitespace characters.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Email
  // ---------------------------------------------------------------------------

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Bool helpers
  // ---------------------------------------------------------------------------

  static bool isValidPhone(String phone) => validatePhone(phone) == null;

  static bool isValidPin(String pin) => validatePin(pin) == null;
}
