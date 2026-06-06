import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../core/constants/dummy_data.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void initialize() {
    _notifications = List.from(DummyData.notifications);
    notifyListeners();
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void addTransactionNotification({
    required String title,
    required String body,
  }) {
    final notification = NotificationModel(
      id: 'NTF${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: NotificationType.transaction,
      isRead: false,
      createdAt: DateTime.now(),
    );
    addNotification(notification);
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void dismissNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
