import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        final response = await SupabaseService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (response.user == null && mounted) {
          setState(
            () =>
                _errorMessage = 'Login failed. Please check your credentials.',
          );
        }
      } else {
        final response = await SupabaseService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
        );
        if (response.user != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account created! Please check your email to verify.',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() => _isLogin = true);
        }
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF1E1B4B)],
          ),
        ),
        child: Row(
          children: [
            // Left panel - branding
            Expanded(flex: 5, child: _buildBrandingPanel()),
            // Right panel - form
            Expanded(flex: 4, child: _buildFormPanel()),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingPanel() {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 36,
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, curve: Curves.easeOut),

          const SizedBox(height: 40),

          Text(
                'BG Manager',
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.5,
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideX(begin: -0.2),

          const SizedBox(height: 16),

          Text(
                'Bank Guarantee\nManagement System',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideX(begin: -0.2),

          const SizedBox(height: 60),

          // Features list
          ..._buildFeatureItems(),

          const Spacer(),

          // Bottom tagline
          Text(
            'Secure • Cloud • Real-time',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 3,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 1000.ms, duration: 800.ms),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureItems() {
    final features = [
      (Icons.cloud_done_rounded, 'Cloud-backed data, never lost'),
      (Icons.security_rounded, 'Enterprise-grade security'),
      (Icons.notifications_active_rounded, 'Real-time expiry alerts'),
      (Icons.bar_chart_rounded, 'Comprehensive analytics'),
    ];

    return features.asMap().entries.map((entry) {
      final index = entry.key;
      final (icon, label) = entry.value;
      return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primaryLight, size: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(delay: (600 + index * 150).ms, duration: 500.ms)
          .slideX(begin: -0.2);
    }).toList();
  }

  Widget _buildFormPanel() {
    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    _isLogin ? 'Welcome back' : 'Create account',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: 8),

                  Text(
                    _isLogin
                        ? 'Sign in to access your BG dashboard'
                        : 'Start managing your bank guarantees',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                  const SizedBox(height: 40),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.danger,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.inter(
                                color: AppColors.danger,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).shakeX(),

                  // Name field (signup only)
                  if (!_isLogin) ...[
                    _buildLabel('Full Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Enter your full name',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Email field
                  _buildLabel('Email Address'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v!.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password field
                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v!.isEmpty) return 'Password is required';
                      if (!_isLogin && v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),

                  // Forgot password (login only)
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: Text(
                          'Forgot password?',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primaryLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Sign In' : 'Create Account',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideY(begin: 0.3),

                  const SizedBox(height: 28),

                  // Toggle login/signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account? "
                            : 'Already have an account? ',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = null;
                          });
                        },
                        child: Text(
                          _isLogin ? 'Sign Up' : 'Sign In',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Password',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a reset link.',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'your@email.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailCtrl.text.isNotEmpty) {
                await SupabaseService.resetPassword(emailCtrl.text.trim());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Password reset email sent!',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Send Link',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
