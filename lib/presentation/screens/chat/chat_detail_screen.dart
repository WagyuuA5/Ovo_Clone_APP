import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../data/models/chat_message.dart';
import '../../widgets/common/ovo_app_bar.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Trigger scroll to bottom on new messages
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const OvoAppBar(title: 'Customer Service'),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final messages = chatProvider.messages;
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada percakapan',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageBubble(context, msg);
                  },
                );
              },
            ),
          ),
          _buildInputArea(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage msg) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final alignment = msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = msg.isMe
        ? AppColors.primary
        : (isDark ? AppColors.surfaceDark : Colors.white);
    final textColor = msg.isMe
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);
    final borderRadius = msg.isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
            border: msg.isMe
                ? null
                : Border.all(color: isDark ? AppColors.dividerDark : AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                msg.text,
                style: AppTextStyles.bodyMedium.copyWith(color: textColor),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: msg.isMe ? Colors.white60 : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  if (msg.isMe) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(msg.status),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 12, color: Colors.white60);
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 12, color: Colors.white60);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 12, color: Colors.greenAccent);
    }
  }

  Widget _buildInputArea(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.primary),
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }
}
