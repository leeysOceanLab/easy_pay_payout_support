// Project imports:
import '../imports.dart';
import '../configs/app_config.dart';
import '../services/notification/bubble_service.dart';

class MainController with ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();
  bool isLoading = true;
  bool _isFetchingList = false;
  TextEditingController searchTextController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  dynamic filters = {};
  List<WithdrawalOrderModel> priorityList = [];
  List<WithdrawalOrderModel> manualWithdrawalList = [];
  List<WithdrawalOrderModel> withdrawalList = [];
  WithdrawalDetailsModel withdrawalDetails = WithdrawalDetailsModel();
  int page = 1;
  final ScrollController scrollController = ScrollController();

  List<UUMemberModel> uuMembers = [];

  String get activeUUMemberName {
    final List<UUMemberModel> active = uuMembers
        .where((e) => e.isActive == true)
        .toList();
    if (active.isEmpty) return '未选择';

    final UUMemberModel member = active.first;
    final String name = member.name ?? '未选择';
    final String bank = member.bank ?? '';
    return bank.isEmpty ? name : '$name - ${_truncateBankName(bank)}';
  }

  String _truncateBankName(String bank, {int maxLength = 6}) {
    if (bank.length <= maxLength) return bank;
    return '${bank.substring(0, maxLength)}…';
  }

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
    if (_isFetchingList) {
      refreshController.refreshCompleted();
      return;
    }
    _isFetchingList = true;
    isLoading = true;
    page = 1;
    priorityList = [];
    manualWithdrawalList = [];
    withdrawalList = [];
    update();
    await getWithdrawalList();
    refreshController.refreshCompleted();
    isLoading = false;
    _isFetchingList = false;
    await getUUMembers();
    update();
  }

  void onLoading() async {
    if (_isFetchingList) {
      refreshController.loadComplete();
      return;
    }
    _isFetchingList = true;
    await getWithdrawalList();
    _isFetchingList = false;
    update();
  }

  bool isLoadingUUMembers = false;

  Future<void> getUUMembers() async {
    isLoadingUUMembers = true;
    update();

    await ApiService.api.getUUMembers(
      onSuccess: (response) {
        final raw = response.data['members'];
        if (raw is List) {
          uuMembers = raw
              .map((e) => UUMemberModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      },
      onError: (error) {},
    );

    isLoadingUUMembers = false;
    update();
  }

  Future<void> activateUUMember(int memberId) async {
    bool success = false;

    await ApiService.api.activateUUMember(
      memberId: memberId,
      showLoader: true,
      onSuccess: (response) {
        success = true;
        response.showMessage();
      },
    );

    if (success) {
      await getUUMembers();
    }
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

    if (AppConfig.instance.bubbleOnTap) {
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
    }

    if (AppConfig.instance.detailsOnTap) {
      // ignore: use_build_context_synchronously
      await AppNavigator.pushNamed(
        context,
        RouteName.withdrawalDetails,
        arguments: {
          "id": d.id ?? 0,
          "details": d,
          "lockedByMe": lockedByMe ?? true,
        },
      );
    }

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
        if (page == 1) {
          final rawPriority = response.data['priority'];
          if (rawPriority is List) {
            priorityList =
                rawPriority
                    .map(
                      (e) => WithdrawalOrderModel.fromJson(
                        Map<String, dynamic>.from(e),
                      ),
                    )
                    .toList()
                  ..sort(
                    (a, b) =>
                        (a.priorityValue ?? 0).compareTo(b.priorityValue ?? 0),
                  );
          }

          final rawManual = response.data['manual_withdrawals'];
          if (rawManual is List) {
            manualWithdrawalList = rawManual
                .map(
                  (e) => WithdrawalOrderModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList();
          }
        }

        final excludedIds = {
          ...priorityList.map((e) => e.id),
          ...manualWithdrawalList.map((e) => e.id),
        };
        final rawWithdrawals = response.data['withdrawals'];
        if (rawWithdrawals is List) {
          withdrawalList.addAll(
            rawWithdrawals
                .map(
                  (e) => WithdrawalOrderModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .where((e) => !excludedIds.contains(e.id))
                .toList(),
          );
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
