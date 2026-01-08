import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/package_model.dart';
import '../../data/repositories/package_repository.dart';

// Package Repository Provider
final packageRepositoryProvider = Provider<PackageRepository>((ref) {
  return PackageRepository(ref.read(apiServiceProvider));
});

// Packages List State
class PackagesState {
  final List<PackageModel> packages;
  final bool isLoading;
  final String? error;
  final PackageStatus? filterStatus;

  const PackagesState({
    this.packages = const [],
    this.isLoading = false,
    this.error,
    this.filterStatus,
  });

  PackagesState copyWith({
    List<PackageModel>? packages,
    bool? isLoading,
    String? error,
    PackageStatus? filterStatus,
    bool clearFilter = false,
  }) {
    return PackagesState(
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
    );
  }
}

// Packages Notifier
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
      final packages = await _repository.getPackages(status: state.filterStatus);
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

  Future<bool> createPackage({
    int? routeId,
    required String senderName,
    String? senderPhone,
    String? senderAddress,
    required String receiverName,
    String? receiverPhone,
    String? receiverAddress,
    String? description,
    double? weight,
    int? lengthCm,
    int? widthCm,
    int? heightCm,
    int? quantity,
    double? declaredValue,
    String? notes,
  }) async {
    try {
      final newPackage = await _repository.createPackage(
        routeId: routeId,
        senderName: senderName,
        senderPhone: senderPhone,
        senderAddress: senderAddress,
        receiverName: receiverName,
        receiverPhone: receiverPhone,
        receiverAddress: receiverAddress,
        description: description,
        weight: weight,
        lengthCm: lengthCm,
        widthCm: widthCm,
        heightCm: heightCm,
        quantity: quantity,
        declaredValue: declaredValue,
        notes: notes,
      );
      state = state.copyWith(
        packages: [newPackage, ...state.packages],
      );
      return true;
    } catch (e, stack) {
      debugPrint('PackagesNotifier.createPackage error: $e\n$stack');
      return false;
    }
  }

  Future<bool> updateStatus(int id, PackageStatus status, {String? notes}) async {
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

  Future<bool> deletePackage(int id) async {
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
}

// Packages Provider
final packagesProvider =
    StateNotifierProvider<PackagesNotifier, PackagesState>((ref) {
  return PackagesNotifier(ref.read(packageRepositoryProvider));
});

// Single Package Provider
final packageDetailProvider =
    FutureProvider.family<PackageModel, int>((ref, id) async {
  final repository = ref.read(packageRepositoryProvider);
  return repository.getPackage(id);
});

// Package Status History Provider
final packageHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, id) async {
  final repository = ref.read(packageRepositoryProvider);
  return repository.getStatusHistory(id);
});
