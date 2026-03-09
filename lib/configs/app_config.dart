enum AppFlavor { staging, easyPay, threeSixty }

class AppConfig {
  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final String apiTrialBaseUrl;
  final String logoAsset;

  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.apiTrialBaseUrl,
    required this.logoAsset,
  });

  static late AppConfig instance;
}
