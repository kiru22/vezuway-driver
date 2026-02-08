import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/plan_request_model.dart';
import '../../data/repositories/plan_request_repository.dart';

final planRequestRepositoryProvider = Provider<PlanRequestRepository>((ref) {
  return PlanRequestRepository(ref.read(apiServiceProvider));
});

// My pending plan request (driver side)
final myPlanRequestProvider = FutureProvider<PlanRequestModel?>((ref) async {
  final repository = ref.read(planRequestRepositoryProvider);
  return repository.getMyRequest();
});

enum PlanRequestStatus { idle, loading, success, error }

class PlanRequestState {
  final PlanRequestStatus status;
  final String? error;

  const PlanRequestState({
    this.status = PlanRequestStatus.idle,
    this.error,
  });

  PlanRequestState copyWith({
    PlanRequestStatus? status,
    String? error,
  }) {
    return PlanRequestState(
      status: status ?? this.status,
      error: error,
    );
  }
}

class PlanRequestNotifier extends StateNotifier<PlanRequestState> {
  final PlanRequestRepository _repository;
  final Ref _ref;

  PlanRequestNotifier(this._repository, this._ref)
      : super(const PlanRequestState());

  Future<bool> submitRequest({
    required String planKey,
    required String planName,
    required int planPrice,
  }) async {
    state = state.copyWith(status: PlanRequestStatus.loading);

    try {
      await _repository.createPlanRequest(
        planKey: planKey,
        planName: planName,
        planPrice: planPrice,
      );
      _ref.invalidate(myPlanRequestProvider);
      state = state.copyWith(status: PlanRequestStatus.success);
      _scheduleStateReset();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: PlanRequestStatus.error,
        error: e.toString(),
      );
      _scheduleStateReset();
      return false;
    }
  }

  void _scheduleStateReset() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = const PlanRequestState();
      }
    });
  }
}

final planRequestProvider =
    StateNotifierProvider<PlanRequestNotifier, PlanRequestState>((ref) {
  return PlanRequestNotifier(ref.read(planRequestRepositoryProvider), ref);
});
