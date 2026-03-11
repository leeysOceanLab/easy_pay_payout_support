import "package:easy_pay_bank_infomrm/configs/app_config.dart";
import "package:flutter/cupertino.dart";
import "package:bot_toast/bot_toast.dart";
import "package:easy_pay_bank_infomrm/routes/route_generator.dart";

import "controller/app_controller.dart";
import "imports.dart";

Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.instance = config;

  await EasyLocalization.ensureInitialized();
  await SecureStorage().init();
  await SharedPrefs.instance.init();
  await ApiService.init();

  runApp(
    EasyLocalization(
      useOnlyLangCode: false,
      supportedLocales: const [Locale('zh', 'HK')],
      saveLocale: true,
      path: "assets/translations",
      fallbackLocale: const Locale('zh', 'HK'),
      startLocale: const Locale('zh', 'HK'),
      child: MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AppController())],
        child: const MyApp(),
      ),
    ),
  );
}

Future<void> main() async {
  const config = AppConfig(
    flavor: AppFlavor.staging,
    appName: 'EZ Pay Staging',
    apiBaseUrl: 'https://staging.easypayonline.org/api',
    apiTrialBaseUrl: 'https://staging.easypayonline.org/api',
    logoAsset: 'assets/icon/ez_pay_square.png',
  );

  await bootstrap(config);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BotToastNavigatorObserver _botToastNavigatorObserver =
      BotToastNavigatorObserver();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final botToastBuilder = BotToastInit();

    return ScreenUtilInit(
      designSize: kIsWeb
          ? Size(screenSize.width, screenSize.height)
          : const Size(375, 812),
      builder: (_, child) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          title: "Transaction Details",
          debugShowCheckedModeBanner: false,
          initialRoute: RouteName.splashPage,
          onGenerateRoute: RouteGenerator.generateRoute,
          navigatorObservers: <NavigatorObserver>[_botToastNavigatorObserver],
          builder: (context, widget) {
            widget = botToastBuilder(context, widget);
            return widget ?? const SizedBox.shrink();
          },
          theme: ThemeData(
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
              ),
            ),
            cupertinoOverrideTheme: const CupertinoThemeData().copyWith(
              primaryColor: Colors.blue,
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.blue[600],
              selectionHandleColor: Colors.blue,
              selectionColor: const Color.fromARGB(255, 177, 220, 255),
            ),
          ),
        );
      },
    );
  }
}
