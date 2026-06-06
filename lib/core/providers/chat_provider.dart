import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: 'Halo! Ada yang bisa kami bantu hari ini?',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      status: MessageStatus.read,
    ),
  ];

  List<ChatMessage> get messages => _messages;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final userMsg = ChatMessage(
      id: messageId,
      text: text,
      isMe: true,
      time: DateTime.now(),
      status: MessageStatus.sending,
    );
    _messages.add(userMsg);
    notifyListeners();

    // Simulate sent
    Future.delayed(const Duration(milliseconds: 500), () {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(status: MessageStatus.sent);
        notifyListeners();
      }
    });

    // Simulate read
    Future.delayed(const Duration(milliseconds: 1000), () {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(status: MessageStatus.read);
        notifyListeners();
      }
    });

    // Simulate mock auto-reply after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      final replies = [
        'Terima kasih telah menghubungi Customer Service OVO. Pertanyaan Anda akan segera direspons oleh agen kami.',
        'Baik, mohon tunggu sebentar kami sedang memverifikasi data Anda.',
        'Ada hal lain yang bisa kami bantu terkait saldo atau transfer?',
        'Sistem kami mencatat transaksi terakhir Anda berjalan dengan lancar.',
      ];
      final randomReply = (replies..shuffle()).first;
      final replyMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: randomReply,
        isMe: false,
        time: DateTime.now(),
        status: MessageStatus.read,
      );
      _messages.add(replyMsg);
      notifyListeners();
    });
  }
}
