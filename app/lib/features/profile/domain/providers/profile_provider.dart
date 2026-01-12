import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/domain/providers/auth_provider.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthRepository _repository;
  final Ref _ref;

  ProfileNotifier(this._repository, this._ref) : super(const ProfileState());

  Future<bool> updateName(String name) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final user = await _repository.updateProfile(name: name);
      _ref.read(authProvider.notifier).updateUser(user);
      state = state.copyWith(isLoading: false, successMessage: 'name_updated');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'name_update_error');
      return false;
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: confirmPassword,
      );
      state = state.copyWith(isLoading: false, successMessage: 'password_updated');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'password_error');
      return false;
    }
  }

  Future<bool> uploadAvatar(File imageFile) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final user = await _repository.uploadAvatar(imageFile);
      _ref.read(authProvider.notifier).updateUser(user);
      state = state.copyWith(isLoading: false, successMessage: 'avatar_updated');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'avatar_error');
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    ref.read(authRepositoryProvider),
    ref,
  );
});
