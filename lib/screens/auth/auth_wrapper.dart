import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import 'login_screen.dart';
import '../main_navigation_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Initialize auth service
      await _authService.initializeAuthState();
      
      // Check if user is already authenticated
      final isAuthenticated = _authService.isAuthenticated;
      
      if (isAuthenticated) {
        // Check if biometric auth is available and enabled
        final biometricAvailable = await _biometricService.isBiometricAvailable();
        final biometricEnabled = await _biometricService.isBiometricEnabled();
        
        if (biometricAvailable && biometricEnabled) {
          // Attempt biometric authentication
          final authenticated = await _biometricService.authenticate();
          if (authenticated) {
            _navigateToMain();
            return;
          }
        }
        
        // If no biometric or biometric failed, go to main
        _navigateToMain();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error initializing auth: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToMain() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }
    
    // User is not authenticated, show login screen
    return const LoginScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ghost mascot logo
            Image.asset(
              'assets/images/ghostroll_logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            // Loading text
            const Text(
              'GhostRoll',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
} 