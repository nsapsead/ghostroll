import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/auth_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_components.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = false;
  bool _emailSent = false;
  String _errorMessage = '';

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(_emailController.text.trim());
      setState(() {
        _emailSent = true;
      });
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

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'Password reset failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.xl),
                    if (_emailSent) _buildSuccessContent() else _buildResetForm(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: GradientCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.small,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Image.asset(
                    'assets/images/GhostRollBeltMascot.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Reset Password',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GradientCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Text(
            'Enter your email to receive reset instructions',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return GradientCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forgot your password?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildEmailField(),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _buildErrorMessage(),
            ],
            const SizedBox(height: AppSpacing.lg),
            _buildResetButton(),
            const SizedBox(height: AppSpacing.md),
            _buildBackToLoginLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _emailController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter your email',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              contentPadding: EdgeInsets.all(AppSpacing.md),
            ),
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
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.red.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[300],
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return AppButton(
      text: _isLoading ? 'Sending...' : 'Send Reset Link',
      onPressed: _isLoading ? null : _resetPassword,
      isLoading: _isLoading,
      backgroundColor: Colors.white,
      textColor: AppColors.primary,
    );
  }

  Widget _buildBackToLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        },
        child: Text(
          'Back to Login',
          style: TextStyle(
            color: AppColors.textSecondary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        GradientCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 64,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Email Sent!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We\'ve sent password reset instructions to:\n${_emailController.text}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GradientCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.success, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Check your email and follow the link to reset your password',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          text: 'Back to Login',
          onPressed: () => Navigator.pop(context),
          width: double.infinity,
        ),
      ],
    );
  }
} 