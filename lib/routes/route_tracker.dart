import "package:flutter/material.dart";

class RouteTracker extends NavigatorObserver {
  static String? currentRouteName;

  void _updateRoute(Route<dynamic>? route) {
    currentRouteName = route?.settings.name;
    print("RouteTracker: current route = $currentRouteName");
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateRoute(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateRoute(previousRoute);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _updateRoute(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
