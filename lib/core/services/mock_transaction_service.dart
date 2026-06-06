import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/transaction_model.dart';
import '../constants/app_constants.dart';

class MockTransactionService {
  MockTransactionService._();
  static final MockTransactionService instance = MockTransactionService._();

  final _uuid = const Uuid();

  Future<TransactionModel> processTransfer({
    required String targetPhone,
    required String targetName,
    required double amount,
    String? note,
  }) async {
    await Future.delayed(AppConstants.transactionDelay);
    return TransactionModel(
      id: 'TRX${_uuid.v4().substring(0, 8).toUpperCase()}',
      type: TransactionType.transfer,
      direction: TransactionDirection.debit,
      title: 'Transfer ke $targetName',
      subtitle: targetPhone,
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.success,
      targetPhone: targetPhone,
      targetName: targetName,
      note: note,
      referenceId: 'REF${_uuid.v4().substring(0, 8).toUpperCase()}',
    );
  }

  Future<TransactionModel> processTopUp({
    required String bankName,
    required double amount,
  }) async {
    await Future.delayed(AppConstants.transactionDelay);
    return TransactionModel(
      id: 'TRX${_uuid.v4().substring(0, 8).toUpperCase()}',
      type: TransactionType.topup,
      direction: TransactionDirection.credit,
      title: 'Top Up dari $bankName',
      subtitle: 'Transfer $bankName',
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.success,
      referenceId: 'REF${_uuid.v4().substring(0, 8).toUpperCase()}',
    );
  }

  Future<TransactionModel> processPayment({
    required String merchantName,
    required double amount,
    String? note,
  }) async {
    await Future.delayed(AppConstants.transactionDelay);
    return TransactionModel(
      id: 'TRX${_uuid.v4().substring(0, 8).toUpperCase()}',
      type: TransactionType.payment,
      direction: TransactionDirection.debit,
      title: 'Bayar di $merchantName',
      subtitle: merchantName,
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.success,
      referenceId: 'REF${_uuid.v4().substring(0, 8).toUpperCase()}',
    );
  }

  Future<TransactionModel> processWithdraw({
    required String bankName,
    required double amount,
  }) async {
    await Future.delayed(AppConstants.transactionDelay);
    return TransactionModel(
      id: 'TRX${_uuid.v4().substring(0, 8).toUpperCase()}',
      type: TransactionType.withdraw,
      direction: TransactionDirection.debit,
      title: 'Tarik Tunai $bankName',
      subtitle: 'ATM $bankName',
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.success,
      referenceId: 'REF${_uuid.v4().substring(0, 8).toUpperCase()}',
    );
  }

  Future<Map<String, dynamic>> processPlnPayment({
    required String customerId,
    required String customerName,
    required double amount,
  }) async {
    await Future.delayed(AppConstants.transactionDelay);
    final tokenDigits = List.generate(16, (_) => (DateTime.now().millisecondsSinceEpoch % 10).toString()).join();
    final token = '${tokenDigits.substring(0, 4)}-${tokenDigits.substring(4, 8)}-${tokenDigits.substring(8, 12)}-${tokenDigits.substring(12, 16)}';
    final tx = TransactionModel(
      id: 'TRX${_uuid.v4().substring(0, 8).toUpperCase()}',
      type: TransactionType.pln,
      direction: TransactionDirection.debit,
      title: 'PLN Listrik',
      subtitle: 'ID Pelanggan: $customerId',
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.success,
      referenceId: token,
      targetName: customerName,
    );
    return {'transaction': tx, 'token': token};
  }

  Future<TransactionModel> processPulsa({
    required String phone,
    required String operator,
    required String packageName,
    required double amount,
  }) async {
    await Future.delayed(AppConstants.transactionDelay);
    return TransactionModel(
      id: 'TRX${_uuid.v4().substring(0, 8).toUpperCase()}',
      type: TransactionType.pulsa,
      direction: TransactionDirection.debit,
      title: 'Pulsa $operator',
      subtitle: '$packageName • $phone',
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.success,
      targetPhone: phone,
      referenceId: 'REF${_uuid.v4().substring(0, 8).toUpperCase()}',
    );
  }

  Future<TransactionModel> processInternet({
    required String phone,
    required String operator,
    required String packageName,
    required double amount,
  }) async {
    await Future.delayed(AppConstants.transactionDelay);
    return TransactionModel(
      id: 'TRX${_uuid.v4().substring(0, 8).toUpperCase()}',
      type: TransactionType.internet,
      direction: TransactionDirection.debit,
      title: 'Paket Internet $operator',
      subtitle: '$packageName • $phone',
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.success,
      targetPhone: phone,
      referenceId: 'REF${_uuid.v4().substring(0, 8).toUpperCase()}',
    );
  }

  String generateWithdrawCode() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch % 1000000}'.padLeft(6, '0');
  }
}
