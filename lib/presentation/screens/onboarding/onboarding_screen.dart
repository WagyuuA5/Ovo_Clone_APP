import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/services/mock_auth_service.dart';
import '../../widgets/common/ovo_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  static const List<_OnboardingData> _slides = [
    _OnboardingData(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Dompet Digital Terpercaya',
      subtitle:
          'Kelola keuangan kamu dengan mudah dan aman bersama OVO',
    ),
    _OnboardingData(
      icon: Icons.swap_horiz_rounded,
      title: 'Transfer Kilat',
      subtitle:
          'Kirim uang ke sesama pengguna OVO dalam hitungan detik',
    ),
    _OnboardingData(
      icon: Icons.local_offer_rounded,
      title: 'Promo Eksklusif',
      subtitle: 'Dapatkan cashback dan promo menarik setiap hari',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _slides.length - 1;

  Future<void> _navigateToLogin() async {
    await MockAuthService.instance.setOnboarded();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _onNextPressed() {
    if (_isLastPage) {
      _navigateToLogin();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Top gradient header area (~40% of screen)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.42,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button at top right
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _navigateToLogin,
                    child: Text(
                      'Lewati',
                      style: AppTextStyles.labelLargeWhite,
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      return _OnboardingSlide(data: _slides[index]);
                    },
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _slides.length,
                        effect: WormEffect(
                          activeDotColor: AppColors.primary,
                          dotColor: AppColors.divider,
                          dotHeight: 10,
                          dotWidth: 10,
                          spacing: 8,
                        ),
                      ),
                      const SizedBox(height: 28),
                      OvoButton(
                        label: _isLastPage ? 'Mulai' : 'Lanjut',
                        onPressed: _onNextPressed,
                      ),
                      const SizedBox(height: 16),
                      if (!_isLastPage)
                        OvoButton(
                          label: 'Lewati',
                          variant: OvoButtonVariant.ghost,
                          onPressed: _navigateToLogin,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.05),
          // Icon in colored circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                data.icon,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.08),

          // Title
          Text(
            data.title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            data.subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
