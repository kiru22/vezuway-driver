import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/form_app_bar.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../domain/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordSectionExpanded = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasNameChanged = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController.text = user?.name ?? '';
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final user = ref.read(authProvider).user;
    final hasChanged = _nameController.text != (user?.name ?? '');
    if (hasChanged != _hasNameChanged) {
      setState(() => _hasNameChanged = hasChanged);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      File imageFile;
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        imageFile = File(image.path);
        await imageFile.writeAsBytes(bytes);
      } else {
        imageFile = File(image.path);
      }

      final success =
          await ref.read(profileProvider.notifier).uploadAvatar(imageFile);
      if (success && mounted) {
        _showSuccessSnackBar(context.l10n.profile_avatarUpdated);
      } else if (mounted) {
        _showErrorSnackBar(context.l10n.profile_avatarError);
      }
    }
  }

  Future<void> _handleSaveName() async {
    if (!_nameFormKey.currentState!.validate()) return;

    final success = await ref.read(profileProvider.notifier).updateName(
          _nameController.text.trim(),
        );

    if (success && mounted) {
      _showSuccessSnackBar(context.l10n.profile_nameUpdated);
      setState(() => _hasNameChanged = false);
    } else if (mounted) {
      _showErrorSnackBar(context.l10n.profile_nameError);
    }
  }

  Future<void> _handleChangePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final success = await ref.read(profileProvider.notifier).updatePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

    if (success && mounted) {
      _showSuccessSnackBar(context.l10n.profile_passwordUpdated);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => _isPasswordSectionExpanded = false);
    } else if (mounted) {
      _showErrorSnackBar(context.l10n.profile_passwordError);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final l10n = context.l10n;
    final user = ref.watch(authProvider).user;
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: isDark ? colors.background : AppColors.lightBackground,
      appBar: FormAppBar(
        title: l10n.profile_title,
        onClose: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAvatarSection(user?.avatarUrl, user?.name ?? '',
                profileState.isLoading, colors, isDark),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            _buildNameSection(colors, isDark, l10n, profileState.isLoading),
            const SizedBox(height: 24),

            _buildPasswordSection(colors, isDark, l10n, profileState.isLoading,
                user?.googleId != null),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(
    String? avatarUrl,
    String name,
    bool isLoading,
    AppColorsExtension colors,
    bool isDark,
  ) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: isLoading ? null : _pickImage,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: avatarUrl == null ? AppColors.primaryGradient : null,
                boxShadow: AppTheme.shadowColored,
              ),
              child: ClipOval(
                child: avatarUrl != null
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildInitialAvatar(initial),
                      )
                    : _buildInitialAvatar(initial),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: isLoading ? null : _pickImage,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? colors.surface : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  boxShadow: AppTheme.shadowSoft,
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(6),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: AppColors.primary,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar(String initial) {
    return Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNameSection(
    AppColorsExtension colors,
    bool isDark,
    AppLocalizations l10n,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: isDark ? null : AppTheme.shadowSoft,
      ),
      child: Form(
        key: _nameFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.profile_name,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.profile_nameHint,
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: colors.textMuted,
                ),
                filled: true,
                fillColor:
                    isDark ? colors.surface : AppColors.lightSurfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.profile_nameRequired;
                }
                return null;
              },
            ),
            if (_hasNameChanged) ...[
              const SizedBox(height: 16),
              GradientButton(
                onPressed: isLoading ? null : _handleSaveName,
                label: l10n.profile_saveName,
                isLoading: isLoading,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection(
    AppColorsExtension colors,
    bool isDark,
    AppLocalizations l10n,
    bool isLoading,
    bool isGoogleUser,
  ) {
    // Hide password section for Google OAuth users
    if (isGoogleUser) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: isDark ? null : AppTheme.shadowSoft,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(
                () => _isPasswordSectionExpanded = !_isPasswordSectionExpanded),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: colors.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.profile_changePassword,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isPasswordSectionExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Form(
                key: _passwordFormKey,
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: l10n.profile_currentPassword,
                      obscure: _obscureCurrentPassword,
                      onToggle: () => setState(() =>
                          _obscureCurrentPassword = !_obscureCurrentPassword),
                      colors: colors,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.profile_passwordRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: l10n.profile_newPassword,
                      obscure: _obscureNewPassword,
                      onToggle: () => setState(
                          () => _obscureNewPassword = !_obscureNewPassword),
                      colors: colors,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.profile_passwordRequired;
                        }
                        if (value.length < 8) {
                          return l10n.profile_passwordMinLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: l10n.profile_confirmPassword,
                      obscure: _obscureConfirmPassword,
                      onToggle: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                      colors: colors,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.profile_passwordRequired;
                        }
                        if (value != _newPasswordController.text) {
                          return l10n.profile_passwordMismatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    GradientButton(
                      onPressed: isLoading ? null : _handleChangePassword,
                      label: l10n.profile_updatePassword,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),
            crossFadeState: _isPasswordSectionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required AppColorsExtension colors,
    required bool isDark,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.textSecondary),
        prefixIcon: Icon(Icons.lock_outline, color: colors.textMuted),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: colors.textMuted,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: isDark ? colors.surface : AppColors.lightSurfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
