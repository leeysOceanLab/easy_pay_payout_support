import 'package:easy_pay_bank_infomrm/configs/app_config.dart';

import 'main.dart';

Future<void> main() async {
  const config = AppConfig(
    flavor: AppFlavor.ffPayBubble,
    appName: 'FF Pay',
    apiBaseUrl: 'https://staging.easypayapi.online/api',
    apiTrialBaseUrl: 'https://staging.easypayapi.online/api',
    logoAsset: 'assets/easy_pay/icon.png',
    bubbleOnTap: true,
    detailsOnTap: false,
  );

  await bootstrap(config);
}
