import "../imports.dart";

class SessionController extends ChangeNotifier with WidgetsBindingObserver {
  DateTime? _lastActivityTime;
  Timer? _timer;

  bool _isStarted = false;
  bool _isHandlingTimeout = false;
  bool _isExpired = false;

  Duration timeout = const Duration(minutes: 15);

  bool get isStarted => _isStarted;
  bool get isExpired => _isExpired;
  DateTime? get lastActivityTime => _lastActivityTime;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void disposeController() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }

  void start({Duration? customTimeout}) {
    if (customTimeout != null) {
      timeout = customTimeout;
    }

    _isStarted = true;
    _isExpired = false;
    _isHandlingTimeout = false;
    _lastActivityTime = DateTime.now();
    _startTimer();
    notifyListeners();
  }

  void stop() {
    _isStarted = false;
    _isExpired = false;
    _isHandlingTimeout = false;
    _lastActivityTime = null;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void markActivity({String source = "unknown"}) {
    if (!_isStarted || _isExpired) return;
    if (_shouldIgnoreCurrentRoute()) return;

    _lastActivityTime = DateTime.now();
    notifyListeners();
  }

  bool _shouldIgnoreCurrentRoute() {
    final String? routeName = RouteTracker.currentRouteName;

    return routeName == RouteName.splashPage ||
        routeName == RouteName.loginPage;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await checkTimeout();
    });
  }

  Future<void> checkTimeout() async {
    if (!_isStarted || _isExpired || _isHandlingTimeout) return;
    if (_shouldIgnoreCurrentRoute()) return;
    if (_lastActivityTime == null) return;

    final Duration idleDuration = DateTime.now().difference(_lastActivityTime!);

    if (idleDuration >= timeout) {
      _isHandlingTimeout = true;
      _isExpired = true;
      _timer?.cancel();
      _timer = null;
      try {
        await SessionTimeoutHelper.handleTimeout();
      } finally {
        _isHandlingTimeout = false;
      }

      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isStarted || _isExpired) return;

    if (state == AppLifecycleState.resumed) {
      checkTimeout();
    }
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }
}
