import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/package_model.dart';
import '../../domain/providers/package_provider.dart';

class PackageDetailScreen extends ConsumerWidget {
  final int packageId;

  const PackageDetailScreen({super.key, required this.packageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageAsync = ref.watch(packageDetailProvider(packageId));
    final historyAsync = ref.watch(packageHistoryProvider(packageId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detalle del Paquete',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        elevation: 0,
      ),
      body: packageAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error al cargar el paquete'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(packageDetailProvider(packageId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (package) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(package: package),
              const SizedBox(height: 16),
              _SenderReceiverCard(package: package),
              const SizedBox(height: 16),
              if (package.description != null || package.notes != null)
                _DetailsCard(package: package),
              const SizedBox(height: 16),
              _HistoryCard(historyAsync: historyAsync),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final PackageModel package;

  const _HeaderCard({required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Codigo de Seguimiento',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.trackingCode,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              _StatusBadge(status: package.status),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'Peso',
                  value: package.weight != null
                      ? '${package.weight} kg'
                      : 'No especificado',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'Valor Declarado',
                  value: package.declaredValue != null
                      ? '${package.declaredValue?.toStringAsFixed(2)} EUR'
                      : 'No especificado',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PackageStatus status;

  const _StatusBadge({required this.status});

  Color _getStatusColor() {
    switch (status) {
      case PackageStatus.pending:
        return AppColors.textMuted;
      case PackageStatus.pickedUp:
        return AppColors.info;
      case PackageStatus.inTransit:
        return AppColors.warning;
      case PackageStatus.inWarehouse:
        return Colors.purple;
      case PackageStatus.outForDelivery:
        return Colors.indigo;
      case PackageStatus.delivered:
        return AppColors.success;
      case PackageStatus.cancelled:
        return AppColors.error;
      case PackageStatus.returned:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SenderReceiverCard extends StatelessWidget {
  final PackageModel package;

  const _SenderReceiverCard({required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Remitente y Destinatario',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PersonInfo(
                  icon: Icons.upload,
                  title: 'Remitente',
                  name: package.senderName,
                  phone: package.senderPhone,
                  address: package.senderAddress,
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_forward,
                  color: AppColors.textMuted,
                ),
              ),
              Expanded(
                child: _PersonInfo(
                  icon: Icons.download,
                  title: 'Destinatario',
                  name: package.receiverName,
                  phone: package.receiverPhone,
                  address: package.receiverAddress,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String name;
  final String? phone;
  final String? address;

  const _PersonInfo({
    required this.icon,
    required this.title,
    required this.name,
    this.phone,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (phone != null) ...[
          const SizedBox(height: 4),
          Text(
            phone!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
        if (address != null) ...[
          const SizedBox(height: 4),
          Text(
            address!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final PackageModel package;

  const _DetailsCard({required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (package.description != null) ...[
            const SizedBox(height: 12),
            _InfoItem(label: 'Descripcion', value: package.description!),
          ],
          if (package.notes != null) ...[
            const SizedBox(height: 12),
            _InfoItem(label: 'Notas', value: package.notes!),
          ],
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> historyAsync;

  const _HistoryCard({required this.historyAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historial de Estados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          historyAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (_, __) => const Text('Error al cargar historial'),
            data: (history) => history.isEmpty
                ? const Text('Sin historial')
                : Column(
                    children: history
                        .map((item) => _HistoryItem(
                              status: item['status'] as String,
                              notes: item['notes'] as String?,
                              date: DateTime.parse(item['created_at']),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String status;
  final String? notes;
  final DateTime date;

  const _HistoryItem({
    required this.status,
    this.notes,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PackageStatus.fromString(status).displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (notes != null)
                  Text(
                    notes!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                Text(
                  dateFormat.format(date),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
