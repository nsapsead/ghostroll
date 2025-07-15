import 'dart:async';
import 'package:rxdart/rxdart.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _notifyAuthChanged();
    return _mockUser;
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
      'displayName': 'Test User',
      'provider': 'email',
    };
    _notifyAuthChanged();
    return _mockUser;
  }

  // Sign in with Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful Google sign in
    _mockUser = {
      'uid': 'google-user-id',
      'email': 'user@gmail.com',
      'displayName': 'Google User',
      'provider': 'google',
      'photoURL': 'https://via.placeholder.com/150',
    };
    _notifyAuthChanged();
    return _mockUser;
  }

  // Sign in with Apple
  Future<Map<String, dynamic>?> signInWithApple() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful Apple sign in
    _mockUser = {
      'uid': 'apple-user-id',
      'email': 'user@privaterelay.appleid.com',
      'displayName': 'Apple User',
      'provider': 'apple',
      'photoURL': 'https://via.placeholder.com/150',
    };
    _notifyAuthChanged();
    return _mockUser;
  }

  // Sign in with Facebook
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful Facebook sign in
    _mockUser = {
      'uid': 'facebook-user-id',
      'email': 'user@facebook.com',
      'displayName': 'Facebook User',
      'provider': 'facebook',
      'photoURL': 'https://via.placeholder.com/150',
    };
    _notifyAuthChanged();
    return _mockUser;
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
    print('Password reset email sent to: $email');
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String displayName,
    String? photoURL,
  }) async {
    // Mock profile update
    print('Profile updated: $displayName');
  }

  // Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    // Mock user profile
    return {
      'uid': uid,
      'email': 'test@example.com',
      'displayName': 'Test User',
      'profile': {
        'personalInfo': {
          'name': 'Test User',
          'age': null,
          'gender': null,
          'weight': null,
          'height': null,
          'experience': null,
        },
        'martialArtsStyles': [],
        'beltRanks': {},
      },
    };
  }

  // Update user profile in Firestore
  Future<void> updateUserProfileData(String uid, Map<String, dynamic> data) async {
    // Mock profile data update
    print('Profile data updated for user: $uid');
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    // Mock account deletion
    print('User account deleted');
  }

  // Check if user exists
  Future<bool> userExists(String email) async {
    // Mock user existence check
    return email == 'test@example.com';
  }
} 