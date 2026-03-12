import '../imports.dart';

class HistoryController with ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  TabController? tabController;

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void setInit(TickerProvider vsync) async {
    List<String> tabLabels = [
      context.tr(AppStrings.currentHistory),
      context.tr(AppStrings.historyRecord),
    ];

    tabController = TabController(length: tabLabels.length, vsync: vsync)
      ..addListener(() {
        notifyListeners();
      });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
