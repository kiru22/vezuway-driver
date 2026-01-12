import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/providers/locale_provider.dart';
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
          child: Stack(
            children: [
              Positioned(
                top: 16,
                right: 24,
                child: const _LanguageSwitcher(),
              ),
              SafeArea(
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
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSwitcher extends ConsumerWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocale = ref.watch(localeProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageButton(
            label: 'ES',
            isSelected: selectedLocale == AppLocale.es,
            onTap: () => ref.read(localeProvider.notifier).setLocale(AppLocale.es),
          ),
          const SizedBox(width: 2),
          _LanguageButton(
            label: 'UA',
            isSelected: selectedLocale == AppLocale.uk,
            onTap: () => ref.read(localeProvider.notifier).setLocale(AppLocale.uk),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white60,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
