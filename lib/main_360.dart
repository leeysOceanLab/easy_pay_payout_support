import 'package:easy_pay_bank_infomrm/configs/app_config.dart';

import 'main.dart';

Future<void> main() async {
  const config = AppConfig(
    flavor: AppFlavor.threeSixty,
    appName: '360 辅助系统',
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://360payhk.asia/api',
    ),
    apiTrialBaseUrl: String.fromEnvironment(
      'API_TRIAL_BASE_URL',
      defaultValue: 'https://360payhk.asia/api',
    ),
    logoAsset: 'assets/three_sixty/logo.png',
  );

  await bootstrap(config);
}
