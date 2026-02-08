import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/package_box_icon.dart';
import '../../domain/providers/package_provider.dart';
import '../../data/models/package_model.dart';
import '../widgets/bulk_action_bar.dart';
import '../widgets/expandable_filter_bar.dart';
import '../widgets/package_card_v2.dart';

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

  final _scrollController = ScrollController();

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

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(packagesProvider.notifier).loadPackages(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(packagesProvider.notifier).loadMore();
    }
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
    _slideFromRight = newFilterIndex > _previousFilterIndex;
    _previousFilterIndex = newFilterIndex;
    _listAnimationController.reset();
    _listAnimationController.forward();
  }

  List<PackageModel> _filterPackages(List<PackageModel> packages) {
    var result = packages;

    final filterCities = ref.read(packagesProvider).filterCities;
    if (filterCities.isNotEmpty) {
      result = result.where((p) {
        final senderMatch =
            p.senderCity != null && filterCities.contains(p.senderCity);
        final receiverMatch =
            p.receiverCity != null && filterCities.contains(p.receiverCity);
        return senderMatch || receiverMatch;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.trackingCode.toLowerCase().contains(query) ||
            p.senderName.toLowerCase().contains(query) ||
            p.receiverName.toLowerCase().contains(query) ||
            (p.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return result;
  }

  Future<void> _handleBulkAdvance() async {
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
    final isDark = context.isDarkMode;
    final packagesState = ref.watch(packagesProvider);
    final countsAsync = ref.watch(packageCountsProvider);
    final filteredPackages = _filterPackages(packagesState.packages);

    return Scaffold(
      backgroundColor: isDark ? colors.background : const Color(0xFFF4F5F6),
      body: Stack(
        children: [
          Column(
            children: [
              AppHeader(
                icon: Icons.inventory_2_rounded,
                iconWidget: const PackageBoxIcon(size: 22, color: Colors.white, filled: true),
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
              ExpandableFilterBar(
                searchController: _searchController,
                searchQuery: _searchQuery,
                onSearchChanged: (value) =>
                    setState(() => _searchQuery = value),
                selectedStatus: packagesState.filterStatus,
                onStatusSelected: (status) {
                  final newIndex = status == null
                      ? -1
                      : PackageStatus.values.indexOf(status);
                  _animateListRefresh(newIndex);
                  ref.read(packagesProvider.notifier).filterByStatus(status);
                },
                counts: countsAsync.valueOrNull,
                onFilterChanged: () {
                  _listAnimationController.reset();
                  _listAnimationController.forward();
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(packageCountsProvider);
                    await ref.read(packagesProvider.notifier).loadPackages(refresh: true);
                  },
                  color: AppColors.primary,
                  child: GestureDetector(
                    onTap: _collapseAll,
                    behavior: HitTestBehavior.translucent,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        const SliverToBoxAdapter(
                            child: SizedBox(height: 8)),
                        _buildSliverBody(packagesState, filteredPackages),
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: SizedBox.shrink(),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height:
                                packagesState.isSelectionMode ? 80 : 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    if (state.isLoading && state.packages.isEmpty) {
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

    final hasAnyFilter = state.filterStatus != null ||
        state.tripId != null ||
        state.filterCities.isNotEmpty ||
        _searchQuery.isNotEmpty;

    if (packages.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.inventory_2_outlined,
          iconWidget: PackageBoxIcon(
            size: 40,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          title: hasAnyFilter
              ? context.l10n.packages_emptyFilterTitle
              : context.l10n.packages_emptyTitle,
          subtitle: hasAnyFilter
              ? context.l10n.packages_emptyFilterMessage
              : context.l10n.packages_emptyMessage,
        ),
      );
    }

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
              children: [
                ...packages.map((package) {
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
                }),
                if (state.hasMore)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
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
