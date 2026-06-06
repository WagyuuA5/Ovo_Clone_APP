// OVO Clone Main Application
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/themes/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/balance_provider.dart';
import 'core/providers/transaction_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/chat_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/otp_screen.dart';
import 'presentation/screens/auth/pin_setup_screen.dart';
import 'presentation/screens/auth/pin_lock_screen.dart';
import 'presentation/screens/chat/chat_detail_screen.dart';
import 'presentation/screens/main_navigation/main_navigation_screen.dart';
import 'presentation/screens/transfer/transfer_screen.dart';
import 'presentation/screens/transfer/transfer_confirm_screen.dart';
import 'presentation/screens/transfer/transfer_success_screen.dart';
import 'presentation/screens/topup/topup_screen.dart';
import 'presentation/screens/topup/topup_confirm_screen.dart';
import 'presentation/screens/topup/withdraw_screen.dart';
import 'presentation/screens/payment/payment_screen.dart';
import 'presentation/screens/payment/payment_success_screen.dart';
import 'presentation/screens/payment/pln_screen.dart';
import 'presentation/screens/payment/pulsa_screen.dart';
import 'presentation/screens/inbox/inbox_screen.dart';
import 'presentation/screens/history/history_screen.dart';
import 'presentation/screens/history/transaction_detail_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/profile/edit_profile_screen.dart';
import 'presentation/screens/profile/security_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  runApp(const OvoApp());
}

class OvoApp extends StatefulWidget {
  const OvoApp({super.key});

  @override
  State<OvoApp> createState() => _OvoAppState();
}

class _OvoAppState extends State<OvoApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final prefs = await SharedPreferences.getInstance();
    if (state == AppLifecycleState.paused) {
      await prefs.setInt('ovo_background_time', DateTime.now().millisecondsSinceEpoch);
    } else if (state == AppLifecycleState.resumed) {
      final bgTime = prefs.getInt('ovo_background_time') ?? 0;
      if (bgTime > 0) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsedSeconds = (now - bgTime) / 1000;
        if (elapsedSeconds > 300) {
          final context = _navigatorKey.currentContext;
          if (context == null || !mounted) return;
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.isAuthenticated) {
            _navigatorKey.currentState?.pushNamed('/pin-lock');
          }
        }
      }
      await prefs.setInt('ovo_background_time', 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => BalanceProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'OVO',
            navigatorKey: _navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              final args = settings.arguments;
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
                case '/onboarding':
                  return MaterialPageRoute(builder: (_) => const OnboardingScreen());
                case '/login':
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case '/otp':
                  return MaterialPageRoute(
                    builder: (_) => OtpScreen(phone: args as String? ?? ''),
                  );
                case '/pin-setup':
                  return MaterialPageRoute(
                    builder: (_) => PinSetupScreen(phone: args as String? ?? ''),
                  );
                case '/pin-lock':
                  return MaterialPageRoute(
                    builder: (_) => const PinLockScreen(),
                  );
                case '/home':
                  return MaterialPageRoute(
                    builder: (_) => const MainNavigationScreen(),
                  );
                case '/transfer':
                  return MaterialPageRoute(builder: (_) => const TransferScreen());
                case '/transfer/confirm':
                  return MaterialPageRoute(
                    builder: (_) => const TransferConfirmScreen(),
                  );
                case '/transfer/success':
                  return MaterialPageRoute(
                    builder: (_) => const TransferSuccessScreen(),
                  );
                case '/topup':
                  return MaterialPageRoute(builder: (_) => const TopUpScreen());
                case '/topup/confirm':
                  return MaterialPageRoute(
                    builder: (_) => const TopUpConfirmScreen(),
                  );
                case '/withdraw':
                  return MaterialPageRoute(builder: (_) => const WithdrawScreen());
                case '/payment':
                  return MaterialPageRoute(builder: (_) => const PaymentScreen());
                case '/payment/success':
                  return MaterialPageRoute(
                    builder: (_) => PaymentSuccessScreen(
                      args: args as Map<String, dynamic>? ?? {},
                    ),
                  );
                case '/chat':
                  return MaterialPageRoute(builder: (_) => const ChatDetailScreen());
                case '/pln':
                  return MaterialPageRoute(builder: (_) => const PlnScreen());
                case '/pulsa':
                  return MaterialPageRoute(builder: (_) => const PulsaScreen());
                case '/history':
                  return MaterialPageRoute(builder: (_) => const HistoryScreen());
                case '/history/detail':
                  return MaterialPageRoute(
                    builder: (_) => TransactionDetailScreen(
                      transaction: args as dynamic,
                    ),
                  );
                case '/inbox':
                  return MaterialPageRoute(builder: (_) => const InboxScreen());
                case '/profile':
                  return MaterialPageRoute(builder: (_) => const ProfileScreen());
                case '/profile/edit':
                  return MaterialPageRoute(builder: (_) => const EditProfileScreen());
                case '/profile/security':
                  return MaterialPageRoute(builder: (_) => const SecurityScreen());
                default:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
              }
            },
          );
        },
      ),
    );
  }
}
