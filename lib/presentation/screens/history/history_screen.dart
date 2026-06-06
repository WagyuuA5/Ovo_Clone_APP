import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../widgets/common/ovo_app_bar.dart';
import '../../widgets/common/ovo_text_field.dart';
import '../../widgets/common/transaction_tile.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedMonth;

  final List<DateTime> _months = List.generate(6, (i) {
    final now = DateTime.now();
    return DateTime(now.year, now.month - i, 1);
  });

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OvoAppBar(
        title: 'Riwayat Transaksi',
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        showBackButton: false,
        bottom: _buildTabBar(),
        bottomHeight: 48,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TransactionList(filterType: _FilterType.all),
                _TransactionList(filterType: _FilterType.incoming),
                _TransactionList(filterType: _FilterType.outgoing),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
      unselectedLabelStyle: AppTextStyles.labelLarge,
      tabs: const [
        Tab(text: 'Semua'),
        Tab(text: 'Masuk'),
        Tab(text: 'Keluar'),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: OvoTextField(
              controller: _searchController,
              hint: 'Cari transaksi...',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textSecondary),
              onChanged: (val) {
                context.read<TransactionProvider>().setSearchQuery(val);
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 12),
          _buildMonthDropdown(),
        ],
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DateTime?>(
          value: _selectedMonth,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary, size: 18),
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
          hint: Text('Bulan',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          items: [
            DropdownMenuItem<DateTime?>(
              value: null,
              child: Text('Semua',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textPrimary)),
            ),
            ..._months.map((m) => DropdownMenuItem<DateTime?>(
                  value: m,
                  child: Text(DateFormatter.formatMonth(m),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textPrimary)),
                )),
          ],
          onChanged: (val) {
            setState(() => _selectedMonth = val);
            context.read<TransactionProvider>().setFilterMonth(val);
          },
        ),
      ),
    );
  }
}

enum _FilterType { all, incoming, outgoing }

class _TransactionList extends StatelessWidget {
  final _FilterType filterType;

  const _TransactionList({required this.filterType});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final List<TransactionModel> transactions;
        switch (filterType) {
          case _FilterType.all:
            transactions = provider.allTransactions;
            break;
          case _FilterType.incoming:
            transactions = provider.incomingTransactions;
            break;
          case _FilterType.outgoing:
            transactions = provider.outgoingTransactions;
            break;
        }

        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (transactions.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: AppColors.divider,
          ),
          itemBuilder: (context, index) {
            final tx = transactions[index];
            return TransactionTile(
              transaction: tx,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TransactionDetailScreen(transaction: tx),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada transaksi',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada riwayat transaksi\nuntuk filter yang dipilih',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
