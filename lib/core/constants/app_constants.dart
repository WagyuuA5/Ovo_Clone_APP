class AppConstants {
  AppConstants._();

  static const int pinLength = 6;
  static const int otpLength = 6;
  static const String defaultPin = '123456';
  static const String mockOtp = '123456';

  static const Duration transactionDelay = Duration(seconds: 2);
  static const Duration otpDelay = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 800);
  static const Duration balanceAnimationDuration = Duration(milliseconds: 1200);

  static const String appName = 'OVO';
  static const String currencyCode = 'IDR';
  static const String currencySymbol = 'Rp';

  static const int minTransferAmount = 10000;
  static const int maxTransferAmount = 50000000;
  static const int minTopupAmount = 10000;
  static const int maxTopupAmount = 10000000;
}
