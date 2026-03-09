// Package imports:
import '../imports.dart';
// Project imports:

class AppNavigator extends NavigatorObserver {
  static final navStack = <RouteStackItemModel>[];

  static void popUntil(BuildContext context, String routeName) {
    for (var element in navStack) {
      printLog("popUntil nav stack name: ${element.name}");
    }

    if (Navigator.canPop(context)) {
      Navigator.popUntil(context, ModalRoute.withName(routeName));
    }
  }

  static void pop<T>(BuildContext context, [T? result]) {
    for (var element in navStack) {
      printLog("pop nav stack name: ${element.name}");
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }

  static void popUntilFirstWithResult<T>(BuildContext context, [T? result]) {
    while (navStack.length > 1) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, result);
      } else {
        break;
      }
    }
  }

  static void popUntilWithResult<T>(
    BuildContext context,
    String routeName, [
    T? result,
  ]) {
    while (navStack.length > 1) {
      if (Navigator.canPop(context)) {
        if (navStack.last.name == routeName) {
          break;
        }

        Navigator.pop(context, result);
      } else {
        break;
      }
    }
  }

  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget widget,
  ) {
    final settings = ModalRoute.of(context)?.settings;

    return Navigator.push(
      context,
      MaterialWithModalsPageRoute(
        settings: settings,
        builder: (context) => widget,
      ),
    );
  }

  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    if (!RouteName.containsRoute(routeName)) {
      printLog("pushNamed route error: $routeName");
      return Future.value();
    }

    if (parameters != null) {
      final uri = Uri(path: routeName, queryParameters: parameters);
      routeName = uri.toString();
    }

    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T>(
    BuildContext context,
    String routeName, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    if (!RouteName.containsRoute(routeName)) {
      printLog("pushReplacementNamed route error: $routeName");
      return Future.value();
    }

    if (parameters != null) {
      final uri = Uri(path: routeName, queryParameters: parameters);
      routeName = uri.toString();
    }

    return Navigator.of(
      context,
    ).pushReplacementNamed(routeName, arguments: arguments);
  }

  static void popUntilFirst(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  ///
  ///
  ///
  ///

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      navStack.removeLast();
    }

    printLog("======== didPop");
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    navStack.add(RouteStackItemModel.fromRoute(route));

    printLog("======== didPush");
    super.didPush(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      navStack.removeLast();
    }

    printLog("======== didRemove");
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null) {
      navStack.removeLast();
    }
    if (newRoute != null) {
      navStack.add(RouteStackItemModel.fromRoute(newRoute));
    }

    printLog("======== didReplace");
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
