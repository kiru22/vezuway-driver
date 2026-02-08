import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/package_box_icon.dart';
import '../../../shared/widgets/styled_form_field.dart';
import '../../auth/domain/providers/auth_provider.dart';
import '../../contacts/domain/providers/contact_provider.dart';
import '../../trips/presentation/screens/trips_routes_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  bool _slideFromRight = true;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNavTap(int newIndex, BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    if (newIndex == currentIndex) return;

    HapticFeedback.lightImpact();

    setState(() {
      _slideFromRight = newIndex > currentIndex;
    });

    // Update slide direction for animation
    _slideAnimation = Tween<Offset>(
      begin: _slideFromRight ? const Offset(1, 0) : const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.reset();
    _animationController.forward();

    switch (newIndex) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/packages');
        break;
      case 2:
        context.go('/routes');
        break;
      case 3:
        context.go('/contacts');
        break;
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/home' || location == '/') return 0;
    if (location.startsWith('/packages')) return 1;
    if (location.startsWith('/routes')) return 2;
    if (location.startsWith('/contacts')) return 3;
    return 0;
  }

  void _handleAddPressed(BuildContext context) {
    HapticFeedback.mediumImpact();
    final currentIndex = _calculateSelectedIndex(context);

    // Obtener tipo de usuario
    final authState = ref.read(authProvider);
    final user = authState.user;
    final isClient = user?.isClient ?? false;

    // Clientes solo pueden crear pedidos
    if (isClient) {
      context.push('/packages/new');
      return;
    }

    // Resto de usuarios: lógica normal
    switch (currentIndex) {
      case 0: // Dashboard
      case 1: // Packages
        context.push('/packages/new');
        break;
      case 2: // Routes/Trips screen
        final tabIndex = ref.read(tripsRoutesTabIndexProvider);
        if (tabIndex == 0) {
          context.push('/trips/create');
        } else {
          context.push('/routes/create');
        }
        break;
      case 3: // Contacts
        _showCreateContactDialog(context);
        break;
    }
  }

  void _showCreateContactDialog(BuildContext context) {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.contacts_newContact,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 24),

                StyledFormField(
                  controller: nameController,
                  label: l10n.contacts_nameLabel,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.contacts_nameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                StyledFormField(
                  controller: emailController,
                  label: l10n.contacts_emailLabel,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return l10n.contacts_emailInvalid;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                StyledFormField(
                  controller: phoneController,
                  label: l10n.contacts_phoneLabel,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      child: Text(l10n.common_cancel),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        try {
                          await ref
                              .read(contactsProvider.notifier)
                              .createContact(
                                name: nameController.text.trim(),
                                email: emailController.text.trim().isNotEmpty
                                    ? emailController.text.trim()
                                    : null,
                                phone: phoneController.text.trim().isNotEmpty
                                    ? phoneController.text.trim()
                                    : null,
                              );

                          if (context.mounted) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.contacts_created)),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${l10n.common_error}: ${e.toString()}')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: Text(l10n.contacts_create),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const bottomNavHeight = 60.0 + 16 + 16;
    final currentIndex = _calculateSelectedIndex(context);

    // Obtener tipo de usuario para navegación condicional
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isClient = user?.isClient ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            context.isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: colors.navBackground,
        systemNavigationBarIconBrightness:
            context.isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding:
                    EdgeInsets.only(bottom: bottomNavHeight + bottomPadding),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(currentIndex),
                    child: widget.child,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _PremiumBottomNav(
                currentIndex: currentIndex,
                onTap: (index) => _onNavTap(index, context),
                onAddPressed: () => _handleAddPressed(context),
                isClientMode: isClient,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingAddButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _FloatingAddButton({required this.onPressed});

  @override
  State<_FloatingAddButton> createState() => _FloatingAddButtonState();
}

class _FloatingAddButtonState extends State<_FloatingAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      label: l10n.quickAction_title,
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddPressed;
  final bool isClientMode;

  const _PremiumBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.onAddPressed,
    this.isClientMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final isDark = context.isDarkMode;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: AppTheme.glassBlurFilter,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.glassGradient(isDark: isDark),
          ),
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark ? colors.navBackground : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? colors.border.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.06),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (isClientMode)
                        Expanded(
                          child: Center(
                            child: _NavItem(
                              icon: Icons.shopping_bag_outlined,
                              activeIcon: Icons.shopping_bag_rounded,
                              label: 'Mis pedidos',
                              isSelected: true,
                              onTap: () => onTap(1),
                            ),
                          ),
                        )
                      else ...[
                        Expanded(
                          child: _NavItem(
                            icon: Icons.space_dashboard_outlined,
                            activeIcon: Icons.space_dashboard_rounded,
                            label: l10n.nav_home,
                            isSelected: currentIndex == 0,
                            onTap: () => onTap(0),
                          ),
                        ),
                        Expanded(
                          child: _NavItem(
                            icon: Icons.view_in_ar_outlined,
                            activeIcon: Icons.view_in_ar_rounded,
                            iconBuilder: (color, size) =>
                                PackageBoxIcon(size: size, color: color),
                            label: l10n.nav_packages,
                            isSelected: currentIndex == 1,
                            onTap: () => onTap(1),
                          ),
                        ),
                        Expanded(
                          child: _NavItem(
                            icon: Icons.timeline_outlined,
                            activeIcon: Icons.timeline_rounded,
                            label: l10n.nav_routes,
                            isSelected: currentIndex == 2,
                            onTap: () => onTap(2),
                          ),
                        ),
                        Expanded(
                          child: _NavItem(
                            icon: Icons.contacts_outlined,
                            activeIcon: Icons.contacts_rounded,
                            label: l10n.nav_contacts,
                            isSelected: currentIndex == 3,
                            onTap: () => onTap(3),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 60,
                height: 60,
                child: _FloatingAddButton(onPressed: onAddPressed),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final Widget Function(Color color, double size)? iconBuilder;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    this.iconBuilder,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    final color = isSelected
        ? AppColors.primary
        : isDark
            ? colors.textMuted
            : Colors.black45;

    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: iconBuilder != null
              ? iconBuilder!(color, 24)
              : Icon(
                  isSelected ? activeIcon : icon,
                  color: color,
                  size: 24,
                ),
        ),
      ),
    );
  }
}
