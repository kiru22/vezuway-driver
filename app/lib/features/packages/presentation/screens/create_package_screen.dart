import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/providers/package_provider.dart';
import '../../../routes/domain/providers/route_provider.dart';
import '../../../routes/data/models/route_model.dart';

class CreatePackageScreen extends ConsumerStatefulWidget {
  const CreatePackageScreen({super.key});

  @override
  ConsumerState<CreatePackageScreen> createState() => _CreatePackageScreenState();
}

class _CreatePackageScreenState extends ConsumerState<CreatePackageScreen> {
  final _formKey = GlobalKey<FormState>();

  // Sender fields
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _senderAddressController = TextEditingController();

  // Receiver fields
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _receiverAddressController = TextEditingController();

  // Package details
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _declaredValueController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedRouteId;
  bool _isLoading = false;

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _senderAddressController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _receiverAddressController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _declaredValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final weight = double.tryParse(_weightController.text);
    final declaredValue = double.tryParse(_declaredValueController.text);

    final success = await ref.read(packagesProvider.notifier).createPackage(
      routeId: _selectedRouteId,
      senderName: _senderNameController.text.trim(),
      senderPhone: _senderPhoneController.text.isNotEmpty
          ? _senderPhoneController.text.trim()
          : null,
      senderAddress: _senderAddressController.text.isNotEmpty
          ? _senderAddressController.text.trim()
          : null,
      receiverName: _receiverNameController.text.trim(),
      receiverPhone: _receiverPhoneController.text.isNotEmpty
          ? _receiverPhoneController.text.trim()
          : null,
      receiverAddress: _receiverAddressController.text.isNotEmpty
          ? _receiverAddressController.text.trim()
          : null,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      weight: weight,
      declaredValue: declaredValue,
      notes: _notesController.text.isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paquete creado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(packagesProvider).error ?? 'Error al crear el paquete'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final routes = ref.watch(routesProvider).routes
        .where((r) => r.status == RouteStatus.planned || r.status == RouteStatus.inProgress)
        .toList();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Nuevo Paquete',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Text(
                      'Guardar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Route selector
            _SectionTitle(title: 'Asignar a ruta', icon: Icons.route_rounded),
            const SizedBox(height: 12),
            _RouteDropdown(
              routes: routes,
              selectedRouteId: _selectedRouteId,
              onChanged: (id) => setState(() => _selectedRouteId = id),
            ),
            const SizedBox(height: 24),

            // Sender section
            _SectionTitle(title: 'Remitente', icon: Icons.person_outline),
            const SizedBox(height: 12),
            _FormField(
              controller: _senderNameController,
              label: 'Nombre *',
              hint: 'Nombre del remitente',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _senderPhoneController,
              label: 'Teléfono',
              hint: '+34 600 000 000',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _senderAddressController,
              label: 'Dirección',
              hint: 'Dirección de recogida',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Receiver section
            _SectionTitle(title: 'Destinatario', icon: Icons.person_pin_circle_outlined),
            const SizedBox(height: 12),
            _FormField(
              controller: _receiverNameController,
              label: 'Nombre *',
              hint: 'Nombre del destinatario',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _receiverPhoneController,
              label: 'Teléfono',
              hint: '+380 00 000 0000',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _receiverAddressController,
              label: 'Dirección',
              hint: 'Dirección de entrega',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Package details section
            _SectionTitle(title: 'Detalles del paquete', icon: Icons.inventory_2_outlined),
            const SizedBox(height: 12),
            _FormField(
              controller: _descriptionController,
              label: 'Descripción',
              hint: 'Contenido del paquete',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    controller: _weightController,
                    label: 'Peso (kg)',
                    hint: '0.0',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    controller: _declaredValueController,
                    label: 'Valor declarado (€)',
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _notesController,
              label: 'Notas',
              hint: 'Notas adicionales...',
              maxLines: 3,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: colors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _RouteDropdown extends StatelessWidget {
  final List<RouteModel> routes;
  final int? selectedRouteId;
  final ValueChanged<int?> onChanged;

  const _RouteDropdown({
    required this.routes,
    required this.selectedRouteId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedRouteId,
          hint: Text(
            'Sin asignar',
            style: TextStyle(color: colors.textMuted),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: colors.textMuted),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'Sin asignar',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            ...routes.map((route) => DropdownMenuItem<int?>(
              value: route.id,
              child: Text(
                '${route.name} (${route.status.displayName})',
                style: TextStyle(color: colors.textPrimary),
              ),
            )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
