import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/providers/balance_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _displayBalance = 0;
  double _targetBalance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _animation.addListener(() {
      setState(() {
        _displayBalance = _animation.value * _targetBalance;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final balance = context.read<BalanceProvider>().ovoBalance;
    if (_targetBalance != balance) {
      _targetBalance = balance;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BalanceProvider>(
      builder: (context, balanceProvider, _) {
        if (_targetBalance != balanceProvider.ovoBalance) {
          _targetBalance = balanceProvider.ovoBalance;
          _controller.forward(from: 0);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'OVO Cash',
                    style: AppTextStyles.titleMediumWhite.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        CurrencyFormatter.formatPoints(balanceProvider.ovoPoints),
                        style: AppTextStyles.bodySmallWhite,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total Saldo',
                style: AppTextStyles.bodySmallWhite.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    balanceProvider.isBalanceVisible
                        ? CurrencyFormatter.format(_displayBalance.round())
                        : 'Rp ••••••',
                    style: AppTextStyles.headlineLargeWhite.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: balanceProvider.toggleBalanceVisibility,
                    child: Icon(
                      balanceProvider.isBalanceVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickAction(Icons.add_circle_outline, 'Top Up', '/topup'),
                  _buildQuickAction(Icons.swap_horiz_rounded, 'Transfer', '/transfer'),
                  _buildQuickAction(Icons.credit_card_outlined, 'Tarik', '/withdraw'),
                  _buildQuickAction(Icons.history_rounded, 'Riwayat', '/history'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmallWhite.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
