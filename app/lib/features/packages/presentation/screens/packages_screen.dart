import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../domain/providers/package_provider.dart';
import '../../data/models/package_model.dart';
import '../widgets/package_card.dart';
import '../widgets/status_filter_chips.dart';

class PackagesScreen extends ConsumerStatefulWidget {
  const PackagesScreen({super.key});

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends ConsumerState<PackagesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

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
    final packagesState = ref.watch(packagesProvider);
    final filteredPackages = _filterPackages(packagesState.packages);

    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: [
          // Header
          AppHeader(
            title: 'Pedidos',
            showLanguageSelector: false,
            showMenu: false,
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Buscar por código, remitente o destinatario...',
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          StatusFilterChips(
            selectedStatus: packagesState.filterStatus,
            onStatusSelected: (status) {
              ref.read(packagesProvider.notifier).filterByStatus(status);
            },
          ),
          const SizedBox(height: 8),
          // Package list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(packagesProvider.notifier).loadPackages(),
              color: AppColors.primary,
              child: _buildBody(packagesState, filteredPackages),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PackagesState state, List<PackageModel> packages) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      return _ErrorState(
        message: state.error!,
        onRetry: () => ref.read(packagesProvider.notifier).loadPackages(),
      );
    }

    if (packages.isEmpty) {
      return _EmptyState(
        hasFilter: state.filterStatus != null || _searchQuery.isNotEmpty,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        return PackageCard(
          package: package,
          onTap: () => context.push('/packages/${package.id}'),
          onStatusChange: (status) {
            ref.read(packagesProvider.notifier).updateStatus(package.id, status);
          },
        );
      },
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
              label: const Text('Reintentar'),
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
              hasFilter ? 'Sin resultados' : 'Sin paquetes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'No se encontraron paquetes con los filtros aplicados'
                  : 'Usa el botón + para registrar un nuevo paquete',
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
