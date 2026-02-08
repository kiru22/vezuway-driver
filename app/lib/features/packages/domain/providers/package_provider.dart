import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/extensions/package_status_extensions.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/package_model.dart';
import '../../data/repositories/package_repository.dart';

final packageRepositoryProvider = Provider<PackageRepository>((ref) {
  return PackageRepository(ref.read(apiServiceProvider));
});

class PackagesState {
  final List<PackageModel> packages;
  final bool isLoading;
  final String? error;
  final PackageStatus? filterStatus;
  final String? tripId;
  final Set<String> filterCities;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final bool isBulkUpdating;

  const PackagesState({
    this.packages = const [],
    this.isLoading = false,
    this.error,
    this.filterStatus,
    this.tripId,
    this.filterCities = const {},
    this.isSelectionMode = false,
    this.selectedIds = const {},
    this.isBulkUpdating = false,
  });

  PackagesState copyWith({
    List<PackageModel>? packages,
    bool? isLoading,
    String? error,
    PackageStatus? filterStatus,
    bool clearFilter = false,
    String? tripId,
    bool clearTripId = false,
    Set<String>? filterCities,
    bool? isSelectionMode,
    Set<String>? selectedIds,
    bool? isBulkUpdating,
  }) {
    return PackagesState(
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
      tripId: clearTripId ? null : (tripId ?? this.tripId),
      filterCities: filterCities ?? this.filterCities,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
      isBulkUpdating: isBulkUpdating ?? this.isBulkUpdating,
    );
  }
}

class PackagesNotifier extends StateNotifier<PackagesState> {
  final PackageRepository _repository;
  bool _isInitialized = false;

  PackagesNotifier(this._repository) : super(const PackagesState()) {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await loadPackages();
  }

  Future<void> loadPackages() async {
    // Prevent concurrent loads
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final packages = await _repository.getPackages(
        status: state.filterStatus,
        tripId: state.tripId,
      );
      state = state.copyWith(packages: packages, isLoading: false);
    } catch (e, stack) {
      debugPrint('PackagesNotifier.loadPackages error: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar paquetes',
      );
    }
  }

  Future<void> filterByStatus(PackageStatus? status) async {
    if (status == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterStatus: status);
    }
    await loadPackages();
  }

  Future<void> filterByTrip(String? tripId) async {
    if (tripId == null) {
      state = state.copyWith(clearTripId: true);
    } else {
      state = state.copyWith(tripId: tripId);
    }
    await loadPackages();
  }

  void toggleCityFilter(String city) {
    final newCities = Set<String>.from(state.filterCities);
    if (newCities.contains(city)) {
      newCities.remove(city);
    } else {
      newCities.add(city);
    }
    state = state.copyWith(filterCities: newCities);
  }

  void clearCityFilter() {
    state = state.copyWith(filterCities: {});
  }

  Future<bool> createPackage({
    String? tripId,
    String? senderContactId,
    String? receiverContactId,
    String? senderName,
    String? senderPhone,
    String? senderCity,
    String? senderCountry,
    String? senderAddress,
    required String receiverName,
    String? receiverPhone,
    String? receiverCity,
    String? receiverCountry,
    String? receiverAddress,
    double? weight,
    int? lengthCm,
    int? widthCm,
    int? heightCm,
    int? quantity,
    double? declaredValue,
    String? description,
    String? novaPostNumber,
    List<Uint8List>? images,
  }) async {
    try {
      final newPackage = await _repository.createPackage(
        tripId: tripId,
        senderContactId: senderContactId,
        receiverContactId: receiverContactId,
        senderName: senderName,
        senderPhone: senderPhone,
        senderCity: senderCity,
        senderCountry: senderCountry,
        senderAddress: senderAddress,
        receiverName: receiverName,
        receiverPhone: receiverPhone,
        receiverCity: receiverCity,
        receiverCountry: receiverCountry,
        receiverAddress: receiverAddress,
        weight: weight,
        lengthCm: lengthCm,
        widthCm: widthCm,
        heightCm: heightCm,
        quantity: quantity,
        declaredValue: declaredValue,
        description: description,
        novaPostNumber: novaPostNumber,
        images: images,
      );
      state = state.copyWith(
        packages: [newPackage, ...state.packages],
      );
      return true;
    } catch (e, stack) {
      debugPrint('PackagesNotifier.createPackage error: $e');
      debugPrint('Stack trace: $stack');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateStatus(String id, PackageStatus status,
      {String? notes}) async {
    try {
      final updated = await _repository.updateStatus(id, status, notes: notes);
      final packages = state.packages.map((p) {
        return p.id == id ? updated : p;
      }).toList();
      state = state.copyWith(packages: packages);
      return true;
    } catch (e, stack) {
      debugPrint('PackagesNotifier.updateStatus error: $e\n$stack');
      return false;
    }
  }

  Future<bool> updatePackage({
    required String id,
    String? tripId,
    String? senderContactId,
    String? receiverContactId,
    String? senderName,
    String? senderPhone,
    String? senderCity,
    String? senderCountry,
    String? senderAddress,
    required String receiverName,
    String? receiverPhone,
    String? receiverCity,
    String? receiverCountry,
    String? receiverAddress,
    double? weight,
    int? lengthCm,
    int? widthCm,
    int? heightCm,
    int? quantity,
    double? declaredValue,
    String? description,
    String? novaPostNumber,
  }) async {
    try {
      final data = <String, dynamic>{
        if (tripId != null) 'trip_id': tripId,
        if (senderContactId != null) 'sender_contact_id': senderContactId,
        if (receiverContactId != null) 'receiver_contact_id': receiverContactId,
        if (senderName != null && senderName.isNotEmpty)
          'sender_name': senderName,
        if (senderPhone != null && senderPhone.isNotEmpty)
          'sender_phone': senderPhone,
        if (senderCity != null) 'sender_city': senderCity,
        if (senderCountry != null) 'sender_country': senderCountry,
        if (senderAddress != null) 'sender_address': senderAddress,
        'receiver_name': receiverName,
        if (receiverPhone != null) 'receiver_phone': receiverPhone,
        if (receiverCity != null) 'receiver_city': receiverCity,
        if (receiverCountry != null) 'receiver_country': receiverCountry,
        if (receiverAddress != null) 'receiver_address': receiverAddress,
        if (weight != null) 'weight_kg': weight,
        if (lengthCm != null) 'length_cm': lengthCm,
        if (widthCm != null) 'width_cm': widthCm,
        if (heightCm != null) 'height_cm': heightCm,
        if (quantity != null) 'quantity': quantity,
        if (declaredValue != null) 'declared_value': declaredValue,
        if (description != null) 'description': description,
        if (novaPostNumber != null) 'nova_post_number': novaPostNumber,
      };

      final updated = await _repository.updatePackage(id, data);
      final packages = state.packages.map((p) {
        return p.id == id ? updated : p;
      }).toList();
      state = state.copyWith(packages: packages);
      return true;
    } catch (e, stack) {
      debugPrint('PackagesNotifier.updatePackage error: $e');
      debugPrint('Stack trace: $stack');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deletePackage(String id) async {
    try {
      await _repository.deletePackage(id);
      final packages = state.packages.where((p) => p.id != id).toList();
      state = state.copyWith(packages: packages);
      return true;
    } catch (e, stack) {
      debugPrint('PackagesNotifier.deletePackage error: $e\n$stack');
      return false;
    }
  }

  /// Entra en modo selección
  void enterSelectionMode([String? initialId]) {
    state = state.copyWith(
      isSelectionMode: true,
      selectedIds: initialId != null ? {initialId} : {},
    );
  }

  /// Sale del modo selección y limpia la selección
  void exitSelectionMode() {
    state = state.copyWith(
      isSelectionMode: false,
      selectedIds: {},
    );
  }

  /// Alterna la selección de un paquete
  void toggleSelection(String id) {
    final newSelected = Set<String>.from(state.selectedIds);
    if (newSelected.contains(id)) {
      newSelected.remove(id);
    } else {
      newSelected.add(id);
    }
    state = state.copyWith(selectedIds: newSelected);
  }

  /// Selecciona todos los paquetes que tienen un nextStatus válido
  void selectAllWithNextStatus() {
    final selectableIds = state.packages
        .where((p) => p.status != PackageStatus.delivered)
        .map((p) => p.id)
        .toSet();
    state = state.copyWith(selectedIds: selectableIds);
  }

  /// Avanza los paquetes seleccionados a su siguiente estado
  /// Agrupa por nextStatus y hace llamadas API separadas
  Future<({bool success, int count, String? error})>
      bulkAdvanceToNextStatus() async {
    if (state.selectedIds.isEmpty) {
      return (success: false, count: 0, error: 'No hay paquetes seleccionados');
    }

    state = state.copyWith(isBulkUpdating: true);

    try {
      // Agrupar paquetes por su nextStatus
      final Map<PackageStatus, List<String>> groupedByNextStatus = {};

      for (final id in state.selectedIds) {
        final package = state.packages.firstWhere(
          (p) => p.id == id,
          orElse: () => throw Exception('Paquete no encontrado: $id'),
        );

        final nextStatus = package.status.nextStatus;
        if (nextStatus != null) {
          groupedByNextStatus.putIfAbsent(nextStatus, () => []).add(id);
        }
      }

      if (groupedByNextStatus.isEmpty) {
        return (
          success: false,
          count: 0,
          error: 'Ningún paquete puede avanzar de estado',
        );
      }

      // Ejecutar updates por grupo
      int totalUpdated = 0;
      for (final entry in groupedByNextStatus.entries) {
        final result = await _repository.bulkUpdateStatus(
          packageIds: entry.value,
          status: entry.key,
        );
        totalUpdated += result.updatedCount;
      }

      // Recargar la lista para obtener estados actualizados
      await loadPackages();

      // Salir del modo selección
      state = state.copyWith(
        isSelectionMode: false,
        selectedIds: {},
        isBulkUpdating: false,
      );

      return (success: true, count: totalUpdated, error: null);
    } catch (e, stack) {
      debugPrint('PackagesNotifier.bulkAdvanceToNextStatus error: $e\n$stack');
      state = state.copyWith(isBulkUpdating: false);
      return (success: false, count: 0, error: e.toString());
    }
  }
}

final packagesProvider =
    StateNotifierProvider<PackagesNotifier, PackagesState>((ref) {
  return PackagesNotifier(ref.read(packageRepositoryProvider));
});

final packageDetailProvider =
    FutureProvider.family<PackageModel, String>((ref, id) async {
  final repository = ref.read(packageRepositoryProvider);
  return repository.getPackage(id);
});

final packageHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, id) async {
  final repository = ref.read(packageRepositoryProvider);
  return repository.getStatusHistory(id);
});

final packageCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.read(packageRepositoryProvider);
  return repository.getPackageCounts();
});

final availableCitiesProvider = Provider<List<String>>((ref) {
  final packages = ref.watch(packagesProvider).packages;
  final cities = <String>{};
  for (final p in packages) {
    if (p.senderCity != null && p.senderCity!.isNotEmpty) {
      cities.add(p.senderCity!);
    }
    if (p.receiverCity != null && p.receiverCity!.isNotEmpty) {
      cities.add(p.receiverCity!);
    }
  }
  final sorted = cities.toList()..sort();
  return sorted;
});
