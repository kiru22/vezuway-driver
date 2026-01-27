import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/push_notification_service.dart';
import '../../../../core/utils/pwa_utils.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../auth/domain/providers/auth_provider.dart';

/// State for push notification management
enum NotificationState {
  /// Initial state, not yet checked
  initial,

  /// Notifications not supported in this environment
  notSupported,

  /// Permission not requested yet
  permissionNotRequested,

  /// User denied permission
  permissionDenied,

  /// User dismissed the banner (don't show again this session)
  dismissed,

  /// Notifications enabled and working
  enabled,

  /// Error occurred
  error,
}

/// Provider for the PushNotificationService singleton
final pushNotificationServiceProvider =
    Provider<PushNotificationService>((ref) {
  return PushNotificationService.instance;
});

/// Provider for notification state management
final notificationStateProvider =
    StateNotifierProvider<NotificationStateNotifier, NotificationState>((ref) {
  return NotificationStateNotifier(ref);
});

/// Whether to show the notification permission banner
final shouldShowNotificationBannerProvider = Provider<bool>((ref) {
  final state = ref.watch(notificationStateProvider);
  final authState = ref.watch(authProvider);

  // Only show banner if:
  // 1. User is authenticated
  // 2. Permission hasn't been requested yet
  // 3. User hasn't dismissed the banner
  // 4. Not in an error state
  return authState.status == AuthStatus.authenticated &&
      state == NotificationState.permissionNotRequested;
});

class NotificationStateNotifier extends StateNotifier<NotificationState> {
  final Ref _ref;
  final PushNotificationService _service;
  StreamSubscription<String?>? _tokenSubscription;
  bool _initialized = false;

  static const _dismissedKey = 'notification_banner_dismissed';

  NotificationStateNotifier(this._ref)
      : _service = PushNotificationService.instance,
        super(NotificationState.initial) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Check if we're on web
    if (!kIsWeb) {
      state = NotificationState.notSupported;
      return;
    }

    // Check basic support
    if (!PwaUtils.supportsNotifications() ||
        !PwaUtils.supportsServiceWorkers()) {
      state = NotificationState.notSupported;
      return;
    }

    // Initialize Firebase
    final success = await _service.initialize();
    if (!success) {
      // Firebase not configured - treat as not supported
      state = NotificationState.notSupported;
      return;
    }

    // Check if user already dismissed the banner
    final prefs = _ref.read(sharedPreferencesProvider);
    final dismissed = prefs.getBool(_dismissedKey) ?? false;
    if (dismissed) {
      state = NotificationState.dismissed;
      return;
    }

    // Check current permission status
    final permissionStatus = await _service.getPermissionStatus();
    await _handlePermissionStatus(permissionStatus);
  }

  Future<void> _handlePermissionStatus(
      NotificationPermissionStatus status) async {
    switch (status) {
      case NotificationPermissionStatus.granted:
        await _setupNotifications();
      case NotificationPermissionStatus.denied:
        state = NotificationState.permissionDenied;
      case NotificationPermissionStatus.notRequested:
        state = NotificationState.permissionNotRequested;
      case NotificationPermissionStatus.notSupported:
        state = NotificationState.notSupported;
    }
  }

  /// Request notification permission from user.
  /// Should be called in response to user interaction.
  Future<bool> requestPermission() async {
    if (state == NotificationState.notSupported) {
      return false;
    }

    final permissionStatus = await _service.requestPermission();
    await _handlePermissionStatus(permissionStatus);

    return permissionStatus == NotificationPermissionStatus.granted;
  }

  /// Dismiss the notification banner for this session
  Future<void> dismissBanner() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setBool(_dismissedKey, true);
    state = NotificationState.dismissed;
  }

  /// Setup notifications after permission granted
  Future<void> _setupNotifications() async {
    try {
      // Get FCM token
      final token = await _service.getToken();
      if (token != null) {
        await _sendTokenToServer(token);
      }

      // Listen for token refresh
      _tokenSubscription = _service.onTokenRefresh.listen((newToken) {
        if (newToken != null) {
          _sendTokenToServer(newToken);
        }
      });

      state = NotificationState.enabled;
    } catch (e) {
      debugPrint(
          '[NotificationStateNotifier] Error setting up notifications: $e');
      state = NotificationState.error;
    }
  }

  /// Send FCM token to backend
  Future<void> _sendTokenToServer(String token) async {
    try {
      final authRepository = _ref.read(authRepositoryProvider);
      await authRepository.updateFcmToken(token);
      debugPrint('[NotificationStateNotifier] Token sent to server');
    } catch (e) {
      debugPrint(
          '[NotificationStateNotifier] Error sending token to server: $e');
      // Don't change state - notifications can still work locally
    }
  }

  /// Reset the dismissed state (useful for settings screen)
  Future<void> resetDismissed() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.remove(_dismissedKey);

    // Re-check permission status
    final permissionStatus = await _service.getPermissionStatus();
    if (permissionStatus == NotificationPermissionStatus.notRequested) {
      state = NotificationState.permissionNotRequested;
    }
  }

  @override
  void dispose() {
    _tokenSubscription?.cancel();
    super.dispose();
  }
}
