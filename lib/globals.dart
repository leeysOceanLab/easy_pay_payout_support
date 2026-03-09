import 'configs/app_config.dart';

class Globals {
  static final Globals _globals = Globals._internal();
  static double? _screenHeight;
  static double? _screenWidth;
  static String _versionCode = '1.0.0';

  factory Globals() {
    return _globals;
  }

  Globals._internal();

  String getVersionCode() {
    return _versionCode;
  }

  void setVersionCode(String versionCode) {
    _versionCode = versionCode;
  }

  void setScreenSize({
    required double screenHeight,
    required double screenWidth,
  }) {
    _screenHeight = screenHeight;
    _screenWidth = screenWidth;
  }

  double getScreenHeight() {
    return _screenHeight!;
  }

  double getScreenWidth() {
    return _screenWidth!;
  }

  String get(String key) {
    switch (key) {
      case "api_base_url":
        return AppConfig.instance.apiBaseUrl;
      case "api_trial_base_url":
        return AppConfig.instance.apiTrialBaseUrl;
      default:
        return "";
    }
  }
}
