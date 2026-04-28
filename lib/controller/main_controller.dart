// Project imports:
import '../imports.dart';
import '../configs/app_config.dart';
import '../services/notification/bubble_service.dart';

class MainController with ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();
  bool isLoading = true;
  TextEditingController searchTextController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  dynamic filters = {};
  List<WithdrawalOrderModel> withdrawalList = [];
  WithdrawalDetailsModel withdrawalDetails = WithdrawalDetailsModel();
  int page = 1;
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    refreshController.dispose();
    searchTextController.dispose();
    searchFocusNode.dispose();
    _isDisposed = true;
    super.dispose();
  }

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void setInit() {
    onRefresh();
  }

  void onRefresh() async {
    isLoading = true;
    page = 1;
    withdrawalList = [];
    update();
    // await getMyLockedWithdrawal();
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

  Future<void> getMyLockedWithdrawal() async {
    WithdrawalDetailsModel? lockedDetails;

    await ApiService.api.myLockedWithdrawal(
      onSuccess: (response) {
        if (response.data['withdrawal'] == null) {
          return;
        }

        lockedDetails = WithdrawalDetailsModel.fromJson(
          Map<String, dynamic>.from(response.data['withdrawal']),
        );
      },
      onError: (error) {},
    );

    if (lockedDetails == null) return;

    withdrawalDetails = lockedDetails!;

    // await AppNavigator.pushNamed(
    //   context,
    //   RouteName.withdrawalDetails,
    //   arguments: {"id": withdrawalDetails.id, "details": withdrawalDetails},
    // );

    // onRefresh();
    goToWithdrawalDetails(
      withdrawalDetails.id ?? 0,
      detailsItem: withdrawalDetails,
    );
  }

  Future<void> goToWithdrawalDetails(
    int id, {
    WithdrawalDetailsModel? detailsItem,
    bool? lockedByMe,
  }) async {
    WithdrawalDetailsModel? details = detailsItem;

    if (details == null) {
      bool success = false;
      Loader.show();
      await ApiService.api.lockWithdrawalDetails(
        id: id,
        onSuccess: (response) {
          final raw = response.data['withdrawal'];
          if (raw != null) {
            details = WithdrawalDetailsModel.fromJson(
              Map<String, dynamic>.from(raw),
            );
            success = true;
          }
        },
        onError: (error) {},
      );
      Loader.hide();
      if (!success || details == null) {
        onRefresh();
        return;
      }
    }

    final d = details!;
    final bool isKuaizhuan = (d.type ?? '').toLowerCase() == 'kuaizhuan';

    await BubbleService.dismissAll();
    await BubbleService.showBubble(
      withdrawalId: d.id ?? 0,
      txId: d.txId ?? '',
      isKuaizhuan: isKuaizhuan,
      amount: _sanitizeAmount(d.withdrawAmount),
      name: d.holderName ?? d.accountName ?? '',
      accountNumber: d.accountNumber ?? '',
      mobile: d.mobileNo ?? '',
      bankName: d.bankName ?? '',
      createdAt: d.createdAt ?? '',
      lockExpiresAt: d.lockExpiresAt ?? '',
      token: await SecureStorage().readLoginToken() ?? '',
      apiBaseUrl: AppConfig.instance.apiBaseUrl,
    );

    onRefresh();
  }

  String _sanitizeAmount(String? amount) {
    if (amount == null) return '';
    return amount
        .replaceAll('HKD', '')
        .replaceAll('hkd', '')
        .replaceAll('RM', '')
        .replaceAll('rm', '')
        .replaceAll(',', '')
        .trim();
  }

  Future<void> getWithdrawalList() async {
    await ApiService.api.getWithdrawalsList(
      page: page,
      onSuccess: (response) {
        withdrawalList.addAll(
          List.from(
            response.data['withdrawals'],
          ).map((element) => WithdrawalOrderModel.fromJson(element)).toList(),
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

  Map<String, List<WithdrawalOrderModel>> get groupedWithdrawalList {
    final Map<String, List<WithdrawalOrderModel>> grouped = {};

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
