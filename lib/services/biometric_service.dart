import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Keys for SharedPreferences
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _rememberMeKey = 'remember_me';
  static const String _lastAuthTimeKey = 'last_auth_time';
  static const String _authTimeoutKey = 'auth_timeout_hours';

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      return isAvailable && isDeviceSupported;
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Touch ID';
      case BiometricType.iris:
        return 'Iris';
      default:
        return 'Biometric';
    }
  }

  /// Get primary biometric type for the device
  Future<String?> getPrimaryBiometricType() async {
    final availableBiometrics = await getAvailableBiometrics();
    
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Touch ID';
    }
    
    return null;
  }

  /// Authenticate using biometrics
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your journal',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Check if biometric authentication is enabled by user
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Enable or disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  /// Check if "Remember Me" is enabled
  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  /// Enable or disable "Remember Me"
  Future<void> setRememberMeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, enabled);
  }

  /// Enable biometric authentication for the current user
  Future<void> enableBiometricAuth() async {
    try {
      // Enable biometric authentication
      await setBiometricEnabled(true);
      
      // Enable remember me
      await setRememberMeEnabled(true);
      
      // Record successful authentication
      await recordSuccessfulAuth();
      
      debugPrint('Biometric authentication enabled successfully');
    } catch (e) {
      debugPrint('Error enabling biometric authentication: $e');
      rethrow;
    }
  }

  /// Set authentication timeout (in hours)
  Future<void> setAuthTimeout(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_authTimeoutKey, hours);
  }

  /// Get authentication timeout (in hours)
  Future<int> getAuthTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_authTimeoutKey) ?? 24; // Default 24 hours
  }

  /// Check if user needs to re-authenticate based on timeout
  Future<bool> needsReAuthentication() async {
    final rememberMe = await isRememberMeEnabled();
    if (!rememberMe) return true;

    final prefs = await SharedPreferences.getInstance();
    final lastAuthTime = prefs.getInt(_lastAuthTimeKey);
    if (lastAuthTime == null) return true;

    final timeoutHours = await getAuthTimeout();
    final timeoutDuration = Duration(hours: timeoutHours);
    final lastAuth = DateTime.fromMillisecondsSinceEpoch(lastAuthTime);
    final now = DateTime.now();

    return now.difference(lastAuth) > timeoutDuration;
  }

  /// Record successful authentication
  Future<void> recordSuccessfulAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastAuthTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear authentication records
  Future<void> clearAuthRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastAuthTimeKey);
  }

  /// Get device-specific authentication message
  String getAuthMessage() {
    if (Platform.isIOS) {
      return 'Use Face ID or Touch ID to sign in';
    } else if (Platform.isAndroid) {
      return 'Use fingerprint or face recognition to sign in';
    }
    return 'Use biometric authentication to sign in';
  }

  /// Check if device has biometric hardware
  Future<bool> hasBiometricHardware() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      return isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error checking biometric hardware: $e');
      return false;
    }
  }

  /// Get authentication status summary
  Future<Map<String, dynamic>> getAuthStatus() async {
    final hasHardware = await hasBiometricHardware();
    final isEnabled = await isBiometricEnabled();
    final rememberMe = await isRememberMeEnabled();
    final needsReAuth = await needsReAuthentication();
    final primaryType = await getPrimaryBiometricType();

    return {
      'hasBiometricHardware': hasHardware,
      'isBiometricEnabled': isEnabled,
      'isRememberMeEnabled': rememberMe,
      'needsReAuthentication': needsReAuth,
      'primaryBiometricType': primaryType,
      'canUseBiometrics': hasHardware && isEnabled,
    };
  }
} 