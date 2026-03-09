import 'package:easy_pay_bank_infomrm/configs/app_config.dart';

import 'main.dart';

Future<void> main() async {
  const config = AppConfig(
    flavor: AppFlavor.easyPay,
    appName: 'EasyPay 辅助系统',
    apiBaseUrl: 'https://easypayonline.org/api',
    apiTrialBaseUrl: 'https://staging.easypayonline.org/api',
    logoAsset: 'assets/easy_pay/icon.png',
  );

  await bootstrap(config);
}
