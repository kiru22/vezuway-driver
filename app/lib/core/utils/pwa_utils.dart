import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Utilities for PWA-specific functionality
class PwaUtils {
  PwaUtils._();

  /// Check if the app is running as an installed PWA (standalone mode)
  static bool isPwaInstalled() {
    if (!kIsWeb) return false;

    try {
      // Check display-mode media query for standalone
      final mq = html.window.matchMedia('(display-mode: standalone)');
      return mq.matches;
    } catch (e) {
      debugPrint('[PwaUtils] Error checking PWA installed: $e');
      return false;
    }
  }

  /// Check if the device is running iOS
  static bool isIos() {
    if (!kIsWeb) return false;

    try {
      final ua = html.window.navigator.userAgent.toLowerCase();
      return ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod');
    } catch (e) {
      debugPrint('[PwaUtils] Error checking iOS: $e');
      return false;
    }
  }

  /// Check if the device supports iOS web push (iOS 16.4+)
  static bool supportsIosWebPush() {
    if (!kIsWeb || !isIos()) return false;

    try {
      // Check for Notification API support (added in iOS 16.4)
      return html.Notification.supported;
    } catch (e) {
      debugPrint('[PwaUtils] Error checking iOS web push support: $e');
      return false;
    }
  }

  /// Check if notifications are supported in the current environment
  static bool supportsNotifications() {
    if (!kIsWeb) return false;

    try {
      return html.Notification.supported;
    } catch (e) {
      return false;
    }
  }

  /// Check if service workers are supported
  static bool supportsServiceWorkers() {
    if (!kIsWeb) return false;

    try {
      return html.window.navigator.serviceWorker != null;
    } catch (e) {
      return false;
    }
  }

  /// Get a summary of PWA capabilities for debugging
  static Map<String, bool> getCapabilities() {
    return {
      'isWeb': kIsWeb,
      'isPwaInstalled': isPwaInstalled(),
      'isIos': isIos(),
      'supportsNotifications': supportsNotifications(),
      'supportsServiceWorkers': supportsServiceWorkers(),
      'supportsIosWebPush': supportsIosWebPush(),
    };
  }
}
