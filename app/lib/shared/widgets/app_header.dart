import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class AppHeader extends ConsumerWidget {
  final VoidCallback? onMenuTap;
  final bool showLanguageSelector;
  final bool showMenu;
  final String? title;
  final Widget? trailing;

  const AppHeader({
    super.key,
    this.onMenuTap,
    this.showLanguageSelector = true,
    this.showMenu = true,
    this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Logo with glow effect
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Text(
                        'UA-ES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const Spacer(),
            // Language selector
            if (showLanguageSelector) ...[
              _LanguageSelector(
                selectedLocale: locale,
                onLocaleChanged: (newLocale) {
                  HapticFeedback.lightImpact();
                  ref.read(localeProvider.notifier).state = newLocale;
                },
              ),
              const SizedBox(width: 8),
            ],
            // Theme toggle
            _ThemeToggle(
              isDarkMode: isDarkMode,
              onToggle: () {
                HapticFeedback.lightImpact();
                ref.read(themeModeProvider.notifier).state =
                    isDarkMode ? ThemeMode.light : ThemeMode.dark;
              },
            ),
            const SizedBox(width: 8),
            // Trailing widget or menu
            if (trailing != null)
              trailing!
            else if (showMenu)
              _MenuButton(onTap: onMenuTap),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const _ThemeToggle({
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: AnimatedSwitcher(
          duration: AppTheme.durationFast,
          child: Icon(
            isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(isDarkMode),
            color: isDarkMode ? AppColors.warning : colors.textSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _MenuButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!();
        } else {
          Scaffold.of(context).openEndDrawer();
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Icon(
          Icons.menu_rounded,
          color: colors.textPrimary,
          size: 22,
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final AppLocale selectedLocale;
  final ValueChanged<AppLocale> onLocaleChanged;

  const _LanguageSelector({
    required this.selectedLocale,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageButton(
            label: 'ES',
            isSelected: selectedLocale == AppLocale.es,
            onTap: () => onLocaleChanged(AppLocale.es),
          ),
          const SizedBox(width: 2),
          _LanguageButton(
            label: 'UA',
            isSelected: selectedLocale == AppLocale.ua,
            onTap: () => onLocaleChanged(AppLocale.ua),
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
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : colors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
