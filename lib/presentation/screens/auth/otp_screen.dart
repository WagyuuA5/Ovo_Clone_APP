import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/mock_auth_service.dart';
import '../../widgets/common/ovo_button.dart';

class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  static const int _otpLength = 6;
  static const int _countdownSeconds = 60;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  int _secondsLeft = _countdownSeconds;
  Timer? _countdownTimer;
  bool _canResend = false;

  String get _otp =>
      _controllers.map((c) => c.text).join();

  bool get _isOtpComplete => _otp.length == _otpLength;

  @override
  void initState() {
    super.initState();
    _setupShakeAnimation();
    _startCountdown();
  }

  void _setupShakeAnimation() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _startCountdown() {
    _secondsLeft = _countdownSeconds;
    _canResend = false;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    await MockAuthService.instance.sendOtp(widget.phone);
    if (!mounted) return;
    _startCountdown();
    // Clear digits
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // handle paste
      final pasted = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength && i < pasted.length; i++) {
        _controllers[i].text = pasted[i];
      }
      final nextFocus =
          pasted.length >= _otpLength ? _otpLength - 1 : pasted.length;
      _focusNodes[nextFocus.clamp(0, _otpLength - 1)].requestFocus();
      setState(() {});
      if (_isOtpComplete) _verifyOtp();
      return;
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    setState(() {});

    if (_isOtpComplete) {
      _verifyOtp();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  Future<void> _verifyOtp() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(widget.phone, _otp);

    if (!mounted) return;

    if (success) {
      final isNewUser = !(await MockAuthService.instance.isLoggedIn());
      if (!mounted) return;
      if (isNewUser) {
        Navigator.of(context).pushNamed(
          AppRoutes.pinSetup,
          arguments: widget.phone,
        );
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } else {
      _triggerShake();
      _clearOtp();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Kode OTP tidak valid.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  void _clearOtp() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  String get _maskedPhone {
    if (widget.phone.length <= 6) return widget.phone;
    final visible = widget.phone.substring(0, 4);
    final last = widget.phone.substring(widget.phone.length - 4);
    return '$visible****$last';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _shakeController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Verifikasi OTP', style: AppTextStyles.titleMedium),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verifikasi OTP',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kode OTP telah dikirim ke $_maskedPhone',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // OTP boxes with shake animation
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final offset =
                          (_shakeAnimation.value * 10 * (1 - _shakeAnimation.value))
                              .clamp(-10.0, 10.0);
                      return Transform.translate(
                        offset: Offset(
                          offset * ((_shakeController.value < 0.5) ? 1 : -1),
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: _OtpBoxesRow(
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                      otpLength: _otpLength,
                      onChanged: _onDigitChanged,
                      onKeyEvent: _onKeyEvent,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mock OTP hint
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Gunakan OTP: 123456',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Countdown / resend
                  Center(
                    child: _canResend
                        ? TextButton(
                            onPressed: _resendOtp,
                            child: Text(
                              'Kirim Ulang OTP',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Text(
                            'Kirim ulang ($_secondsLeft\u200bs)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),

                  // Verify button
                  OvoButton(
                    label: 'Verifikasi',
                    isLoading: authProvider.isLoading,
                    onPressed: (_isOtpComplete && !authProvider.isLoading)
                        ? _verifyOtp
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OtpBoxesRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final int otpLength;
  final void Function(int index, String value) onChanged;
  final void Function(int index, KeyEvent event) onKeyEvent;

  const _OtpBoxesRow({
    required this.controllers,
    required this.focusNodes,
    required this.otpLength,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(otpLength, (i) {
        return _OtpDigitBox(
          controller: controllers[i],
          focusNode: focusNodes[i],
          onChanged: (v) => onChanged(i, v),
          onKeyEvent: (e) => onKeyEvent(i, e),
        );
      }),
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final void Function(KeyEvent) onKeyEvent;

  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: SizedBox(
        width: 50,
        height: 56,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2.5),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
