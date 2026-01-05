import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/providers/route_provider.dart';
import '../widgets/multi_date_calendar.dart';
import '../widgets/selected_dates_chips.dart';

class CreateRouteScreen extends ConsumerStatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  ConsumerState<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends ConsumerState<CreateRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _tripDurationController = TextEditingController();
  final _notesController = TextEditingController();

  List<DateTime> _selectedDepartureDates = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _tripDurationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartureDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una fecha de salida'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final tripDuration = int.tryParse(_tripDurationController.text);

    final success = await ref.read(routesProvider.notifier).createRoute(
      origin: _originController.text.trim(),
      destination: _destinationController.text.trim(),
      departureDates: _selectedDepartureDates,
      tripDurationHours: tripDuration,
      notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ruta creada correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear la ruta'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          'Nueva Ruta',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
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
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Origin and Destination
              _buildSectionTitle(context, 'Origen y Destino'),
              const SizedBox(height: 8),

              // Origin
              TextFormField(
                controller: _originController,
                decoration: _buildInputDecoration(
                  context,
                  'Ciudad de origen',
                  Icons.trip_origin,
                  iconColor: AppColors.success,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa la ciudad de origen';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Arrow indicator
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_downward,
                    color: colors.textMuted,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Destination
              TextFormField(
                controller: _destinationController,
                decoration: _buildInputDecoration(
                  context,
                  'Ciudad de destino',
                  Icons.location_on,
                  iconColor: AppColors.error,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa la ciudad de destino';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Departure Dates Section
              _buildSectionTitle(context, 'Fechas de salida'),
              const SizedBox(height: 4),
              Text(
                'Selecciona una o mas fechas en el calendario',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 12),

              // Selected dates chips
              SelectedDatesChips(
                dates: _selectedDepartureDates,
                onRemove: (date) {
                  setState(() {
                    _selectedDepartureDates.remove(date);
                  });
                },
              ),

              const SizedBox(height: 16),

              // Calendar
              MultiDateCalendar(
                selectedDates: _selectedDepartureDates,
                onDatesChanged: (dates) {
                  setState(() {
                    _selectedDepartureDates = dates;
                  });
                },
                firstAllowedDate: DateTime.now(),
              ),

              const SizedBox(height: 24),

              // Trip Duration
              _buildSectionTitle(context, 'Duracion del viaje (opcional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tripDurationController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration(
                  context,
                  'Numero de horas',
                  Icons.schedule,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tiempo estimado de viaje en horas',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textMuted,
                ),
              ),

              const SizedBox(height: 24),

              // Notes
              _buildSectionTitle(context, 'Notas (opcional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  context,
                  'Observaciones adicionales...',
                  Icons.notes,
                ),
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _selectedDepartureDates.isEmpty
                              ? 'Crear Ruta'
                              : 'Crear Ruta (${_selectedDepartureDates.length} ${_selectedDepartureDates.length == 1 ? 'fecha' : 'fechas'})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context.colors.textSecondary,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context,
    String hint,
    IconData icon, {
    Color? iconColor,
  }) {
    final colors = context.colors;

    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: iconColor ?? colors.textMuted),
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
    );
  }
}
