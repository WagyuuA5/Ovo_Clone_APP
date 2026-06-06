import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/common/ovo_card.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  String _selectedYear = '2026';
  String _selectedTimeframe = '1D';
  int? _hoveredIndex;
  double? _touchX;

  // Cache generated detailed points to keep chart consistent
  late Map<String, Map<String, List<double>>> _chartPoints;
  late Map<String, List<String>> _timeLabels;

  @override
  void initState() {
    super.initState();
    _generateData();
  }

  void _generateData() {
    _chartPoints = {};
    _timeLabels = {
      '1D': ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00'],
      '1W': ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
      '1M': ['M1', 'M2', 'M3', 'M4'],
      '1Y': ['Jan', 'Mar', 'Mei', 'Jul', 'Sep', 'Nov'],
    };

    // Seed data points for volatility
    final random = math.Random(42);
    for (var year in ['2024', '2025', '2026']) {
      _chartPoints[year] = {};
      double startPrice = year == '2026' ? 1450000 : (year == '2025' ? 1200000 : 950000);
      
      for (var tf in ['1D', '1W', '1M', '1Y']) {
        int count = tf == '1D' ? 60 : (tf == '1W' ? 50 : 80);
        List<double> points = [];
        double current = startPrice;
        
        for (int i = 0; i < count; i++) {
          double changePercent = (random.nextDouble() - 0.48) * 0.05; // Volatility factor
          current = current * (1.0 + changePercent);
          // Keep bounds realistic
          if (current < startPrice * 0.7) current = startPrice * 0.7;
          if (current > startPrice * 1.5) current = startPrice * 1.5;
          points.add(current);
        }
        _chartPoints[year]![tf] = points;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = _chartPoints[_selectedYear]![_selectedTimeframe]!;
    final xLabels = _timeLabels[_selectedTimeframe]!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Finance',
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUpperSummary(context),
            const SizedBox(height: 16),
            _buildCryptoChartSection(context, points, xLabels),
            const SizedBox(height: 16),
            _buildBudgetTracker(context),
            const SizedBox(height: 16),
            _buildCategories(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUpperSummary(BuildContext context) {
    final double income = _selectedYear == '2026' ? 18200000 : (_selectedYear == '2025' ? 15600000 : 12000000);
    final double expense = _selectedYear == '2026' ? 8900000 : (_selectedYear == '2025' ? 7200000 : 5400000);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Laporan Keuangan',
                style: AppTextStyles.titleMediumWhite.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedYear,
                    dropdownColor: AppColors.primary,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    items: ['2024', '2025', '2026'].map((year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text('Tahun $year'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedYear = val;
                          _hoveredIndex = null;
                          _touchX = null;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCardItem(
                  context,
                  title: 'Pemasukan',
                  amount: income,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCardItem(
                  context,
                  title: 'Pengeluaran',
                  amount: expense,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardItem(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.dividerDark : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(amount.toInt()),
            style: AppTextStyles.titleSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoChartSection(BuildContext context, List<double> points, List<String> xLabels) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Displayed Price value tracking
    String displayedPrice;
    if (_hoveredIndex != null && _hoveredIndex! < points.length) {
      displayedPrice = CurrencyFormatter.format(points[_hoveredIndex!].toInt());
    } else {
      displayedPrice = CurrencyFormatter.format(points.last.toInt());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OvoCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Saldo Aktif',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayedPrice,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  _buildTimeframeTabs(),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _touchX = details.localPosition.dx;
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _touchX = null;
                    _hoveredIndex = null;
                  });
                },
                onTapDown: (details) {
                  setState(() {
                    _touchX = details.localPosition.dx;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _touchX = null;
                    _hoveredIndex = null;
                  });
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    // Note: Reserve right side (approx 50px) for Y-axis labels
                    final chartWidth = width - 50;
                    final step = chartWidth / (points.length - 1);
                    if (_touchX != null) {
                      int index = (_touchX! / step).round();
                      if (index < 0) index = 0;
                      if (index >= points.length) index = points.length - 1;
                      _hoveredIndex = index;
                    }
                    return Container(
                      height: 180,
                      width: width,
                      color: Colors.transparent,
                      child: CustomPaint(
                        painter: _ProfessionalCryptoPainter(
                          data: points,
                          hoveredIndex: _hoveredIndex,
                          isDark: isDark,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Bottom X-axis Labels
              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: xLabels.map((lbl) {
                    return Text(
                      lbl,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textHint,
                        fontSize: 9,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeTabs() {
    final List<String> intervals = ['1D', '1W', '1M', '1Y'];
    return Row(
      children: intervals.map((tf) {
        final isSelected = _selectedTimeframe == tf;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTimeframe = tf;
              _hoveredIndex = null;
              _touchX = null;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.transparent : AppColors.divider,
              ),
            ),
            child: Text(
              tf,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBudgetTracker(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final budgetLimit = 1000000.0;
    final budgetSpent = _selectedYear == '2026' ? 450000.0 : (_selectedYear == '2025' ? 380000.0 : 250000.0);
    final percentage = (budgetSpent / budgetLimit).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OvoCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget Bulanan',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toInt()}% Terpakai',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 8,
                  backgroundColor: isDark ? AppColors.dividerDark : AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Telah Dibelanjakan',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(budgetSpent.toInt()),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Batas Anggaran',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(budgetLimit.toInt()),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double expense = _selectedYear == '2026' ? 8900000 : (_selectedYear == '2025' ? 7200000 : 5400000);
    final categories = [
      _CategorySpending(
        icon: Icons.restaurant_rounded,
        label: 'Makanan & Minuman',
        amount: (expense * 0.45).toInt(),
        color: Colors.orange,
      ),
      _CategorySpending(
        icon: Icons.directions_car_rounded,
        label: 'Transportasi',
        amount: (expense * 0.25).toInt(),
        color: Colors.blue,
      ),
      _CategorySpending(
        icon: Icons.receipt_long_rounded,
        label: 'Tagihan & PLN',
        amount: (expense * 0.3).toInt(),
        color: Colors.purple,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Pengeluaran',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: categories.map((cat) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.label,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(cat.amount / expense * 100).toInt()}% dari total pengeluaran',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(cat.amount),
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategorySpending {
  final IconData icon;
  final String label;
  final int amount;
  final Color color;

  const _CategorySpending({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });
}

class _ProfessionalCryptoPainter extends CustomPainter {
  final List<double> data;
  final int? hoveredIndex;
  final bool isDark;

  _ProfessionalCryptoPainter({
    required this.data,
    required this.hoveredIndex,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    // Reserve 50px on the right for Y-axis labels
    final double chartWidth = size.width - 50;
    final double height = size.height;
    final double step = chartWidth / (data.length - 1);

    // Color theme matches crypto screenshot (Teal/Emerald Green)
    const Color trendColor = Color(0xFF10B981);

    // 1. Draw Grid Lines & Y-axis labels
    final Paint gridPaint = Paint()
      ..color = isDark ? const Color(0xFF222235) : const Color(0xFFF0F0F5)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Render 4 horizontal gridlines & prices
    for (int i = 0; i <= 3; i++) {
      final double ratio = i / 3;
      final double y = ratio * (height - 30) + 15;
      final double gridPrice = maxVal - (ratio * range);

      // Line
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);

      // Label text on the right side
      textPainter.text = TextSpan(
        text: CurrencyFormatter.formatCompact(gridPrice.toInt()),
        style: TextStyle(
          color: AppColors.textHint,
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(chartWidth + 8, y - 6));
    }

    // Convert data to Offset points
    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final double x = i * step;
      final double normalizedY = (data[i] - minVal) / range;
      final double y = height - (normalizedY * (height - 30) + 15);
      points.add(Offset(x, y));
    }

    // 2. Draw Area Gradient path
    final Path areaPath = Path();
    areaPath.moveTo(points.first.dx, height);
    areaPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      areaPath.lineTo(p2.dx, p2.dy);
    }
    areaPath.lineTo(points.last.dx, height);
    areaPath.close();

    final Paint areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          trendColor.withOpacity(0.25),
          trendColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(0, 0, chartWidth, height));

    canvas.drawPath(areaPath, areaPaint);

    // 3. Draw Trend Line
    final Paint linePaint = Paint()
      ..color = trendColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // 4. Draw Interactive touch tracking
    if (hoveredIndex != null && hoveredIndex! < points.length) {
      final hoveredPoint = points[hoveredIndex!];

      // Vertical line
      final Paint trackerPaint = Paint()
        ..color = isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)
        ..strokeWidth = 1.0;

      double startY = 0;
      while (startY < height) {
        canvas.drawLine(
          Offset(hoveredPoint.dx, startY),
          Offset(hoveredPoint.dx, (startY + 4).clamp(0.0, height)),
          trackerPaint,
        );
        startY += 8;
      }

      // Outer glow circle
      final Paint dotOuter = Paint()
        ..color = trendColor.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(hoveredPoint, 8.0, dotOuter);

      // Inner solid point
      final Paint dotInner = Paint()
        ..color = trendColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(hoveredPoint, 3.5, dotInner);
    }
  }

  @override
  bool shouldRepaint(covariant _ProfessionalCryptoPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex || oldDelegate.isDark != isDark || oldDelegate.data != data;
  }
}
