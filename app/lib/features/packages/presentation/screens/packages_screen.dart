import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/providers/package_provider.dart';
import '../../data/models/package_model.dart';
import '../widgets/bulk_action_bar.dart';
import '../widgets/package_card_v2.dart';
import '../widgets/status_filter_chips.dart';

class PackagesScreen extends ConsumerStatefulWidget {
  const PackagesScreen({super.key});

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends ConsumerState<PackagesScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _expandedPackageId;

  final _scrollController = ScrollController(initialScrollOffset: 76.0);
  final double _hiddenHeaderHeight = 76.0;

  // Animation controller for list transitions (slide lateral)
  late AnimationController _listAnimationController;
  late Animation<double> _slideAnimation;
  int _previousFilterIndex = -1; // -1 = "Todos", 0-3 = status index
  bool _slideFromRight = true;

  @override
  void initState() {
    super.initState();

    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    );
    _listAnimationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(packagesProvider.notifier).loadPackages();
    });
  }

  void _collapseAll() {
    if (_expandedPackageId != null) {
      setState(() => _expandedPackageId = null);
    }
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _animateListRefresh(int newFilterIndex) {
    // Determine slide direction based on filter position
    _slideFromRight = newFilterIndex > _previousFilterIndex;
    _previousFilterIndex = newFilterIndex;
    _listAnimationController.reset();
    _listAnimationController.forward();
  }

  List<PackageModel> _filterPackages(List<PackageModel> packages) {
    if (_searchQuery.isEmpty) return packages;
    final query = _searchQuery.toLowerCase();
    return packages.where((p) {
      return p.trackingCode.toLowerCase().contains(query) ||
          p.senderName.toLowerCase().contains(query) ||
          p.receiverName.toLowerCase().contains(query) ||
          (p.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _handleBulkAdvance() async {
    final result =
        await ref.read(packagesProvider.notifier).bulkAdvanceToNextStatus();

    if (!mounted) return;

    if (result.success) {
      ref.invalidate(packageCountsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.packages_bulkUpdateSuccess(result.count)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final packagesState = ref.watch(packagesProvider);
    final countsAsync = ref.watch(packageCountsProvider);
    final filteredPackages = _filterPackages(packagesState.packages);

    return Scaffold(
      backgroundColor: isDark ? colors.background : const Color(0xFFF4F5F6),
      body: Stack(
        children: [
          Column(
            children: [
              // Header (fixed) con botón de selección
              AppHeader(
                title: context.l10n.packages_title,
                showMenu: false,
                trailing: _SelectionModeButton(
                  isSelectionMode: packagesState.isSelectionMode,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (packagesState.isSelectionMode) {
                      ref.read(packagesProvider.notifier).exitSelectionMode();
                    } else {
                      ref.read(packagesProvider.notifier).enterSelectionMode();
                    }
                  },
                ),
              ),
              // Scrollable content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(packageCountsProvider);
                    await ref.read(packagesProvider.notifier).loadPackages();
                  },
                  color: AppColors.primary,
                  child: GestureDetector(
                    onTap: _collapseAll,
                    behavior: HitTestBehavior.translucent,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Search bar (Hidden by default via initialScrollOffset)
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: _hiddenHeaderHeight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 12, 20, 12),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) =>
                                    setState(() => _searchQuery = value),
                                decoration: InputDecoration(
                                  hintText:
                                      context.l10n.packages_searchPlaceholder,
                                  prefixIcon: Icon(Icons.search,
                                      color: colors.textMuted),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear,
                                              color: colors.textMuted),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _searchQuery = '');
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: colors.background,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Filter chips
                        SliverToBoxAdapter(
                          child: StatusFilterChips(
                            selectedStatus: packagesState.filterStatus,
                            onStatusSelected: (status) {
                              // Calculate filter index: null = -1, otherwise status index
                              final newIndex = status == null
                                  ? -1
                                  : PackageStatus.values.indexOf(status);
                              _animateListRefresh(newIndex);
                              ref
                                  .read(packagesProvider.notifier)
                                  .filterByStatus(status);
                            },
                            counts: countsAsync.valueOrNull,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 8)),

                        // Package list
                        _buildSliverBody(packagesState, filteredPackages),

                        // Ensure content is always taller than viewport to allow hiding the search bar
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: SizedBox.shrink(),
                        ),
                        // Extra padding when bulk action bar is visible
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: _hiddenHeaderHeight +
                                (packagesState.isSelectionMode ? 80 : 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Bulk action bar (aparece desde abajo)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: packagesState.isSelectionMode ? 0 : -100,
            child: BulkActionBar(
              selectedCount: packagesState.selectedIds.length,
              isLoading: packagesState.isBulkUpdating,
              onCancel: () =>
                  ref.read(packagesProvider.notifier).exitSelectionMode(),
              onSelectAll: () =>
                  ref.read(packagesProvider.notifier).selectAllWithNextStatus(),
              onAdvanceStatus: _handleBulkAdvance,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverBody(PackagesState state, List<PackageModel> packages) {
    if (state.isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.error != null) {
      return SliverFillRemaining(
        child: _ErrorState(
          message: state.error!,
          onRetry: () => ref.read(packagesProvider.notifier).loadPackages(),
        ),
      );
    }

    if (packages.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.inventory_2_outlined,
          title: (state.filterStatus != null || _searchQuery.isNotEmpty)
              ? context.l10n.packages_emptyFilterTitle
              : context.l10n.packages_emptyTitle,
          subtitle: (state.filterStatus != null || _searchQuery.isNotEmpty)
              ? context.l10n.packages_emptyFilterMessage
              : context.l10n.packages_emptyMessage,
        ),
      );
    }

    // Slide lateral animation applied to the entire container
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: Tween<Offset>(
          begin: _slideFromRight ? const Offset(1, 0) : const Offset(-1, 0),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: FadeTransition(
          opacity: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: packages.map((package) {
                return PackageCardV2(
                  package: package,
                  isExpanded: _expandedPackageId == package.id,
                  onExpand: () =>
                      setState(() => _expandedPackageId = package.id),
                  onTap: () => context.push('/packages/${package.id}'),
                  onStatusChange: (status) async {
                    await ref
                        .read(packagesProvider.notifier)
                        .updateStatus(package.id, status);
                    ref.invalidate(packageCountsProvider);
                  },
                  isSelectionMode: state.isSelectionMode,
                  isSelected: state.selectedIds.contains(package.id),
                  onSelectionToggle: () => ref
                      .read(packagesProvider.notifier)
                      .toggleSelection(package.id),
                  onLongPress: () => ref
                      .read(packagesProvider.notifier)
                      .enterSelectionMode(package.id),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón de activar/desactivar modo selección en el header.
class _SelectionModeButton extends StatelessWidget {
  final bool isSelectionMode;
  final VoidCallback onTap;

  const _SelectionModeButton({
    required this.isSelectionMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelectionMode
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isSelectionMode ? Icons.check_box : Icons.checklist_outlined,
          size: 22,
          color: isSelectionMode ? AppColors.primary : colors.textSecondary,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.common_retry),
            ),
          ],
        ),
      ),
    );
  }
}

