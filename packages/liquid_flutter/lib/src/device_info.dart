import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Enum representing different device types
enum DeviceType {
  /// Mobile phone devices
  phone,

  /// Tablet devices
  tablet,

  /// Desktop/laptop computers
  desktop,

  /// Web browsers
  web,

  /// Unknown device type
  unknown,
}

/// Provides device type detection functionality across all platforms
class DeviceInfo {
  /// Detects the current device type
  ///
  /// Returns a [DeviceType] enum value representing the current device.
  /// Works on all platforms including web.
  static DeviceType getDeviceType() {
    if (kIsWeb) {
      return _getWebDeviceType();
    } else {
      return _getNativeDeviceType();
    }
  }

  /// Detects device type for web platforms
  static DeviceType _getWebDeviceType() {
    // Web detection using screen size and user agent
    final mediaQuery = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Check if it's a mobile device based on screen size
    if (screenWidth < 600 || screenHeight < 600) {
      return DeviceType.phone;
    } else if (screenWidth < 1024) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Detects device type for native platforms (iOS, Android, macOS, Windows, Linux)
  static DeviceType _getNativeDeviceType() {
    if (Platform.isIOS || Platform.isAndroid) {
      // For mobile platforms, we can use screen size to differentiate
      // between phone and tablet
      final mediaQuery = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
      final screenWidth = mediaQuery.size.width;
      final screenHeight = mediaQuery.size.height;

      // Use the smaller dimension to determine device type
      final smallestDimension = screenWidth < screenHeight ? screenWidth : screenHeight;

      // Common breakpoints for mobile devices
      if (smallestDimension < 600) {
        return DeviceType.phone;
      } else {
        return DeviceType.tablet;
      }
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return DeviceType.desktop;
    } else {
      return DeviceType.unknown;
    }
  }

  /// Checks if the current device is a mobile device (phone or tablet)
  static bool get isMobile {
    final deviceType = getDeviceType();
    return deviceType == DeviceType.phone || deviceType == DeviceType.tablet;
  }

  /// Checks if the current device is a phone
  static bool get isPhone => getDeviceType() == DeviceType.phone;

  /// Checks if the current device is a tablet
  static bool get isTablet => getDeviceType() == DeviceType.tablet;

  /// Checks if the current device is a desktop
  static bool get isDesktop => getDeviceType() == DeviceType.desktop;

  /// Checks if the current device is running on web
  static bool get isWeb => kIsWeb;

  /// Gets a human-readable string representation of the device type
  static String getDeviceTypeString() {
    switch (getDeviceType()) {
      case DeviceType.phone:
        return 'Phone';
      case DeviceType.tablet:
        return 'Tablet';
      case DeviceType.desktop:
        return 'Desktop';
      case DeviceType.web:
        return 'Web';
      case DeviceType.unknown:
        return 'Unknown';
    }
  }
}
