class AppRoutes {
  AppRoutes._();

  // ---------------------------------------------------------------------------
  // Auth flow
  // ---------------------------------------------------------------------------
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String pinSetup = '/pin-setup';

  // ---------------------------------------------------------------------------
  // Main
  // ---------------------------------------------------------------------------
  static const String home = '/home';

  // ---------------------------------------------------------------------------
  // Transfer
  // ---------------------------------------------------------------------------
  static const String transfer = '/transfer';
  static const String transferConfirm = '/transfer/confirm';
  static const String transferSuccess = '/transfer/success';

  // ---------------------------------------------------------------------------
  // Top-up
  // ---------------------------------------------------------------------------
  static const String topup = '/topup';
  static const String topupConfirm = '/topup/confirm';

  // ---------------------------------------------------------------------------
  // Payment
  // ---------------------------------------------------------------------------
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment/success';

  // ---------------------------------------------------------------------------
  // Withdraw
  // ---------------------------------------------------------------------------
  static const String withdraw = '/withdraw';

  // ---------------------------------------------------------------------------
  // History
  // ---------------------------------------------------------------------------
  static const String history = '/history';
  static const String transactionDetail = '/history/detail';

  // ---------------------------------------------------------------------------
  // Services
  // ---------------------------------------------------------------------------
  static const String pulsa = '/pulsa';
  static const String pln = '/pln';

  // ---------------------------------------------------------------------------
  // Inbox
  // ---------------------------------------------------------------------------
  static const String inbox = '/inbox';

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String security = '/profile/security';
}
