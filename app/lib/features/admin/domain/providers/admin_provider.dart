import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/repositories/admin_repository.dart';

// Admin Repository Provider
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(apiServiceProvider));
});

// User Role Filter Provider
final userRoleFilterProvider = StateProvider<String?>((ref) => null);

// All Users Provider (watches filter)
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  final roleFilter = ref.watch(userRoleFilterProvider);
  return repository.getAllUsers(roleFilter: roleFilter);
});

// Pending Drivers Provider
final pendingDriversProvider = FutureProvider<List<UserModel>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getPendingDrivers();
});

// Admin Actions State
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

// Admin Actions Notifier
class AdminActionsNotifier extends StateNotifier<AdminActionState> {
  final AdminRepository _repository;
  final Ref _ref;

  AdminActionsNotifier(this._repository, this._ref)
      : super(const AdminActionState());

  Future<bool> approveDriver(String userId) async {
    return _executeAction(
      action: () => _repository.approveDriver(userId),
      errorPrefix: 'Error al aprobar conductor',
    );
  }

  Future<bool> rejectDriver(String userId, {String? reason}) async {
    return _executeAction(
      action: () => _repository.rejectDriver(userId, reason: reason),
      errorPrefix: 'Error al rechazar conductor',
    );
  }

  Future<bool> _executeAction({
    required Future<void> Function() action,
    required String errorPrefix,
  }) async {
    state = state.copyWith(status: AdminActionStatus.loading);

    try {
      await action();
      _ref.invalidate(pendingDriversProvider);
      state = state.copyWith(status: AdminActionStatus.success);
      _scheduleStateReset();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AdminActionStatus.error,
        error: '$errorPrefix: $e',
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

// Admin Actions Provider
final adminActionsProvider =
    StateNotifierProvider<AdminActionsNotifier, AdminActionState>((ref) {
  return AdminActionsNotifier(
    ref.read(adminRepositoryProvider),
    ref,
  );
});
