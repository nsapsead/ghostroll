import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Centralized error handling utility
class ErrorHandler {
  /// Get user-friendly error message from exception
  static String getUserFriendlyMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled.';
        case 'user-disabled':
          return 'This account has been disabled.';
        default:
          return 'Authentication failed. Please try again.';
      }
    }
    
    if (error.toString().contains('network') || error.toString().contains('Network')) {
      return 'Network error. Please check your internet connection.';
    }
    
    if (error.toString().contains('permission') || error.toString().contains('Permission')) {
      return 'You don\'t have permission to perform this action.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  /// Log error to Crashlytics
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    bool fatal = false,
    String? reason,
  }) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: fatal,
        reason: reason,
      );
    } catch (e) {
      // If Crashlytics fails, at least log to console
      debugPrint('Error logging to Crashlytics: $e');
      debugPrint('Original error: $error');
    }
  }

  /// Show error snackbar to user
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar to user
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  /// Handle error with logging and user feedback
  static Future<void> handleError(
    BuildContext context,
    dynamic error,
    StackTrace? stackTrace, {
    bool fatal = false,
    String? customMessage,
    bool showToUser = true,
  }) async {
    // Log to Crashlytics
    await logError(error, stackTrace, fatal: fatal);
    
    // Show user-friendly message
    if (showToUser && context.mounted) {
      final message = customMessage ?? getUserFriendlyMessage(error);
      showErrorSnackBar(context, message);
    }
  }
}


