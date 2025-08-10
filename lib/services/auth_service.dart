import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_service.dart';
import 'biometric_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // User authentication state
  bool _isAuthenticated = false;
  String? _currentUserId;
  String? _currentUserEmail;
  String? _currentUserDisplayName;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserId => _currentUserId;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserDisplayName => _currentUserDisplayName;

  /// Initialize authentication state
  Future<void> initializeAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('is_authenticated') ?? false;
      _currentUserId = prefs.getString('current_user_id');
      _currentUserEmail = prefs.getString('current_user_email');
      _currentUserDisplayName = prefs.getString('current_user_display_name');
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error initializing auth state: $e');
      _isAuthenticated = false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock authentication - in production, this would use Firebase Auth
      if (email.isNotEmpty && password.isNotEmpty) {
        _isAuthenticated = true;
        _currentUserId = DateTime.now().millisecondsSinceEpoch.toString();
        _currentUserEmail = email;
        _currentUserDisplayName = email.split('@').first;
        
        // Save auth state
        await _saveAuthState();
        
        // Auto-populate profile with display name
        if (_currentUserDisplayName != null) {
          await _autoPopulateProfile(_currentUserDisplayName!);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error during sign in: $e');
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock registration - in production, this would use Firebase Auth
      if (email.isNotEmpty && password.isNotEmpty && displayName.isNotEmpty) {
        _isAuthenticated = true;
        _currentUserId = DateTime.now().millisecondsSinceEpoch.toString();
        _currentUserEmail = email;
        _currentUserDisplayName = displayName;
        
        // Save auth state
        await _saveAuthState();
        
        // Auto-populate profile with display name
        await _autoPopulateProfile(displayName);
        
        return true;
      }
      
      return false;
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error during sign up: $e');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _isAuthenticated = false;
      _currentUserId = null;
      _currentUserEmail = null;
      _currentUserDisplayName = null;
      
      // Clear auth state
      await _clearAuthState();
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error during sign out: $e');
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock Google authentication - in production, this would use Firebase Auth
      _isAuthenticated = true;
      _currentUserId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentUserEmail = 'google.user@example.com';
      _currentUserDisplayName = 'Google User';
      
      // Save auth state
      await _saveAuthState();
      
      // Auto-populate profile with display name
      if (_currentUserDisplayName != null) {
        await _autoPopulateProfile(_currentUserDisplayName!);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error during Google sign in: $e');
      return false;
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock Apple authentication - in production, this would use Firebase Auth
      _isAuthenticated = true;
      _currentUserId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentUserEmail = 'apple.user@example.com';
      _currentUserDisplayName = 'Apple User';
      
      // Save auth state
      await _saveAuthState();
      
      // Auto-populate profile with display name
      if (_currentUserDisplayName != null) {
        await _autoPopulateProfile(_currentUserDisplayName!);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error during Apple sign in: $e');
      return false;
    }
  }

  /// Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock Facebook authentication - in production, this would use Firebase Auth
      _isAuthenticated = true;
      _currentUserId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentUserEmail = 'facebook.user@example.com';
      _currentUserDisplayName = 'Facebook User';
      
      // Save auth state
      await _saveAuthState();
      
      // Auto-populate profile with display name
      if (_currentUserDisplayName != null) {
        await _autoPopulateProfile(_currentUserDisplayName!);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error during Facebook sign in: $e');
      return false;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock implementation - in production, this would send a real email
      // For now, we'll just simulate success
      debugPrint('Mock password reset email sent to: $email');
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error sending password reset email: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({String? displayName, String? email}) async {
    try {
      if (displayName != null) {
        _currentUserDisplayName = displayName;
        await _saveAuthState();
      }
      
      if (email != null) {
        _currentUserEmail = email;
        await _saveAuthState();
      }
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error updating user profile: $e');
    }
  }

  /// Auto-populate profile with display name
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
      // Log error but don't crash the app
      debugPrint('Error auto-populating profile: $e');
    }
  }

  /// Save authentication state to local storage
  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', _isAuthenticated);
      await prefs.setString('current_user_id', _currentUserId ?? '');
      await prefs.setString('current_user_email', _currentUserEmail ?? '');
      await prefs.setString('current_user_display_name', _currentUserDisplayName ?? '');
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error saving auth state: $e');
    }
  }

  /// Clear authentication state from local storage
  Future<void> _clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_authenticated');
      await prefs.remove('current_user_id');
      await prefs.remove('current_user_email');
      await prefs.remove('current_user_display_name');
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error clearing auth state: $e');
    }
  }
} 