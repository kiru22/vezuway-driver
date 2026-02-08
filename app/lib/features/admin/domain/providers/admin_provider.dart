import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../plans/data/models/plan_request_model.dart';
import '../../data/models/pending_driver_model.dart';
import '../../data/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(apiServiceProvider));
});

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getAllUsers();
});

final clientUsersProvider = Provider<AsyncValue<List<UserModel>>>((ref) {
  return ref.watch(allUsersProvider).whenData(
        (users) => users.where((u) => u.isClient).toList(),
      );
});

final driverUsersProvider = Provider<AsyncValue<List<UserModel>>>((ref) {
  return ref.watch(allUsersProvider).whenData(
        (users) => users.where((u) => u.isDriver).toList(),
      );
});

final allUsersCountProvider = Provider<int>((ref) {
  return ref.watch(allUsersProvider).valueOrNull?.length ?? 0;
});

final clientUsersCountProvider = Provider<int>((ref) {
  return ref.watch(clientUsersProvider).valueOrNull?.length ?? 0;
});

final driverUsersCountProvider = Provider<int>((ref) {
  return ref.watch(driverUsersProvider).valueOrNull?.length ?? 0;
});

final pendingDriversProvider = FutureProvider<List<PendingDriverModel>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getPendingDrivers();
});

final pendingDriversCountProvider = Provider<int>((ref) {
  return ref.watch(pendingDriversProvider).valueOrNull?.length ?? 0;
});

final adminPlanRequestsProvider =
    FutureProvider<List<PlanRequestModel>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getPlanRequests();
});

final adminPlanRequestsCountProvider = Provider<int>((ref) {
  return ref.watch(adminPlanRequestsProvider).valueOrNull?.length ?? 0;
});

enum AdminActionStatus { idle, loading, success, error }

class AdminActionState {
  final AdminActionStatus status;
  final String? error;
  final String? successMessage;

  const AdminActionState({
    this.status = AdminActionStatus.idle,
    this.error,
    this.successMessage,
  });

  AdminActionState copyWith({
    AdminActionStatus? status,
    String? error,
    String? successMessage,
  }) {
    return AdminActionState(
      status: status ?? this.status,
      error: error,
      successMessage: successMessage,
    );
  }
}

class AdminActionsNotifier extends StateNotifier<AdminActionState> {
  final AdminRepository _repository;
  final Ref _ref;

  AdminActionsNotifier(this._repository, this._ref)
      : super(const AdminActionState());

  Future<bool> approveDriver(String userId) async {
    return _executeAction(
      action: () => _repository.approveDriver(userId),
      invalidateProviders: [pendingDriversProvider],
    );
  }

  Future<bool> rejectDriver(String userId, {String? reason}) async {
    return _executeAction(
      action: () => _repository.rejectDriver(userId, reason: reason),
      invalidateProviders: [pendingDriversProvider],
    );
  }

  Future<bool> approvePlanRequest(String id) async {
    return _executeAction(
      action: () => _repository.approvePlanRequest(id),
      invalidateProviders: [adminPlanRequestsProvider],
    );
  }

  Future<bool> rejectPlanRequest(String id) async {
    return _executeAction(
      action: () => _repository.rejectPlanRequest(id),
      invalidateProviders: [adminPlanRequestsProvider],
    );
  }

  Future<bool> _executeAction({
    required Future<void> Function() action,
    List<ProviderOrFamily>? invalidateProviders,
  }) async {
    state = state.copyWith(status: AdminActionStatus.loading);

    try {
      await action();
      if (invalidateProviders != null) {
        for (final provider in invalidateProviders) {
          _ref.invalidate(provider);
        }
      }
      state = state.copyWith(status: AdminActionStatus.success);
      _scheduleStateReset();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AdminActionStatus.error,
        error: e.toString(),
      );
      return false;
    }
  }

  void _scheduleStateReset() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = const AdminActionState();
      }
    });
  }

  void clearMessages() {
    state = const AdminActionState();
  }
}

final adminActionsProvider =
    StateNotifierProvider<AdminActionsNotifier, AdminActionState>((ref) {
  return AdminActionsNotifier(
    ref.read(adminRepositoryProvider),
    ref,
  );
});
