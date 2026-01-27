import 'package:flutter/material.dart';

import '../../../../shared/widgets/status_chip.dart';

enum TripStatus {
  planned,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case TripStatus.planned:
        return 'Planificado';
      case TripStatus.inProgress:
        return 'En progreso';
      case TripStatus.completed:
        return 'Completado';
      case TripStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get displayNameUk {
    switch (this) {
      case TripStatus.planned:
        return 'Запланований';
      case TripStatus.inProgress:
        return 'В дорозі';
      case TripStatus.completed:
        return 'Завершено';
      case TripStatus.cancelled:
        return 'Скасовано';
    }
  }

  String get chipLabel {
    switch (this) {
      case TripStatus.planned:
        return 'PLANNED';
      case TripStatus.inProgress:
        return 'EN ROUTE';
      case TripStatus.completed:
        return 'COMPLETED';
      case TripStatus.cancelled:
        return 'CANCELLED';
    }
  }

  ChipVariant get chipVariant {
    switch (this) {
      case TripStatus.planned:
        return ChipVariant.blue;
      case TripStatus.inProgress:
        return ChipVariant.orange;
      case TripStatus.completed:
        return ChipVariant.green;
      case TripStatus.cancelled:
        return ChipVariant.gray;
    }
  }

  String get apiValue {
    switch (this) {
      case TripStatus.planned:
        return 'planned';
      case TripStatus.inProgress:
        return 'in_progress';
      case TripStatus.completed:
        return 'completed';
      case TripStatus.cancelled:
        return 'cancelled';
    }
  }

  static TripStatus fromString(String value) {
    switch (value) {
      case 'planned':
        return TripStatus.planned;
      case 'in_progress':
        return TripStatus.inProgress;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.planned;
    }
  }

  Color get color {
    switch (this) {
      case TripStatus.planned:
        return const Color(0xFF3B82F6); // blue
      case TripStatus.inProgress:
        return const Color(0xFFF59E0B); // amber
      case TripStatus.completed:
        return const Color(0xFF10B981); // emerald
      case TripStatus.cancelled:
        return const Color(0xFF6B7280); // gray
    }
  }

  IconData get icon {
    switch (this) {
      case TripStatus.planned:
        return Icons.schedule;
      case TripStatus.inProgress:
        return Icons.directions_car;
      case TripStatus.completed:
        return Icons.check_circle;
      case TripStatus.cancelled:
        return Icons.cancel;
    }
  }
}
