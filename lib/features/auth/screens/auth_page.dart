import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_feedback_snackbar.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/input_field.dart';
import '../providers/auth_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _showPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showFeedback(
        const AuthFeedback(
          title: 'Missing details',
          message: 'Enter your email and password to continue.',
          icon: Icons.info_outline,
          color: Color(0xFFF2A23A),
        ),
      );
      return;
    }
    if (!_isLogin && name.isEmpty) {
      _showFeedback(
        const AuthFeedback(
          title: 'Name required',
          message: 'Add your full name before creating the account.',
          icon: Icons.person_outline,
          color: Color(0xFFF2A23A),
        ),
      );
      return;
    }
    if (!_isLogin && password.length < 6) {
      _showFeedback(
        const AuthFeedback(
          title: 'Password too short',
          message: 'Use at least 6 characters for your new password.',
          icon: Icons.lock_outline,
          color: Color(0xFFF2A23A),
        ),
      );
      return;
    }

    final result = _isLogin
        ? await authProvider.signIn(email: email, password: password)
        : await authProvider.signUp(
            name: name,
            email: email,
            password: password,
          );

    if (!mounted || result.isSuccess) {
      return;
    }
    final feedback = result.feedback ?? authProvider.lastFeedback;
    if (feedback != null) {
      _showFeedback(feedback);
    }
  }

  void _showFeedback(AuthFeedback feedback) {
    AppFeedbackSnackBar.show(
      context: context,
      title: feedback.title,
      message: feedback.message,
      icon: feedback.icon,
      color: feedback.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 40),
            decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'PennyWise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Firebase-backed personal finance tracker',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.border.withValues(alpha: 0.5),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.muted,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () =>
                                    setState(() => _isLogin = true),
                                style: TextButton.styleFrom(
                                  backgroundColor: _isLogin
                                      ? AppTheme.card
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: _isLogin
                                        ? AppTheme.foreground
                                        : AppTheme.mutedForeground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () =>
                                    setState(() => _isLogin = false),
                                style: TextButton.styleFrom(
                                  backgroundColor: !_isLogin
                                      ? AppTheme.card
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: !_isLogin
                                        ? AppTheme.foreground
                                        : AppTheme.mutedForeground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (!_isLogin) ...[
                        const Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InputField(
                          label: '',
                          hint: 'John Doe',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 12),
                      ],
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InputField(
                        label: '',
                        hint: 'you@example.com',
                        controller: _emailController,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: inputDecoration('••••••••').copyWith(
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authProvider.isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: authProvider.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(_isLogin ? 'Log In' : 'Create Account'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Your account controls access to your profile, activity, and savings goals.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
