import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/auth_divider.dart';
import '../../../../shared/widgets/auth_link.dart';
import '../../../../shared/widgets/auth_logo.dart';
import '../../../../shared/widgets/auth_text_field.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/login_background.dart';
import '../../../../shared/widgets/social_button.dart';
import '../../domain/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authProvider).error ?? context.l10n.auth_loginError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).signInWithGoogle();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      final error = ref.read(authProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppColors.loginBackground,
        body: LoginBackground(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthLogo(),
                        const SizedBox(height: 24),
                        Text(
                          l10n.auth_loginTitle,
                          textAlign: TextAlign.center,
                          style: AppTheme.authTitle,
                        ),
                        const SizedBox(height: 32),
                        AuthTextField(
                          controller: _emailController,
                          hintText: l10n.auth_emailLabel,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.auth_emailRequired;
                            }
                            if (!value.contains('@')) {
                              return l10n.auth_emailInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _passwordController,
                          hintText: l10n.auth_passwordLabel,
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.lightTextMuted,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.auth_passwordRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          label: l10n.auth_loginButton,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 24),
                        AuthDivider(text: l10n.auth_continueWith),
                        const SizedBox(height: 24),
                        SocialButton(
                          onPressed: _handleGoogleSignIn,
                          label: l10n.auth_continueWithGoogle,
                          iconPath: 'assets/images/google-icon.svg',
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 24),
                        AuthLink(
                          text: l10n.auth_noAccount,
                          linkText: l10n.auth_signUp,
                          onTap: () => context.go('/register'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
