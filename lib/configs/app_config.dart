enum AppFlavor { staging, easyPay, threeSixty, ffPay, ffPayBubble, ffPayDetails }

class AppConfig {
  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final String apiTrialBaseUrl;
  final String logoAsset;

  /// When true, tapping an order shows the bubble and stays on the list.
  final bool bubbleOnTap;

  /// When true, tapping an order navigates to the details page.
  final bool detailsOnTap;

  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.apiTrialBaseUrl,
    required this.logoAsset,
    this.bubbleOnTap = true,
    this.detailsOnTap = true,
  });

  static late AppConfig instance;
}
