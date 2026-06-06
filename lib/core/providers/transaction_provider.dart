import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/transaction_model.dart';
import '../../core/constants/dummy_data.dart';

class TransactionProvider extends ChangeNotifier {
  static const String _keyTransactions = 'transactions';

  List<TransactionModel> _transactions = [];
  String _searchQuery = '';
  TransactionDirection? _filterDirection;
  DateTime? _filterMonth;
  bool _isLoading = false;

  List<TransactionModel> get allTransactions => _filtered(_transactions);
  List<TransactionModel> get recentTransactions => _transactions.take(5).toList();
  List<TransactionModel> get incomingTransactions =>
      _filtered(_transactions.where((t) => t.direction == TransactionDirection.credit).toList());
  List<TransactionModel> get outgoingTransactions =>
      _filtered(_transactions.where((t) => t.direction == TransactionDirection.debit).toList());
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TransactionDirection? get filterDirection => _filterDirection;

  List<TransactionModel> _filtered(List<TransactionModel> list) {
    var result = list;
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_filterMonth != null) {
      result = result
          .where((t) =>
              t.date.year == _filterMonth!.year &&
              t.date.month == _filterMonth!.month)
          .toList();
    }
    return result;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_keyTransactions);
      if (json != null) {
        final list = jsonDecode(json) as List;
        _transactions = list.map((e) => TransactionModel.fromJson(e)).toList();
        // Merge with dummy if empty
        if (_transactions.isEmpty) {
          _transactions = List.from(DummyData.transactions);
        }
      } else {
        _transactions = List.from(DummyData.transactions);
      }
      // Sort by date descending
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      _transactions = List.from(DummyData.transactions);
    }
    _isLoading = false;
    notifyListeners();
  }

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  Future<void> addTransaction(TransactionModel transaction) async {
    if (_isProcessing) return;
    _isProcessing = true;
    notifyListeners();
    try {
      _transactions.insert(0, transaction);
      await _persist();
      notifyListeners();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterMonth(DateTime? month) {
    _filterMonth = month;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterDirection = null;
    _filterMonth = null;
    notifyListeners();
  }

  TransactionModel? getById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_transactions.map((t) => t.toJson()).toList());
      await prefs.setString(_keyTransactions, json);
    } catch (_) {}
  }
}
