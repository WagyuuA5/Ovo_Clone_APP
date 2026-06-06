import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class MockAuthService {
  MockAuthService._();
  static final MockAuthService instance = MockAuthService._();

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserPin = 'user_pin';
  static const String _keyIsOnboarded = 'is_onboarded';

  Future<bool> sendOtp(String phone) async {
    await Future.delayed(AppConstants.otpDelay);
    return true;
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    return otp == AppConstants.mockOtp;
  }

  Future<bool> verifyPin(String pin) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_keyUserPin) ?? AppConstants.defaultPin;
    return pin == savedPin;
  }

  Future<void> setupPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserPin, pin);
  }

  Future<void> saveLoginState(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserPhone, phone);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsOnboarded) ?? false;
  }

  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsOnboarded, true);
  }

  Future<String?> getSavedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserPhone);
  }

  Future<String> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserPin) ?? AppConstants.defaultPin;
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    await Future.delayed(const Duration(seconds: 1));
    final currentPin = await getPin();
    if (currentPin != oldPin) return false;
    await setupPin(newPin);
    return true;
  }
}
