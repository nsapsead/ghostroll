import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/auth_repository.dart';
import '../../theme/ghostroll_theme.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _errorMessage = '';
  String _passwordStrength = '';
  bool _isGoogleLoading = false;

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

    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    String password = _passwordController.text;
    int score = 0;
    String strength = '';

    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    switch (score) {
      case 0:
      case 1:
        strength = 'Very Weak';
        break;
      case 2:
        strength = 'Weak';
        break;
      case 3:
        strength = 'Fair';
        break;
      case 4:
        strength = 'Good';
        break;
      case 5:
        strength = 'Strong';
        break;
    }

    setState(() {
      _passwordStrength = strength;
    });
  }

  Color _getPasswordStrengthColor() {
    switch (_passwordStrength) {
      case 'Very Weak':
        return GhostRollTheme.grindRed;
      case 'Weak':
        return Colors.orange;
      case 'Fair':
        return Colors.yellow;
      case 'Good':
        return GhostRollTheme.recoveryGreen;
      case 'Strong':
        return GhostRollTheme.recoveryGreen;
      default:
        return GhostRollTheme.textSecondary;
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = await ref.read(authRepositoryProvider).createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());
        if (mounted) {
          // Pop the register screen so AuthWrapper can show the MainNavigationScreen
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = '';
    });

    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (user != null && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google sign up failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
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
                        const SizedBox(height: 20),
                        _buildLogo(),
                        const SizedBox(height: 32),
                        _buildWelcomeText(),
                        const SizedBox(height: 32),
                        _buildRegistrationForm(),
                        const SizedBox(height: 24),
                        _buildSignInLink(),
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
        height: 100,
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
          'Join GhostRoll',
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
            'Start tracking your martial arts journey',
            style: GhostRollTheme.bodyMedium.copyWith(
              color: GhostRollTheme.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
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
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildConfirmPasswordField(),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
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
                        'Create Account',
                        style: GhostRollTheme.labelLarge.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSocialAuthSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Full Name',
        prefixIcon: Icon(Icons.person_outline, color: GhostRollTheme.textSecondary),
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
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
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
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        if (_passwordStrength.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Strength: ',
                style: TextStyle(
                  color: GhostRollTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                _passwordStrength,
                style: TextStyle(
                  color: _getPasswordStrengthColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: Icon(Icons.lock_outline, color: GhostRollTheme.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
            color: GhostRollTheme.textTertiary,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
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
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildErrorMessage() {
    return Container(
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
    );
  }

  Widget _buildSocialAuthSection() {
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
                'or sign up with',
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
        _buildSocialButton(
          icon: Icons.g_mobiledata,
          label: 'Continue with Google',
          isLoading: _isGoogleLoading,
          onPressed: _signUpWithGoogle,
          color: Colors.red,
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: GhostRollTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: GhostRollTheme.bodyMedium.copyWith(
            color: GhostRollTheme.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Sign In',
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