import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../theme/ghostroll_theme.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _rememberMe = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isFacebookLoading = false;
  bool _isBiometricLoading = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    
    _loadRememberMeState();
  }

  Future<void> _loadRememberMeState() async {
    final biometricService = BiometricService();
    final rememberMe = await biometricService.isRememberMeEnabled();
    setState(() {
      _rememberMe = rememberMe;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // If remember me is enabled, also enable biometric auth
      if (_rememberMe) {
        final biometricService = BiometricService();
        await biometricService.enableBiometricAuth();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // TODO: Implement social sign-in methods
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = '';
    });

    try {
      // TODO: Implement Google sign-in
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _errorMessage = 'Google sign-in not yet implemented';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Google sign in failed. Please try again.';
      });
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isAppleLoading = true;
      _errorMessage = '';
    });

    try {
      // TODO: Implement Apple sign-in
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _errorMessage = 'Apple sign-in not yet implemented';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Apple sign in failed. Please try again.';
      });
    } finally {
      setState(() {
        _isAppleLoading = false;
      });
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() {
      _isFacebookLoading = true;
      _errorMessage = '';
    });

    try {
      // TODO: Implement Facebook sign-in
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _errorMessage = 'Facebook sign-in not yet implemented';
      });
    } catch (e) {
      setState(() {
        _isFacebookLoading = false;
      });
    }
  }

  Future<void> _signInWithBiometrics() async {
    setState(() {
      _isBiometricLoading = true;
      _errorMessage = '';
    });

    try {
      final biometricService = BiometricService();
      final success = await biometricService.authenticate();
      if (!success) {
        setState(() {
          _errorMessage = 'Biometric authentication failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Biometric authentication failed. Please try again.';
      });
    } finally {
      setState(() {
        _isBiometricLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ghost watermark background
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                'assets/images/GhostRollBeltMascot.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Main content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: GhostRollTheme.primaryGradient,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        _buildLogo(),
                        const SizedBox(height: 48),
                        _buildWelcomeText(),
                        const SizedBox(height: 48),
                        _buildLoginForm(),
                        const SizedBox(height: 24),
                        _buildBiometricButton(),
                        const SizedBox(height: 16),
                        _buildSocialLoginButtons(),
                        const SizedBox(height: 24),
                        _buildSignUpLink(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: GhostRollTheme.glow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/GhostRollBeltMascot.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: GhostRollTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: GhostRollTheme.flowGradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: GhostRollTheme.small,
          ),
          child: Text(
            'Sign in to continue your training journey',
            style: GhostRollTheme.bodyMedium.copyWith(
              color: GhostRollTheme.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: GhostRollTheme.medium,
        border: Border.all(
          color: GhostRollTheme.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign In',
              style: GhostRollTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, color: GhostRollTheme.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                ),
                filled: true,
                fillColor: GhostRollTheme.overlayDark,
              ),
              style: TextStyle(color: GhostRollTheme.text),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline, color: GhostRollTheme.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: GhostRollTheme.textTertiary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                ),
                filled: true,
                fillColor: GhostRollTheme.overlayDark,
              ),
              style: TextStyle(color: GhostRollTheme.text),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) async {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                        final biometricService = BiometricService();
      await biometricService.setRememberMeEnabled(_rememberMe);
                      },
                      activeColor: GhostRollTheme.flowBlue,
                      checkColor: GhostRollTheme.text,
                    ),
                    Text(
                      'Remember me',
                      style: GhostRollTheme.bodyMedium.copyWith(
                        color: GhostRollTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: GhostRollTheme.bodyMedium.copyWith(
                      color: GhostRollTheme.flowBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GhostRollTheme.grindRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: GhostRollTheme.grindRed.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: GhostRollTheme.grindRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: GhostRollTheme.bodyMedium.copyWith(
                          color: GhostRollTheme.grindRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GhostRollTheme.flowBlue,
                  foregroundColor: GhostRollTheme.text,
                  elevation: 12,
                  shadowColor: GhostRollTheme.flowBlue.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(GhostRollTheme.text),
                        ),
                      )
                    : Text(
                        'Sign In',
                        style: GhostRollTheme.labelLarge.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return FutureBuilder<bool>(
      future: BiometricService().isBiometricAvailable(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        
        if (snapshot.data != true) {
          return const SizedBox.shrink();
        }
        
        return FutureBuilder<String?>(
          future: BiometricService().getPrimaryBiometricType(),
          builder: (context, biometricSnapshot) {
            final biometricType = biometricSnapshot.data ?? 'Biometric';
            
            return Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F5FF), Color(0xFF1F8EF1)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F5FF).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isBiometricLoading ? null : _signInWithBiometrics,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: _isBiometricLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                biometricType == 'Face ID' 
                                    ? Icons.face 
                                    : Icons.fingerprint,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sign in with $biometricType',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: GhostRollTheme.textSecondary.withOpacity(0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: GhostRollTheme.bodyMedium.copyWith(
                  color: GhostRollTheme.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: GhostRollTheme.textSecondary.withOpacity(0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                isLoading: _isGoogleLoading,
                onPressed: _signInWithGoogle,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocialButton(
                icon: Icons.apple,
                label: 'Apple',
                isLoading: _isAppleLoading,
                onPressed: _signInWithApple,
                color: Colors.white,
                backgroundColor: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocialButton(
                icon: Icons.facebook,
                label: 'Facebook',
                isLoading: _isFacebookLoading,
                onPressed: _signInWithFacebook,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
    required Color color,
    Color? backgroundColor,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor ?? GhostRollTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: backgroundColor != null 
              ? Colors.transparent 
              : GhostRollTheme.textSecondary.withOpacity(0.2),
        ),
        boxShadow: GhostRollTheme.small,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GhostRollTheme.bodyMedium.copyWith(
            color: GhostRollTheme.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Text(
            'Sign Up',
            style: GhostRollTheme.bodyMedium.copyWith(
              color: GhostRollTheme.flowBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
} 