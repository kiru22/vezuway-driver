import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../domain/providers/package_provider.dart';
import '../../data/models/package_model.dart';
import '../widgets/package_card_v2.dart';
import '../widgets/status_filter_chips.dart';

class PackagesScreen extends ConsumerStatefulWidget {
  const PackagesScreen({super.key});

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends ConsumerState<PackagesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final _scrollController = ScrollController(initialScrollOffset: 76.0);
  final double _hiddenHeaderHeight = 76.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(packagesProvider.notifier).loadPackages();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final packagesState = ref.watch(packagesProvider);
    final filteredPackages = _filterPackages(packagesState.packages);

    return Scaffold(
      backgroundColor: isDark ? colors.background : const Color(0xFFF4F5F6),
      body: Column(
        children: [
          // Header (fixed)
          AppHeader(
            title: context.l10n.packages_title,
            showMenu: false,
          ),
          // Scrollable content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(packagesProvider.notifier).loadPackages(),
              color: AppColors.primary,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Search bar (Hidden by default via initialScrollOffset)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: _hiddenHeaderHeight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: context.l10n.packages_searchPlaceholder,
                            prefixIcon: Icon(Icons.search, color: colors.textMuted),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: colors.textMuted),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: colors.background,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                        ref.read(packagesProvider.notifier).filterByStatus(status);
                      },
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
                  SliverToBoxAdapter(child: SizedBox(height: _hiddenHeaderHeight)),
                ],
              ),
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
        child: _EmptyState(
          hasFilter: state.filterStatus != null || _searchQuery.isNotEmpty,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final package = packages[index];
            return PackageCardV2(
              package: package,
              onTap: () => context.go('/packages/${package.id}'),
              onStatusChange: (status) {
                ref.read(packagesProvider.notifier).updateStatus(package.id, status);
              },
            );
          },
          childCount: packages.length,
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

class _EmptyState extends StatelessWidget {
  final bool hasFilter;

  const _EmptyState({this.hasFilter = false});

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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilter ? context.l10n.packages_emptyFilterTitle : context.l10n.packages_emptyTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? context.l10n.packages_emptyFilterMessage
                  : context.l10n.packages_emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
