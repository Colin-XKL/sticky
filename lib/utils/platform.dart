import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformInfo {
  static const platformNameMapping = {
    PlatformType.Web: "Web",
    PlatformType.Android: 'Android',
    PlatformType.iOS: 'iOS',
    PlatformType.Fuchsia: 'Fuchsia',
    PlatformType.MacOS: "MacOS",
    PlatformType.Windows: "Windows",
    PlatformType.Linux: "Linux",
    PlatformType.Unknown: "Unknown",
  };

  static String? getPlatformString() {
    return platformNameMapping[getCurrentPlatformType()];
  }

  static bool isDesktop() {
    return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  }

  static bool isMobile() {
    return Platform.isIOS || Platform.isAndroid || Platform.isFuchsia;
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static PlatformType getCurrentPlatformType() {
    if (kIsWeb) {
      return PlatformType.Web;
    }

    if (Platform.isWindows) {
      return PlatformType.Windows;
    }

    if (Platform.isMacOS) {
      return PlatformType.MacOS;
    }

    if (Platform.isLinux) {
      return PlatformType.Linux;
    }

    if (Platform.isIOS) {
      return PlatformType.iOS;
    }

    if (Platform.isAndroid) {
      return PlatformType.Android;
    }

    if (Platform.isFuchsia) {
      return PlatformType.Fuchsia;
    }

    return PlatformType.Unknown;
  }
}

enum PlatformType { Web, iOS, Android, MacOS, Fuchsia, Linux, Windows, Unknown }
