enum LdPlatform {
  macos,
  ios,
  android,
  linux,
  windows,
  webAndroid,
  webIOS,
  webMacOS,
  webWindows,
  webLinux,
  webUnknown,
}

extension LdPlatformExtension on LdPlatform {
  bool get isDesktop => switch (this) {
        LdPlatform.macos => true,
        LdPlatform.windows => true,
        LdPlatform.linux => true,
        LdPlatform.webMacOS => true,
        LdPlatform.webWindows => true,
        LdPlatform.webLinux => true,
        _ => false,
      };
  bool get isMobile => switch (this) {
        LdPlatform.ios => true,
        LdPlatform.android => true,
        LdPlatform.webIOS => true,
        LdPlatform.webAndroid => true,
        _ => false,
      };
  bool get isWeb => switch (this) {
        LdPlatform.webAndroid => true,
        LdPlatform.webIOS => true,
        LdPlatform.webMacOS => true,
        LdPlatform.webWindows => true,
        LdPlatform.webLinux => true,
        LdPlatform.webUnknown => true,
        _ => false,
      };
}
