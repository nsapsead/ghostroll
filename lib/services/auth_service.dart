import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'profile_service.dart';
import 'biometric_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // Emit the current user immediately on construction
    _authController.add(_mockUser);
  }

  // Mock user for testing - start with null to show login screen
  static Map<String, dynamic>? _mockUser = null;
  static final BehaviorSubject<Map<String, dynamic>?> _authController =
      BehaviorSubject<Map<String, dynamic>?>.seeded(_mockUser);
  
  final BiometricService _biometricService = BiometricService();

  // Notify listeners when auth state changes
  void _notifyAuthChanged() {
    _authController.add(_mockUser);
  }

  // Get current user
  Map<String, dynamic>? get currentUser => _mockUser;

  // Auth state changes stream
  Stream<Map<String, dynamic>?> get authStateChanges => _authController.stream;

  // Sign up with email and password
  Future<Map<String, dynamic>?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful registration
    _mockUser = {
      'uid': 'mock-user-id',
      'email': email,
      'displayName': displayName,
      'provider': 'email',
    };
    
    // Auto-populate profile with display name
    await _autoPopulateProfile(displayName);
    
    _notifyAuthChanged();
    return _mockUser;
  }

  // Auto-populate profile with display name
  Future<void> _autoPopulateProfile(String displayName) async {
    try {
      final nameParts = displayName.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final surname = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      // Load existing profile data
      final existingData = await ProfileService.loadProfileData();
      
      // Only update if name fields are empty
      if ((existingData['firstName']?.isEmpty ?? true) && 
          (existingData['surname']?.isEmpty ?? true)) {
        final updatedData = {
          ...existingData,
          'firstName': firstName,
          'surname': surname,
        };
        await ProfileService.saveProfileData(updatedData);
      }
    } catch (e) {
      print('Error auto-populating profile: $e');
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful login
    _mockUser = {
      'uid': 'mock-user-id',
      'email': email,
      'displayName': 'Mock User',
      'provider': 'email',
    };
    
    _notifyAuthChanged();
    return _mockUser;
  }

  // Sign in with Google (placeholder for future implementation)
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    throw UnimplementedError('Google Sign-In not yet implemented');
  }

  // Sign in with Apple (placeholder for future implementation)
  Future<Map<String, dynamic>?> signInWithApple() async {
    throw UnimplementedError('Apple Sign-In not yet implemented');
  }

  // Sign in with Facebook (placeholder for future implementation)
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    throw UnimplementedError('Facebook Sign-In not yet implemented');
  }

  // Sign out
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Clear local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Clear mock user
    _mockUser = null;
    _notifyAuthChanged();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful password reset
    print('Mock password reset email sent to: $email');
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String displayName,
    String? photoURL,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Update mock user
    if (_mockUser != null) {
      _mockUser = {
        ..._mockUser!,
        'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
      };
      _notifyAuthChanged();
    }
  }

  // Handle authentication exceptions (mock implementation)
  String _handleAuthException(dynamic e) {
    return 'Authentication failed: $e';
  }

  // Get user profile (placeholder for Firestore integration)
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    // TODO: Implement Firestore integration
    return null;
  }

  // Update user profile data (placeholder for Firestore integration)
  Future<void> updateUserProfileData(String uid, Map<String, dynamic> data) async {
    // TODO: Implement Firestore integration
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Clear mock user
    _mockUser = null;
    _notifyAuthChanged();
  }

  // Check if user exists
  Future<bool> userExists(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock implementation - always return false for new users
    return false;
  }

  // Biometric Authentication Methods

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    return await _biometricService.isBiometricAvailable();
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _biometricService.getAvailableBiometrics();
  }

  /// Get primary biometric type for the device
  Future<String?> getPrimaryBiometricType() async {
    return await _biometricService.getPrimaryBiometricType();
  }

  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics() async {
    final success = await _biometricService.authenticateWithBiometrics(
      reason: 'Sign in to GhostRoll',
    );
    
    if (success) {
      // If biometric auth succeeds, restore the last known user
      await _restoreUserFromBiometric();
      await _biometricService.recordSuccessfulAuth();
    }
    
    return success;
  }

  /// Enable biometric authentication
  Future<void> enableBiometricAuth() async {
    await _biometricService.setBiometricEnabled(true);
    await _biometricService.setRememberMeEnabled(true);
  }

  /// Disable biometric authentication
  Future<void> disableBiometricAuth() async {
    await _biometricService.setBiometricEnabled(false);
    await _biometricService.setRememberMeEnabled(false);
    await _biometricService.clearAuthRecords();
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    return await _biometricService.isBiometricEnabled();
  }

  /// Check if "Remember Me" is enabled
  Future<bool> isRememberMeEnabled() async {
    return await _biometricService.isRememberMeEnabled();
  }

  /// Enable or disable "Remember Me"
  Future<void> setRememberMeEnabled(bool enabled) async {
    await _biometricService.setRememberMeEnabled(enabled);
  }

  /// Check if user needs to re-authenticate
  Future<bool> needsReAuthentication() async {
    return await _biometricService.needsReAuthentication();
  }

  /// Get authentication status
  Future<Map<String, dynamic>> getAuthStatus() async {
    return await _biometricService.getAuthStatus();
  }

  /// Restore user from biometric authentication
  Future<void> _restoreUserFromBiometric() async {
    // In a real app, this would restore the user from secure storage
    // For now, we'll use a mock user
    if (_mockUser == null) {
      _mockUser = {
        'uid': 'biometric-user-id',
        'email': 'user@example.com',
        'displayName': 'Biometric User',
        'provider': 'biometric',
      };
      _notifyAuthChanged();
    }
  }

  /// Initialize authentication state on app start
  Future<void> initializeAuthState() async {
    final authStatus = await _biometricService.getAuthStatus();
    
    // If biometric auth is enabled and user doesn't need re-authentication
    if (authStatus['canUseBiometrics'] && !authStatus['needsReAuthentication']) {
      // Automatically restore user session
      await _restoreUserFromBiometric();
    }
  }
} 