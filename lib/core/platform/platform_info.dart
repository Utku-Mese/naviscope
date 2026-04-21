import 'dart:io';

class PlatformInfo {
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;

  static String get platformName =>
      isAndroid ? 'Android' : isIOS ? 'iOS' : Platform.operatingSystem;
}
