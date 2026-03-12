// Package imports:
// ignore_for_file: unused_local_variable

// Package imports:

import "package:page_transition/page_transition.dart";

// Project imports:

import '../imports.dart';

class RouteGenerator {
  static Route? generateRoute(RouteSettings settings) {
    var uri = Uri.parse(settings.name!);

    // arguments
    dynamic arguments = settings.arguments;
    // parameters
    Map<String, String?> parameters = uri.queryParameters;

    switch (uri.path) {
      case RouteName.splashPage:
        return MaterialWithModalsPageRoute(
          settings: settings,
          builder: (context) => const SplashScreen(),
        );

      case RouteName.loginPage:
        return MaterialWithModalsPageRoute(
          settings: settings,
          builder: (context) {
            final args = settings.arguments as Map<String, dynamic>?;
            return LoginScreen();
          },
        );
      case RouteName.mainPage:
        return MaterialWithModalsPageRoute(
          settings: settings,
          builder: (context) {
            final args = settings.arguments as Map<String, dynamic>?;
            return const MainScreen();
          },
        );

      case RouteName.withdrawalDetails:
        return MaterialWithModalsPageRoute(
          settings: settings,
          builder: (context) {
            int id = arguments["id"];
            WithdrawalDetailsModel? details = arguments?["details"];
            bool? isLockedByMe = arguments?['lockedByMe'] ?? false;
            bool? isHistory = arguments?["isHistory"] ?? false;
            return WithdrawalDetailsScreen(
              id: id,
              initialDetails: details,
              isHistory: isHistory,
              isLockedByMe: isLockedByMe,
            );
          },
        );

      case RouteName.historyWithdrawalDetails:
        return MaterialWithModalsPageRoute(
          settings: settings,
          builder: (context) {
            int id = arguments["id"];
            WithdrawalDetailsModel details = arguments?["initialDetails"];
            return HistoryWithdrawalDetailsScreen(
              id: id,
              initialDetails: details,
            );
          },
        );

      case RouteName.historyWithdrawalList:
        return MaterialWithModalsPageRoute(
          settings: settings,
          builder: (context) {
            return HistoryScreen();
          },
        );

      default:
        return null;
    }
  }
}

PageTransition customPageTransition({
  required Widget child,
  required RouteSettings settings,
  PageTransitionType? type,
}) {
  return PageTransition(
    settings: settings,
    type: type ?? PageTransitionType.rightToLeft,
    isIos: kIsWeb
        ? false
        : Platform.isIOS
        ? true
        : false,
    child: child,
  );
}

class CupertinoRoute extends PageRouteBuilder {
  final Widget enterPage;
  final Widget exitPage;
  CupertinoRoute({required this.exitPage, required this.enterPage})
    : super(
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return enterPage;
            },
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              return Stack(
                children: <Widget>[
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.0, 0.0),
                          end: const Offset(-0.33, 0.0),
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.linearToEaseOut,
                            reverseCurve: Curves.easeInToLinear,
                          ),
                        ),
                    child: exitPage,
                  ),
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.linearToEaseOut,
                            reverseCurve: Curves.easeInToLinear,
                          ),
                        ),
                    child: enterPage,
                  ),
                ],
              );
            },
      );
}
