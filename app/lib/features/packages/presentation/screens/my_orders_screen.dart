import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/package_model.dart';
import '../../domain/providers/my_orders_provider.dart';
import '../widgets/package_card_v2.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(myOrdersProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myOrders_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myOrdersProvider);
        },
        child: ordersAsync.when(
          data: (orders) {
            final filteredOrders = _statusFilter != null
                ? orders
                    .where((o) => o.status.apiValue == _statusFilter)
                    .toList()
                : orders;

            if (filteredOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusFilter != null
                          ? l10n.myOrders_noOrdersFiltered
                          : l10n.myOrders_noOrders,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.myOrders_noOrdersDesc,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final package = filteredOrders[index];
                return Column(
                  children: [
                    PackageCardV2(
                      package: package,
                      onTap: () {
                        context.push('/packages/${package.id}');
                      },
                      onStatusChange: (status) {
                        // Read-only for customers
                      },
                    ),
                    if (_shouldShowRoleBadge(package)) ...[
                      const SizedBox(height: 4),
                      _buildRoleBadge(package),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  l10n.myOrders_errorLoading,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(myOrdersProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.myOrders_retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowRoleBadge(PackageModel package) {
    // Mostrar badge si el usuario es tanto remitente como destinatario
    // o si queremos destacar el rol en cada paquete
    return package.senderContactId != null &&
        package.receiverContactId != null &&
        package.senderContactId != package.receiverContactId;
  }

  Widget _buildRoleBadge(PackageModel package) {
    final l10n = context.l10n;
    final authState = ref.read(authProvider);
    final userContactId = authState
        .user?.id; // Simplificado - en realidad necesitarías user.contact.id

    final isSender = package.senderContactId == userContactId;
    final isReceiver = package.receiverContactId == userContactId;

    String label;
    Color color;

    if (isSender && isReceiver) {
      label = l10n.myOrders_senderAndReceiver;
      color = AppColors.primary;
    } else if (isSender) {
      label = l10n.myOrders_youAreSender;
      color = AppColors.info;
    } else {
      label = l10n.myOrders_youAreReceiver;
      color = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSender ? Icons.north_east : Icons.south_west,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.myOrders_filterByStatus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(null, l10n.myOrders_filterAll),
            _buildFilterOption('pending', l10n.myOrders_filterPending),
            _buildFilterOption('in_transit', l10n.myOrders_filterInTransit),
            _buildFilterOption('delivered', l10n.myOrders_filterDelivered),
            _buildFilterOption('delayed', l10n.myOrders_filterDelayed),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String? value, String label) {
    final isSelected = _statusFilter == value;

    return RadioListTile<String?>(
      title: Text(label),
      value: value,
      groupValue: _statusFilter,
      selected: isSelected,
      onChanged: (newValue) {
        setState(() {
          _statusFilter = newValue;
        });
        Navigator.pop(context);
      },
    );
  }
}
