import 'package:flutter/material.dart';

import '../../app/themes/app_colors.dart';

enum TransactionType {
  transfer,
  topup,
  payment,
  withdraw,
  pulsa,
  internet,
  pln,
  cashback,
}

enum TransactionStatus {
  success,
  pending,
  failed,
}

enum TransactionDirection {
  debit,
  credit,
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final TransactionDirection direction;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final TransactionStatus status;
  final String? referenceId;
  final String? note;
  final String? targetPhone;
  final String? targetName;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.direction,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.status,
    this.referenceId,
    this.note,
    this.targetPhone,
    this.targetName,
  });

  bool get isDebit => direction == TransactionDirection.debit;
  bool get isCredit => direction == TransactionDirection.credit;

  String get typeLabel {
    switch (type) {
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.topup:
        return 'Top Up';
      case TransactionType.payment:
        return 'Pembayaran';
      case TransactionType.withdraw:
        return 'Tarik Tunai';
      case TransactionType.pulsa:
        return 'Pulsa';
      case TransactionType.internet:
        return 'Internet';
      case TransactionType.pln:
        return 'PLN';
      case TransactionType.cashback:
        return 'Cashback';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
      case TransactionType.topup:
        return Icons.add_circle_rounded;
      case TransactionType.payment:
        return Icons.shopping_bag_rounded;
      case TransactionType.withdraw:
        return Icons.account_balance_rounded;
      case TransactionType.pulsa:
        return Icons.smartphone_rounded;
      case TransactionType.internet:
        return Icons.wifi_rounded;
      case TransactionType.pln:
        return Icons.bolt_rounded;
      case TransactionType.cashback:
        return Icons.card_giftcard_rounded;
    }
  }

  Color get typeColor {
    switch (type) {
      case TransactionType.transfer:
        return AppColors.primary;
      case TransactionType.topup:
        return AppColors.success;
      case TransactionType.payment:
        return AppColors.warning;
      case TransactionType.withdraw:
        return AppColors.error;
      case TransactionType.pulsa:
        return AppColors.info;
      case TransactionType.internet:
        return AppColors.primaryLight;
      case TransactionType.pln:
        return AppColors.warning;
      case TransactionType.cashback:
        return AppColors.success;
    }
  }

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    TransactionDirection? direction,
    String? title,
    String? subtitle,
    double? amount,
    DateTime? date,
    TransactionStatus? status,
    String? referenceId,
    String? note,
    String? targetPhone,
    String? targetName,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      referenceId: referenceId ?? this.referenceId,
      note: note ?? this.note,
      targetPhone: targetPhone ?? this.targetPhone,
      targetName: targetName ?? this.targetName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'direction': direction.name,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status.name,
      'referenceId': referenceId,
      'note': note,
      'targetPhone': targetPhone,
      'targetName': targetName,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      direction:
          TransactionDirection.values.byName(json['direction'] as String),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      status: TransactionStatus.values.byName(json['status'] as String),
      referenceId: json['referenceId'] as String?,
      note: json['note'] as String?,
      targetPhone: json['targetPhone'] as String?,
      targetName: json['targetName'] as String?,
    );
  }
}
