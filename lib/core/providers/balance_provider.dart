import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/dummy_data.dart';
import '../errors/exceptions.dart';

class BalanceProvider extends ChangeNotifier {
  static const String _keyBalance = 'ovo_balance';
  static const String _keyPoints = 'ovo_points';

  double _ovoBalance = DummyData.currentUser.ovoBalance;
  int _ovoPoints = DummyData.currentUser.ovoPoints;
  bool _isBalanceVisible = true;
  bool _isProcessing = false;

  double get ovoBalance => _ovoBalance;
  int get ovoPoints => _ovoPoints;
  bool get isBalanceVisible => _isBalanceVisible;
  bool get isProcessing => _isProcessing;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _ovoBalance = prefs.getDouble(_keyBalance) ?? DummyData.currentUser.ovoBalance;
    _ovoPoints = prefs.getInt(_keyPoints) ?? DummyData.currentUser.ovoPoints;
    notifyListeners();
  }

  Future<bool> deduct(double amount) async {
    if (_isProcessing) return false;
    if (amount < 10000) {
      throw MinimumAmountException();
    }
    if (_ovoBalance < amount) {
      throw InsufficientBalanceException();
    }

    _isProcessing = true;
    notifyListeners();
    try {
      _ovoBalance -= amount;
      await _persist();
      notifyListeners();
      return true;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> credit(double amount) async {
    if (_isProcessing) return;
    _isProcessing = true;
    notifyListeners();
    try {
      _ovoBalance += amount;
      await _persist();
      notifyListeners();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> addPoints(int points) async {
    _ovoPoints += points;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPoints, _ovoPoints);
    notifyListeners();
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBalance, _ovoBalance);
  }

  bool hasSufficientBalance(double amount) => _ovoBalance >= amount;
}

