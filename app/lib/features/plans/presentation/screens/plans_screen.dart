import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../widgets/plan_background_orbs.dart';
import '../widgets/plan_card.dart';
import '../widgets/plan_tab_selector.dart';

class PlanData {
  final String nameKey;
  final int price;
  final int scannerLimit;
  final int smsLimit;
  final IconData icon;
  final bool isPopular;

  final Color darkGradientStart;
  final Color darkGradientEnd;
  final Color darkBgTint;

  final Color lightGradientStart;
  final Color lightGradientEnd;
  final Color lightBgTint;

  final Color accent;
  final Color accentDark;

  const PlanData({
    required this.nameKey,
    required this.price,
    required this.scannerLimit,
    required this.smsLimit,
    required this.icon,
    this.isPopular = false,
    required this.darkGradientStart,
    required this.darkGradientEnd,
    required this.darkBgTint,
    required this.lightGradientStart,
    required this.lightGradientEnd,
    required this.lightBgTint,
    required this.accent,
    required this.accentDark,
  });
}

const plans = [
  PlanData(
    nameKey: 'basic',
    price: 49,
    scannerLimit: 50,
    smsLimit: 150,
    icon: Icons.rocket_launch_rounded,
    darkGradientStart: Color(0xFF2D2418),
    darkGradientEnd: Color(0xFF1F1A12),
    darkBgTint: Color(0xFF1A1610),
    lightGradientStart: Color(0xFFFFF7ED),
    lightGradientEnd: Color(0xFFFED7AA),
    lightBgTint: Color(0xFFFFFBF5),
    accent: AppColors.planBasic,
    accentDark: Color(0xFFD97706), // amber-600
  ),
  PlanData(
    nameKey: 'pro',
    price: 99,
    scannerLimit: 250,
    smsLimit: 400,
    icon: Icons.auto_awesome_rounded,
    isPopular: true,
    darkGradientStart: Color(0xFF0F2318),
    darkGradientEnd: Color(0xFF0A1A12),
    darkBgTint: Color(0xFF0D1A14),
    lightGradientStart: Color(0xFFECFDF5),
    lightGradientEnd: Color(0xFFA7F3D0),
    lightBgTint: Color(0xFFF0FDF8),
    accent: AppColors.planPro,
    accentDark: AppColors.primaryDark, // teal-600
  ),
  PlanData(
    nameKey: 'premium',
    price: 149,
    scannerLimit: 500,
    smsLimit: 800,
    icon: Icons.diamond_rounded,
    darkGradientStart: Color(0xFF151B2D),
    darkGradientEnd: Color(0xFF111827),
    darkBgTint: Color(0xFF111520),
    lightGradientStart: Color(0xFFEFF6FF),
    lightGradientEnd: Color(0xFFBFDBFE),
    lightBgTint: Color(0xFFF5F9FF),
    accent: AppColors.planPremium,
    accentDark: Color(0xFF2563EB), // blue-600
  ),
];

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _entranceController;
  late final Animation<double> _headerAnimation;
  late final Animation<double> _tabsAnimation;
  late final Animation<double> _cardAnimation;

  int _currentPage = 1; // Start on Pro
  double _pageOffset = 1.0; // For parallax

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1,
      viewportFraction: 0.88,
    );

    _pageController.addListener(_onPageScroll);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    );
    _tabsAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
    );
    _cardAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();
  }

  void _onPageScroll() {
    if (_pageController.hasClients && _pageController.page != null) {
      setState(() {
        _pageOffset = _pageController.page!;
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  String _planName(String key) {
    final l10n = context.l10n;
    switch (key) {
      case 'basic':
        return l10n.plans_basic;
      case 'pro':
        return l10n.plans_pro;
      case 'premium':
        return l10n.plans_premium;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final currentPlan = plans[_currentPage];
    final bgTint = isDark ? currentPlan.darkBgTint : currentPlan.lightBgTint;

    return AnimatedContainer(
      duration: AppTheme.durationSlow,
      curve: Curves.easeInOut,
      color: bgTint,
      child: Stack(
        children: [
          PlanBackgroundOrbs(
            accent: currentPlan.accent,
            pageOffset: _pageOffset,
          ),

          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded,
                    color: colors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              actions: const [SizedBox(width: 48)],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _headerAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_headerAnimation),
                      child: _buildHeader(colors),
                    ),
                  ),

                  const SizedBox(height: 24),

                  FadeTransition(
                    opacity: _tabsAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_tabsAnimation),
                      child: PlanTabSelector(
                        currentIndex: _currentPage,
                        plans: plans,
                        onTap: (index) {
                          HapticFeedback.lightImpact();
                          _pageController.animateToPage(
                            index,
                            duration: AppTheme.durationSlow,
                            curve: Curves.easeOutCubic,
                          );
                        },
                        planName: _planName,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: FadeTransition(
                      opacity: _cardAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(_cardAnimation),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: plans.length,
                          onPageChanged: (index) {
                            HapticFeedback.selectionClick();
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: PlanCard(
                                plan: plans[index],
                                planName: _planName(plans[index].nameKey),
                                isActive: index == _currentPage,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColorsExtension colors) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            l10n.plans_title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: -1.0,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.plans_subtitle,
            style: TextStyle(
              fontSize: 15,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
