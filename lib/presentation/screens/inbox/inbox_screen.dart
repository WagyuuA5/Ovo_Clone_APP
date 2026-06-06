import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/notification_model.dart';
import '../../widgets/common/ovo_app_bar.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Kotak Masuk',
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Notifikasi'),
            Tab(text: 'Pesan'),
          ],
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (_, provider, __) {
              if (provider.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => provider.markAllAsRead(),
                child: Text(
                  'Tandai Semua Dibaca',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsTab(context),
          _buildMessagesTab(context, isDark),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final notifications = provider.notifications;

        if (notifications.isEmpty) {
          return _buildEmptyState('Tidak ada notifikasi', 'Semua notifikasi kamu akan muncul di sini');
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: notifications.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: Theme.of(context).dividerTheme.color ?? AppColors.divider),
          itemBuilder: (context, index) {
            final notif = notifications[index];
            return _NotificationTile(notification: notif);
          },
        );
      },
    );
  }

  Widget _buildMessagesTab(BuildContext context, bool isDark) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final messages = chatProvider.messages;
        if (messages.isEmpty) {
          return _buildEmptyState('Tidak ada pesan', 'Hubungi Customer Service untuk bantuan');
        }

        final lastMessage = messages.last;

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              onTap: () => Navigator.of(context).pushNamed('/chat'),
              leading: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 28),
              ),
              title: Text(
                'Customer Service',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                lastMessage.text,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                '${lastMessage.time.hour.toString().padLeft(2, '0')}:${lastMessage.time.minute.toString().padLeft(2, '0')}',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textHint),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            Divider(height: 1, color: Theme.of(context).dividerTheme.color ?? AppColors.divider),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
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
            child: const Icon(Icons.notifications_none_rounded,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NotificationProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => provider.dismissNotification(notification.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Hapus',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      child: InkWell(
        onTap: () => provider.markAsRead(notification.id),
        child: Container(
          color: notification.isRead
              ? (isDark ? AppColors.backgroundDark : AppColors.background)
              : (isDark ? AppColors.primarySurfaceDark : AppColors.primarySurface),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconCircle(),
              const SizedBox(width: 12),
              Expanded(child: _buildContent(context, isDark)),
              const SizedBox(width: 8),
              _buildTrailing(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconCircle() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: notification.typeColor.withOpacity(0.14),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(notification.typeIcon,
          color: notification.typeColor, size: 22),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          notification.body,
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textSecondary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTrailing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!notification.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          DateFormatter.formatRelative(notification.createdAt),
          style: AppTextStyles.labelSmall
              .copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }
}
