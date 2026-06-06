import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';

class PinSetupScreen extends StatefulWidget {
  final String phone;

  const PinSetupScreen({super.key, required this.phone});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 6;

  int _step = 0; // 0 = create, 1 = confirm
  String _firstPin = '';
  String _currentInput = '';
  String? _errorMessage;

  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(-0.05, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.05, 0), end: const Offset(0.05, 0)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.05, 0), end: const Offset(-0.05, 0)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.05, 0), end: Offset.zero),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumpadKey(String key) {
    if (key == 'del') {
      if (_currentInput.isNotEmpty) {
        setState(() {
          _currentInput =
              _currentInput.substring(0, _currentInput.length - 1);
          _errorMessage = null;
        });
      }
      return;
    }

    if (_currentInput.length >= _pinLength) return;

    setState(() {
      _currentInput += key;
      _errorMessage = null;
    });

    if (_currentInput.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 150), _onPinComplete);
    }
  }

  Future<void> _onPinComplete() async {
    if (_step == 0) {
      // Save first PIN, move to confirmation step
      setState(() {
        _firstPin = _currentInput;
        _currentInput = '';
        _step = 1;
      });
    } else {
      // Confirm step
      if (_currentInput == _firstPin) {
        await _finishSetup();
      } else {
        _shakeController.forward(from: 0);
        setState(() {
          _errorMessage = 'PIN tidak cocok. Ulangi.';
          _currentInput = '';
          _step = 0;
          _firstPin = '';
        });
      }
    }
  }

  Future<void> _finishSetup() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.setupPin(_currentInput);
    await authProvider.login(widget.phone);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
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
        title: Text('Buat PIN', style: AppTextStyles.titleMedium),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step progress indicator
            _StepProgress(currentStep: _step, totalSteps: 2),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Title for current step
                    Text(
                      _step == 0 ? 'Buat PIN' : 'Konfirmasi PIN',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _step == 0
                          ? 'Buat PIN 6 digit untuk keamanan akun kamu'
                          : 'Masukkan kembali PIN yang sudah kamu buat',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // PIN dots
                    SlideTransition(
                      position: _shakeAnimation,
                      child: _PinDots(
                        filledCount: _currentInput.length,
                        totalCount: _pinLength,
                        hasError: _errorMessage != null,
                      ),
                    ),

                    // Error message
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      opacity: _errorMessage != null ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _errorMessage ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Custom numpad
                    _NumPad(onKey: _onNumpadKey),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step Progress Widget
// ---------------------------------------------------------------------------

class _StepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgress({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isActive = i <= currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 8 : 0),
              height: 5,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PIN Dots Widget
// ---------------------------------------------------------------------------

class _PinDots extends StatelessWidget {
  final int filledCount;
  final int totalCount;
  final bool hasError;

  const _PinDots({
    required this.filledCount,
    required this.totalCount,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCount, (i) {
        final isFilled = i < filledCount;
        final dotColor = hasError
            ? AppColors.error
            : (isFilled ? AppColors.primary : Colors.transparent);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : (isFilled ? AppColors.primary : AppColors.textHint),
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Numpad Widget
// ---------------------------------------------------------------------------

class _NumPad extends StatelessWidget {
  final void Function(String key) onKey;

  const _NumPad({required this.onKey});

  static const List<List<String>> _layout = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _layout.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 80, height: 64);
            return _NumPadKey(label: key, onTap: () => onKey(key));
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _NumPadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumPadKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDel = label == 'del';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 64,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isDel
              ? const Icon(
                  Icons.backspace_outlined,
                  color: AppColors.textSecondary,
                  size: 24,
                )
              : Text(
                  label,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
