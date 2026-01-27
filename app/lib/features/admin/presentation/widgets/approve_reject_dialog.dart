import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/styled_form_field.dart';
import '../../../auth/data/models/user_model.dart';

class ApproveRejectDialog extends StatefulWidget {
  final UserModel driver;
  final bool isApproval;

  const ApproveRejectDialog({
    super.key,
    required this.driver,
    required this.isApproval,
  });

  @override
  State<ApproveRejectDialog> createState() => _ApproveRejectDialogState();
}

class _ApproveRejectDialogState extends State<ApproveRejectDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icono y título
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.isApproval
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isApproval
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: widget.isApproval
                        ? AppColors.primary
                        : Colors.red.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.isApproval
                        ? 'Aprobar conductor'
                        : 'Rechazar conductor',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Mensaje
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: widget.isApproval
                        ? '¿Estás seguro que deseas aprobar a '
                        : '¿Estás seguro que deseas rechazar a ',
                  ),
                  TextSpan(
                    text: widget.driver.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.isApproval
                        ? ' como conductor? Recibirá un email de confirmación y podrá acceder a todas las funciones de la app.'
                        : ' como conductor? Recibirá un email notificándole del rechazo.',
                  ),
                ],
              ),
            ),

            // Campo de razón (solo para rechazo)
            if (!widget.isApproval) ...[
              const SizedBox(height: 24),
              StyledFormField(
                controller: _reasonController,
                label: 'Motivo del rechazo (opcional)',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                hint: 'Ej: Documentación incompleta',
              ),
            ],

            const SizedBox(height: 32),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      widget.isApproval ? true : _reasonController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isApproval
                        ? AppColors.primary
                        : Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(widget.isApproval ? 'Aprobar' : 'Rechazar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
