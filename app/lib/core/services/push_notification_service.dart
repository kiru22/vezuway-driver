import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service for handling push notifications via Firebase Cloud Messaging.
/// Designed for PWA web push notifications with iOS 16.4+ support.
class PushNotificationService {
  static PushNotificationService? _instance;
  static PushNotificationService get instance {
    _instance ??= PushNotificationService._();
    return _instance!;
  }

  PushNotificationService._();

  FirebaseMessaging? _messaging;
  bool _initialized = false;
  bool _firebaseAvailable = false;

  final _tokenController = StreamController<String?>.broadcast();
  final _messageController = StreamController<RemoteMessage>.broadcast();

  /// Stream of FCM token changes
  Stream<String?> get onTokenRefresh => _tokenController.stream;

  /// Stream of foreground messages
  Stream<RemoteMessage> get onMessage => _messageController.stream;

  /// Whether Firebase has been initialized successfully
  bool get isAvailable => _firebaseAvailable;

  /// Whether push notifications are supported in this environment
  bool get isSupported => kIsWeb;

  static const String _vapidKey = 'BFaBq_XlRLjcoo2j4f_x-vtlXcqj1lo5SgBAs92DAnQMm-vcKFFvgfBj9paA4cGllyY_uHc8pln5ESXjalTriw0';

  /// Initialize Firebase and messaging service.
  /// Returns true if initialization was successful.
  Future<bool> initialize() async {
    if (_initialized) return _firebaseAvailable;
    _initialized = true;

    if (!kIsWeb) {
      // Only web is supported for now
      return false;
    }

    try {
      // Check if Firebase is already initialized (from index.html)
      if (Firebase.apps.isEmpty) {
        debugPrint('[PushNotificationService] Firebase not configured in index.html');
        return false;
      }

      _messaging = FirebaseMessaging.instance;
      _firebaseAvailable = true;

      // Listen for token refresh
      _messaging!.onTokenRefresh.listen((token) {
        debugPrint('[PushNotificationService] Token refreshed');
        _tokenController.add(token);
      });

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('[PushNotificationService] Foreground message received: ${message.notification?.title}');
        _messageController.add(message);
      });

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('[PushNotificationService] Message opened app: ${message.notification?.title}');
        _messageController.add(message);
      });

      debugPrint('[PushNotificationService] Initialized successfully');
      return true;
    } catch (e) {
      debugPrint('[PushNotificationService] Initialization failed: $e');
      _firebaseAvailable = false;
      return false;
    }
  }

  /// Get current notification permission status.
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    if (!_firebaseAvailable || _messaging == null) {
      return NotificationPermissionStatus.notSupported;
    }

    try {
      final settings = await _messaging!.getNotificationSettings();
      return _mapAuthorizationStatus(settings.authorizationStatus);
    } catch (e) {
      debugPrint('[PushNotificationService] Error getting permission status: $e');
      return NotificationPermissionStatus.notSupported;
    }
  }

  /// Request notification permission from the user.
  /// Must be called in response to user interaction (especially on iOS).
  Future<NotificationPermissionStatus> requestPermission() async {
    if (!_firebaseAvailable || _messaging == null) {
      return NotificationPermissionStatus.notSupported;
    }

    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('[PushNotificationService] Permission requested: ${settings.authorizationStatus}');
      return _mapAuthorizationStatus(settings.authorizationStatus);
    } catch (e) {
      debugPrint('[PushNotificationService] Error requesting permission: $e');
      return NotificationPermissionStatus.denied;
    }
  }

  /// Get the FCM token for this device/browser.
  /// Returns null if permissions are not granted or Firebase is not available.
  Future<String?> getToken() async {
    if (!_firebaseAvailable || _messaging == null) {
      return null;
    }

    try {
      // For web, we need to provide the VAPID key
      final token = await _messaging!.getToken(vapidKey: _vapidKey);
      debugPrint('[PushNotificationService] Token obtained: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      debugPrint('[PushNotificationService] Error getting token: $e');
      return null;
    }
  }

  /// Delete the current FCM token.
  Future<void> deleteToken() async {
    if (!_firebaseAvailable || _messaging == null) return;

    try {
      await _messaging!.deleteToken();
      _tokenController.add(null);
      debugPrint('[PushNotificationService] Token deleted');
    } catch (e) {
      debugPrint('[PushNotificationService] Error deleting token: $e');
    }
  }

  NotificationPermissionStatus _mapAuthorizationStatus(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized || AuthorizationStatus.provisional =>
        NotificationPermissionStatus.granted,
      AuthorizationStatus.denied => NotificationPermissionStatus.denied,
      AuthorizationStatus.notDetermined => NotificationPermissionStatus.notRequested,
    };
  }

  /// Dispose the service and close streams.
  void dispose() {
    _tokenController.close();
    _messageController.close();
  }
}

/// Status of notification permissions
enum NotificationPermissionStatus {
  /// Notifications are not supported in this environment
  notSupported,

  /// Permission has not been requested yet
  notRequested,

  /// User has granted permission
  granted,

  /// User has denied permission
  denied,
}
