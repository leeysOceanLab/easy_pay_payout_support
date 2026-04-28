import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'configs/app_config.dart';
import 'controller/app_controller.dart';
import 'imports.dart';
import 'screen/bubble_details_screen/bubble_details_screen.dart';
import 'services/navigation_service.dart';

/// Flutter entry point invoked by BubbleActivity via getDartEntrypointFunctionName().
/// args[0] = withdrawalId (int as String)
/// args[1] = apiBaseUrl
@pragma('vm:entry-point')
Future<void> mainBubble(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final int withdrawalId = int.tryParse(args.isNotEmpty ? args[0] : '0') ?? 0;
  final String apiBaseUrl = args.length > 1 && args[1].isNotEmpty
      ? args[1]
      : 'https://easypayonline.org/api';

  AppConfig.instance = AppConfig(
    flavor: AppFlavor.easyPay,
    appName: 'EZ Pay',
    apiBaseUrl: apiBaseUrl,
    apiTrialBaseUrl: apiBaseUrl,
    logoAsset: 'assets/easy_pay/icon.png',
  );

  await EasyLocalization.ensureInitialized();
  await SecureStorage().init();
  await SharedPrefs.instance.init();
  await ApiService.init();

  // Portrait only, same as main app.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      useOnlyLangCode: false,
      supportedLocales: const [Locale('zh', 'HK')],
      saveLocale: true,
      path: 'assets/translations',
      fallbackLocale: const Locale('zh', 'HK'),
      startLocale: const Locale('zh', 'HK'),
      child: MultiProvider(
        providers: [
          // AppController is needed so http_client_custom can handle 401 logout.
          ChangeNotifierProvider(create: (_) => AppController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF1C1C1E),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2DD4BF),
              surface: Color(0xFF2C2C2E),
            ),
          ),
          home: BubbleDetailsScreen(withdrawalId: withdrawalId),
        ),
      ),
    ),
  );
}
