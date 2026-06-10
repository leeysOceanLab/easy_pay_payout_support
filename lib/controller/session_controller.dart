import "../imports.dart";

class SessionController extends ChangeNotifier with WidgetsBindingObserver {
  bool get isExpired => false;

  void init() {}
  void start({Duration? customTimeout}) {}
  void stop() {}
  void markActivity({String source = "unknown"}) {}
}
