import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_model.dart';
import '../../core/constants/dummy_data.dart';
import '../../core/services/mock_auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  static const String _keyUserData = 'user_data';
  static const String _keyAccountLocked = 'ovo_account_locked';

  AuthStatus _status = AuthStatus.initial;
  UserModel _user = DummyData.currentUser;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isAccountLocked = false;

  AuthStatus get status => _status;
  UserModel get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAccountLocked => _isAccountLocked;

  final MockAuthService _authService = MockAuthService.instance;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAccountLocked = prefs.getBool(_keyAccountLocked) ?? false;
      final loggedIn = await _authService.isLoggedIn();
      if (loggedIn) {
        await _loadUserFromPrefs();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    _setLoading(false);
  }

  Future<void> lockAccount() async {
    _isAccountLocked = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAccountLocked, true);
    notifyListeners();
  }

  Future<void> unlockAccount() async {
    _isAccountLocked = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAccountLocked, false);
    notifyListeners();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUserData);
    if (json != null) {
      _user = UserModel.fromJson(jsonDecode(json));
    }
  }

  Future<void> _saveUserToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(_user.toJson()));
  }

  Future<bool> sendOtp(String phone) async {
    _setLoading(true);
    _clearError();
    try {
      final success = await _authService.sendOtp(phone);
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Gagal mengirim OTP. Coba lagi.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    _setLoading(true);
    _clearError();
    try {
      final valid = await _authService.verifyOtp(phone, otp);
      if (!valid) {
        _setError('Kode OTP tidak valid.');
        _setLoading(false);
        return false;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Verifikasi OTP gagal.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> login(String phone) async {
    _setLoading(true);
    try {
      _user = _user.copyWith(phone: phone, lastLogin: DateTime.now());
      await _authService.saveLoginState(phone);
      await _saveUserToPrefs();
      _status = AuthStatus.authenticated;
    } catch (e) {
      _setError('Login gagal. Coba lagi.');
    }
    _setLoading(false);
  }

  Future<void> setupPin(String pin) async {
    await _authService.setupPin(pin);
  }

  Future<void> logout() async {
    await _authService.logout();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    _user = _user.copyWith(
      name: name ?? _user.name,
      email: email ?? _user.email,
      avatarUrl: avatarUrl ?? _user.avatarUrl,
    );
    await _saveUserToPrefs();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
