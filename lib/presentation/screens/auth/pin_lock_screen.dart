import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/services/mock_auth_service.dart';
import '../../../core/providers/auth_provider.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCooldownAndLock();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkCooldownAndLock() async {
    final auth = context.read<AuthProvider>();
    if (auth.isAccountLocked) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Akun terblokir. Hubungi Customer Service.';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt('ovo_pin_cooldown_expiry') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (expiry > now) {
      final diff = ((expiry - now) / 1000).ceil();
      _startCooldown(diff);
    }
  }

  void _startCooldown(int seconds) {
    setState(() {
      _cooldownSeconds = seconds;
      _hasError = true;
      _errorMessage = 'PIN salah. Coba lagi dalam $_cooldownSeconds detik.';
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) {
          _cooldownTimer?.cancel();
          _hasError = false;
          _errorMessage = '';
        } else {
          _errorMessage = 'PIN salah. Coba lagi dalam $_cooldownSeconds detik.';
        }
      });
    });
  }

  void _onKeyPressed(String key) {
    if (_isLoading || _cooldownSeconds > 0 || context.read<AuthProvider>().isAccountLocked) return;
    if (key == 'del') {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
          _hasError = false;
        });
      }
      return;
    }
    if (_pin.length >= 6) return;
    setState(() {
      _pin += key;
      _hasError = false;
    });
    if (_pin.length == 6) {
      _submit();
    }
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (auth.isAccountLocked) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Akun terblokir. Hubungi Customer Service.';
        _pin = '';
      });
      return;
    }

    if (_cooldownSeconds > 0) return;

    setState(() => _isLoading = true);
    final valid = await MockAuthService.instance.verifyPin(_pin);
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    if (valid) {
      await prefs.setInt('ovo_pin_attempts', 0);
      Navigator.of(context).pop(true);
    } else {
      int attempts = prefs.getInt('ovo_pin_attempts') ?? 0;
      attempts++;
      await prefs.setInt('ovo_pin_attempts', attempts);

      HapticFeedback.heavyImpact();
      await _shakeController.forward(from: 0);

      if (attempts >= 5) {
        await auth.lockAccount();
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Akun terblokir. Hubungi Customer Service.';
          _pin = '';
        });
      } else if (attempts >= 3) {
        final cooldownExpiry = DateTime.now().add(const Duration(seconds: 30)).millisecondsSinceEpoch;
        await prefs.setInt('ovo_pin_cooldown_expiry', cooldownExpiry);
        setState(() {
          _isLoading = false;
          _pin = '';
        });
        _startCooldown(30);
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'PIN salah. Sisa percobaan: ${5 - attempts}';
          _pin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent physical back press on Android
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                'Aplikasi Terkunci',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan PIN OVO kamu untuk melanjutkan',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final dx = _hasError
                      ? _shakeAnimation.value == 1
                          ? 0.0
                          : ((_shakeAnimation.value * 4).round() % 2 == 0
                              ? 8.0
                              : -8.0) *
                              (1 - _shakeAnimation.value)
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(dx * 8, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) => _buildDot(i)),
                ),
              ),
              if (_hasError) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              _buildNumpad(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final filled = index < _pin.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled
            ? (_hasError ? AppColors.error : AppColors.primary)
            : AppColors.divider,
        border: Border.all(
          color: filled
              ? (_hasError ? AppColors.error : AppColors.primary)
              : AppColors.textHint,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) => _buildKey(key)).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildKey(String key) {
    if (key.isEmpty) {
      return const SizedBox(width: 80, height: 64);
    }
    return SizedBox(
      width: 80,
      height: 64,
      child: InkWell(
        onTap: _isLoading ? null : () => _onKeyPressed(key),
        borderRadius: BorderRadius.circular(40),
        child: Center(
          child: key == 'del'
              ? const Icon(Icons.backspace_outlined,
                  color: AppColors.textPrimary, size: 22)
              : Text(
                  key,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
