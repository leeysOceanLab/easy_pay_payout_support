import '../imports.dart';

class HistoryController with ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  bool isLoading = false;
  final RefreshController refreshController = RefreshController();
  TextEditingController searchTextController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  dynamic filters = {};
  List<WithdrawalDetailsModel> withdrawalList = [];
  WithdrawalDetailsModel withdrawalDetails = WithdrawalDetailsModel();
  int page = 1;
  final ScrollController scrollController = ScrollController();

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void onRefresh() async {
    isLoading = true;
    page = 1;
    withdrawalList = [];
    await getWithdrawalList();
    refreshController.refreshCompleted();
    isLoading = false;
    update();
  }

  void onLoading() async {
    await getWithdrawalList();
    // filterBookings(_selectedStatus, context);
    update();
  }

  Future<void> goToWithdrawalDetails(WithdrawalDetailsModel item) async {
    await AppNavigator.pushNamed(
      context,
      RouteName.historyWithdrawalDetails,
      arguments: {"id": item.id, "details": item},
    );

    onRefresh();
  }

  Future<void> getWithdrawalList() async {
    await ApiService.api.getWithdrawalsApprovedList(
      page: page,
      onSuccess: (response) {
        withdrawalList.addAll(
          List.from(
            response.data['withdrawals'],
          ).map((element) => WithdrawalDetailsModel.fromJson(element)).toList(),
        );

        int lastPage = response.data['pagination']['last_page'];
        if (page < lastPage) {
          page = page + 1;
          refreshController.loadComplete();
        } else {
          refreshController.loadNoData();
        }
      },
    );
  }

  Map<String, List<WithdrawalDetailsModel>> get groupedWithdrawalList {
    final Map<String, List<WithdrawalDetailsModel>> grouped = {};

    for (final item in withdrawalList) {
      final String dateKey = _dateGroupKey(item.createdAt);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }

      grouped[dateKey]!.add(item);
    }

    return grouped;
  }

  String _dateGroupKey(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) {
      return "-";
    }

    try {
      final DateTime dateTime = DateTime.parse(createdAt);
      final String year = dateTime.year.toString();
      final String month = dateTime.month.toString().padLeft(2, "0");
      final String day = dateTime.day.toString().padLeft(2, "0");

      return "$year-$month-$day";
    } catch (e) {
      return createdAt;
    }
  }
}
