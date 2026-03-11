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

  DateTime? selectedDateFrom;
  DateTime? selectedDateTo;
  String? totalAmount = "0.00";

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> applyDateRange({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    selectedDateFrom = dateFrom;
    selectedDateTo = dateTo;
    update();

    onRefresh();
  }

  Future<void> clearDateRange() async {
    selectedDateFrom = null;
    selectedDateTo = null;
    update();

    onRefresh();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    searchFocusNode.dispose();
    scrollController.dispose();
    _isDisposed = true;
    super.dispose();
  }

  void onRefresh() async {
    isLoading = true;
    page = 1;
    withdrawalList = [];
    update();

    await getWithdrawalList();

    refreshController.refreshCompleted();
    isLoading = false;
    update();
  }

  void onLoading() async {
    await getWithdrawalList();
    update();
  }

  Future<void> goToWithdrawalDetails(WithdrawalDetailsModel item) async {
    await AppNavigator.pushNamed(
      context,
      RouteName.historyWithdrawalDetails,
      arguments: {"id": item.id, "initialDetails": item},
    );

    onRefresh();
  }

  String _formatApiDateTime(DateTime dateTime) {
    final String year = dateTime.year.toString();
    final String month = dateTime.month.toString().padLeft(2, "0");
    final String day = dateTime.day.toString().padLeft(2, "0");
    final String hour = dateTime.hour.toString().padLeft(2, "0");
    final String minute = dateTime.minute.toString().padLeft(2, "0");
    final String second = dateTime.second.toString().padLeft(2, "0");

    return "$year-$month-$day $hour:$minute:$second";
  }

  String _formatDisplayDateTime(DateTime dateTime) {
    final String year = dateTime.year.toString();
    final String month = dateTime.month.toString().padLeft(2, "0");
    final String day = dateTime.day.toString().padLeft(2, "0");
    final String hour = dateTime.hour.toString().padLeft(2, "0");
    final String minute = dateTime.minute.toString().padLeft(2, "0");

    return "$year-$month-$day $hour:$minute";
  }

  String get selectedDateRangeText {
    if (selectedDateFrom == null || selectedDateTo == null) {
      return "請選擇日期時間範圍";
    }

    return "${_formatDisplayDateTime(selectedDateFrom!)} → ${_formatDisplayDateTime(selectedDateTo!)}";
  }

  double _parseAmount(String? amount) {
    if (amount == null || amount.trim().isEmpty) return 0;

    final raw = amount
        .replaceAll("RM", "")
        .replaceAll("rm", "")
        .replaceAll("HKD", "")
        .replaceAll("hkd", "")
        .replaceAll(",", "")
        .trim();

    return double.tryParse(raw) ?? 0;
  }

  String _formatAmount(double value) {
    final parts = value.toStringAsFixed(2).split(".");
    final whole = parts[0];
    final decimal = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final reverseIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(",");
      }
    }

    return "${buffer.toString()}.$decimal";
  }

  Future<void> getWithdrawalList() async {
    await ApiService.api.getWithdrawalsApprovedList(
      page: page,
      dateFrom: selectedDateFrom != null
          ? _formatApiDateTime(selectedDateFrom!)
          : null,
      dateTo: selectedDateTo != null
          ? _formatApiDateTime(selectedDateTo!)
          : null,
      onSuccess: (response) {
        withdrawalList.addAll(
          List.from(
            response.data['withdrawals'],
          ).map((element) => WithdrawalDetailsModel.fromJson(element)).toList(),
        );

        if (response.data['total_amount'] != null) {
          totalAmount = response.data['total_amount'];
        }
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
}
