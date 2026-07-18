import 'package:easy_pay_bank_infomrm/configs/app_config.dart';
import 'package:easy_pay_bank_infomrm/controller/main_controller.dart';
import 'package:easy_pay_bank_infomrm/controller/session_controller.dart';
import 'package:easy_pay_bank_infomrm/services/notification/bubble_service.dart';

import '../../imports.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  String appVersion = '';
  MainController? controller;
  Timer? _autoRefreshTimer;

  Future<void> _onTapHistory() async {
    await AppNavigator.pushNamed(
      context,
      RouteName.historyWithdrawalList,
      arguments: {},
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadAppVersion();
      context.read<SessionController>().start(
        customTimeout: const Duration(minutes: 15),
      );
      if (AppConfig.instance.bubbleOnTap) {
        _checkBubblePermission();
      }
      _startAutoRefresh();
    });
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) controller?.onRefresh();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller?.onRefresh();
    }
  }

  Future<void> _loadAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      appVersion = 'Version ${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  Future<void> _checkBubblePermission() async {
    final bool allowed = await BubbleService.checkPermission();
    if (allowed) return;
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20).r,
        ),
        title: Row(
          children: [
            Icon(
              Icons.bubble_chart_rounded,
              color: AppColors.primaryNoContextColor,
              size: 22.sp,
            ),
            8.widthSpace,
            AppText(
              '开启气泡通知',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryTextColor,
            ),
          ],
        ),
        content: AppText(
          '开启气泡后，点击订单时订单信息会以悬浮气泡方式显示，方便快速复制。\n\n请在下一页找到「气泡」选项并开启。',
          fontSize: 14,
          color: AppColors.secondaryTextColor,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: AppText(
              '稍后',
              fontSize: 14,
              color: AppColors.secondaryTextColor,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              BubbleService.openSettings();
            },
            child: AppText(
              '去开启',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryNoContextColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24).r,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18).r,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16).r,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  context.tr(AppStrings.logout),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTextColor,
                  textAlign: TextAlign.center,
                ),
                12.heightSpace,
                AppText(
                  context.tr(AppStrings.logoutConfirmation),
                  fontSize: 14,
                  color: AppColors.secondaryTextColor,
                  textAlign: TextAlign.center,
                ),
                20.heightSpace,
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44.h,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.greyLightColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12).r,
                            ),
                          ),
                          child: AppText(
                            context.tr(AppStrings.cancel),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                      ),
                    ),
                    12.widthSpace,
                    Expanded(
                      child: SizedBox(
                        height: 44.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            await ApiService.deleteApiToken();

                            if (!mounted) return;

                            Navigator.of(context).pushNamedAndRemoveUntil(
                              RouteName.loginPage,
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12).r,
                            ),
                          ),
                          child: AppText(
                            context.tr(AppStrings.logout),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        controller = MainController()
          ..onRefresh()
          ..getUUMembers();
        return controller!;
      },
      child: Consumer<MainController>(
        builder: (BuildContext context, mainController, _) {
          return SessionAwareScaffold(
            backgroundColor: AppColors.pageBgColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppColors.pageBgColor,
              surfaceTintColor: AppColors.pageBgColor,
              titleSpacing: 16.w,
              title: AppText(
                context.tr(AppStrings.withdrawalOrders),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTextColor,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8).r,
                  child: TextButton.icon(
                    onPressed: _onTapHistory,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12).r,
                      ),
                    ),
                    icon: Icon(
                      Icons.history_rounded,
                      size: 18.sp,
                      color: AppColors.primaryColor,
                    ),
                    label: AppText(
                      context.tr(AppStrings.history),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12).r,
                  child: TextButton.icon(
                    onPressed: _showLogoutDialog,

                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12).r,
                      ),
                    ),
                    icon: Icon(
                      Icons.logout_rounded,
                      size: 18.sp,
                      color: AppColors.primaryColor,
                    ),
                    label: AppText(
                      context.tr(AppStrings.logout),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildUUMemberSelector(mainController),
                Expanded(
                  child: SmartRefresherWrapper(
                    controller: mainController.refreshController,
                    enablePullDown: true,
                    enablePullUp:
                        !mainController.isLoading &&
                        mainController.withdrawalList.isNotEmpty,
                    isLoading: mainController.isLoading,
                    onRefresh: mainController.onRefresh,
                    onLoading: mainController.onLoading,
                    child:
                        mainController.withdrawalList.isEmpty &&
                            mainController.priorityList.isEmpty &&
                            mainController.manualWithdrawalList.isEmpty
                        ? _buildEmptyView()
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              12,
                              16,
                              24,
                            ).r,
                            children: [
                              if (mainController.priorityList.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.push_pin_rounded,
                                      size: 16.sp,
                                      color: AppColors.redColor,
                                    ),
                                    6.widthSpace,
                                    AppText(
                                      '优先订单',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.redColor,
                                    ),
                                  ],
                                ),
                                12.heightSpace,
                                ...List.generate(
                                  mainController.priorityList.length,
                                  (index) {
                                    final item =
                                        mainController.priorityList[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ).r,
                                      child: _buildPriorityTransactionItem(
                                        item,
                                        mainController,
                                        rank: index + 1,
                                      ),
                                    );
                                  },
                                ),
                                20.heightSpace,
                              ],
                              if (mainController
                                  .manualWithdrawalList
                                  .isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.assignment_rounded,
                                      size: 16.sp,
                                      color: const Color(0xFFF97316),
                                    ),
                                    6.widthSpace,
                                    AppText(
                                      '手動內部申請單',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFF97316),
                                    ),
                                  ],
                                ),
                                12.heightSpace,
                                ...List.generate(
                                  mainController.manualWithdrawalList.length,
                                  (index) {
                                    final item = mainController
                                        .manualWithdrawalList[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ).r,
                                      child: _buildManualTransactionItem(
                                        item,
                                        mainController,
                                      ),
                                    );
                                  },
                                ),
                                20.heightSpace,
                              ],
                              ...mainController.groupedWithdrawalList.entries
                                  .map((entry) {
                                    final String date = entry.key;
                                    final List<WithdrawalOrderModel> items =
                                        entry.value;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildDateHeader(date),
                                        12.heightSpace,
                                        ...List.generate(items.length, (index) {
                                          final item = items[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ).r,
                                            child: _buildTransactionItem(
                                              item,
                                              mainController,
                                            ),
                                          );
                                        }),
                                        12.heightSpace,
                                      ],
                                    );
                                  }),
                            ],
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: AppText(
                      appVersion,
                      color: AppColors.primaryLightColor,
                      fontSize: kFont12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmActivateUUMember(
    MainController mainController,
    UUMemberModel member,
  ) {
    DialogHelper().showNormalDialog(
      title: '切换 UUPay 账号',
      description: '确定要切换到「${member.name ?? '-'}」吗？',
      leftButtonText: context.tr(AppStrings.cancel),
      leftFunction: () => AppNavigator.pop(context),
      rightButtonText: context.tr(AppStrings.confirm),
      rightFunction: () {
        AppNavigator.pop(context);
        mainController.activateUUMember(member.id ?? 0);
      },
    );
  }

  Widget _buildUUMemberSelector(MainController mainController) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12).r,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10).r,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14).r,
        border: Border.all(color: AppColors.greyLightColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWellWrapper(
              onTap: () => BottomSheetHelper.uuMembers(
                mainController.uuMembers,
                onSelect: (member) =>
                    _confirmActivateUUMember(mainController, member),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 16.sp,
                    color: AppColors.primaryNoContextColor,
                  ),
                  8.widthSpace,
                  Expanded(
                    child: AppText(
                      'UUPay账号 - ${mainController.activeUUMemberName}',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTextColor,
                      // isOverflow: true,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20.sp,
                    color: AppColors.secondaryTextColor,
                  ),
                ],
              ),
            ),
          ),
          8.widthSpace,
          Container(width: 1, height: 18.h, color: AppColors.greyLightColor),
          8.widthSpace,
          InkWellWrapper(
            onTap: mainController.isLoadingUUMembers
                ? null
                : () => mainController.getUUMembers(),
            child: SizedBox(
              width: 18.sp,
              height: 18.sp,
              child: mainController.isLoadingUUMembers
                  ? SizedBox(
                      width: 14.sp,
                      height: 14.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryNoContextColor,
                      ),
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      size: 18.sp,
                      color: AppColors.primaryNoContextColor,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24).r,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 56.sp, color: AppColors.greyColor),
            12.heightSpace,
            AppText(
              context.tr(AppStrings.noWithdrawalOrdersYet),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTextColor,
              textAlign: TextAlign.center,
            ),
            6.heightSpace,
            AppText(
              context.tr(AppStrings.pullDownToRefreshOrders),
              fontSize: 13,
              color: AppColors.secondaryTextColor,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(String dateKey) {
    return Padding(
      padding: const EdgeInsets.only(left: 4).r,
      child: AppText(
        _formatDateHeader(dateKey),
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.listingSubTextColor,
      ),
    );
  }

  Widget _buildPriorityTransactionItem(
    WithdrawalOrderModel item,
    MainController mainController, {
    required int rank,
  }) {
    final bool isLocked = item.isLocked ?? false;
    final bool lockedByMe = item.lockedByMe ?? false;
    final bool lockedByOther = isLocked && !lockedByMe;
    final bool canClick = !lockedByOther;

    return InkWellWrapper(
      onTap: canClick
          ? () => mainController.goToWithdrawalDetails(
              item.id!,
              detailsItem: null,
              lockedByMe: lockedByMe,
            )
          : null,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(18).r,
          border: Border.all(color: AppColors.redColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.wOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ).r,
              decoration: BoxDecoration(
                color: AppColors.redColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(17).r,
                  topRight: Radius.circular(17).r,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin_rounded,
                    color: AppColors.whiteColor,
                    size: 13.sp,
                  ),
                  5.widthSpace,
                  Expanded(
                    child: AppText(
                      '置顶优先订单',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ).r,
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12).r,
                    ),
                    child: AppText(
                      '#$rank',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8).r,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              _typeText(item),
                              fontSize: kFont14,
                              fontWeight: FontWeight.w600,
                              color: lockedByOther
                                  ? AppColors.listingDisabledTextColor
                                  : AppColors.primaryTextColor,
                            ),
                            10.heightSpace,
                            AppText(
                              item.txId ?? '-',
                              fontSize: kFont16,
                              fontWeight: FontWeight.w800,
                              color: lockedByOther
                                  ? AppColors.listingDisabledTitleColor
                                  : AppColors.primaryTextColor,
                            ),
                          ],
                        ),
                      ),
                      12.widthSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(
                            isLocked: isLocked,
                            lockedByMe: lockedByMe,
                            lockedByOther: lockedByOther,
                          ),
                          _buildAmountDisplay(item.withdrawAmount),
                        ],
                      ),
                    ],
                  ),
                  5.heightSpace,
                  _buildWithdrawalExtraInfoSection(item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualTransactionItem(
    WithdrawalOrderModel item,
    MainController mainController,
  ) {
    const Color manualColor = Color(0xFFF97316);
    final bool isLocked = item.isLocked ?? false;
    final bool lockedByMe = item.lockedByMe ?? false;
    final bool lockedByOther = isLocked && !lockedByMe;
    final bool canClick = !lockedByOther;

    return InkWellWrapper(
      onTap: canClick
          ? () => mainController.goToWithdrawalDetails(
              item.id!,
              detailsItem: null,
              lockedByMe: lockedByMe,
            )
          : null,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(18).r,
          border: Border.all(color: manualColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.wOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ).r,
              decoration: BoxDecoration(
                color: manualColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(17).r,
                  topRight: Radius.circular(17).r,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_rounded,
                    color: AppColors.whiteColor,
                    size: 13.sp,
                  ),
                  5.widthSpace,
                  AppText(
                    '手動內部申請單',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.whiteColor,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8).r,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              _typeText(item),
                              fontSize: kFont14,
                              fontWeight: FontWeight.w600,
                              color: lockedByOther
                                  ? AppColors.listingDisabledTextColor
                                  : AppColors.primaryTextColor,
                            ),
                            10.heightSpace,
                            AppText(
                              item.txId ?? '-',
                              fontSize: kFont16,
                              fontWeight: FontWeight.w800,
                              color: lockedByOther
                                  ? AppColors.listingDisabledTitleColor
                                  : AppColors.primaryTextColor,
                            ),
                          ],
                        ),
                      ),
                      12.widthSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(
                            isLocked: isLocked,
                            lockedByMe: lockedByMe,
                            lockedByOther: lockedByOther,
                          ),
                          _buildAmountDisplay(item.withdrawAmount),
                        ],
                      ),
                    ],
                  ),
                  5.heightSpace,
                  _buildWithdrawalExtraInfoSection(item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeText(WithdrawalOrderModel item) {
    final t = item.type ?? '-';
    if (t.toLowerCase() == 'kuaizhuan')
      return context.tr(AppStrings.fastTransfer);
    if (t.toLowerCase() == 'bank' || t.toLowerCase() == 'bank_transfer') {
      return context.tr(AppStrings.bankTransfer);
    }
    return t;
  }

  Widget _buildTransactionItem(
    WithdrawalOrderModel item,
    MainController mainController,
  ) {
    final bool isLocked = item.isLocked ?? false;
    final bool lockedByMe = item.lockedByMe ?? false;
    final bool lockedByOther = isLocked && !lockedByMe;
    final bool canClick = !lockedByOther;

    String typeText = item.type ?? "-";
    if (typeText.toLowerCase() == "kuaizhuan") {
      typeText = context.tr(AppStrings.fastTransfer);
    } else if (typeText.toLowerCase() == "bank" ||
        typeText.toLowerCase() == "bank_transfer") {
      typeText = context.tr(AppStrings.bankTransfer);
    }

    final Color titleColor = lockedByOther
        ? AppColors.listingDisabledTextColor
        : AppColors.primaryTextColor;

    final Color txIdColor = lockedByOther
        ? AppColors.listingDisabledTitleColor
        : AppColors.primaryTextColor;

    return InkWellWrapper(
      onTap: canClick
          ? () => mainController.goToWithdrawalDetails(
              item.id!,
              detailsItem: null,
              lockedByMe: lockedByMe,
            )
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8).r,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(18).r,
          border: Border.all(color: AppColors.greyLightColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.wOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        typeText,
                        fontSize: kFont14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                      10.heightSpace,
                      AppText(
                        item.txId ?? "-",
                        fontSize: kFont16,
                        fontWeight: FontWeight.w800,
                        color: txIdColor,
                      ),
                    ],
                  ),
                ),
                12.widthSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(
                      isLocked: isLocked,
                      lockedByMe: lockedByMe,
                      lockedByOther: lockedByOther,
                    ),
                    _buildAmountDisplay(item.withdrawAmount),
                  ],
                ),
              ],
            ),
            5.heightSpace,
            _buildWithdrawalExtraInfoSection(item),
          ],
        ),
      ),
    );
  }

  String _sanitizeAmount(String? amount) {
    if (amount == null) return "";

    return amount
        .replaceAll("RM", "")
        .replaceAll("rm", "")
        .replaceAll("HKD", "")
        .replaceAll("hkd", "")
        .replaceAll(",", "")
        .trim();
  }

  String _formatAmountDisplay(String? amount) {
    final raw = _sanitizeAmount(amount);

    if (raw.isEmpty) return "-";

    final value = double.tryParse(raw);
    if (value == null) return raw;

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

  Widget _buildAmountDisplay(String? amount) {
    final String displayAmount = _formatAmountDisplay(amount);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 4.h, right: 4.w),
          child: AppText(
            context.tr(AppStrings.hkd),
            fontSize: kFont12,
            fontWeight: FontWeight.normal,
            color: AppColors.secondaryTextColor,
          ),
        ),
        AppText(
          displayAmount,
          fontSize: kFont18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryNoContextColor,
        ),
      ],
    );
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty || value.trim() == "null") {
      return "-";
    }
    return value.trim();
  }

  Widget _buildWithdrawalExtraInfoSection(WithdrawalOrderModel item) {
    final bool isKuaizhuan = (item.type ?? "").toLowerCase() == "kuaizhuan";

    final String firstLabel = isKuaizhuan
        ? context.tr(AppStrings.mobileNumber)
        : context.tr(AppStrings.bankAccount);

    final String firstValue = isKuaizhuan
        ? _displayValue(item.mobileNo)
        : _displayValue(item.accountNumber);

    final String secondLabel = isKuaizhuan
        ? context.tr(AppStrings.holderName)
        : context.tr(AppStrings.accountName);

    final String secondValue = isKuaizhuan
        ? _displayValue(item.holderName)
        : _displayValue(item.accountName);

    final String thirdLabel = context.tr(AppStrings.bankName);

    final String thridValue = _displayValue(item.bankName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12).r,
      decoration: BoxDecoration(
        color: AppColors.lightGreyBackgroundColor,
        borderRadius: BorderRadius.circular(14).r,
        border: Border.all(color: AppColors.greyLightColor),
      ),
      child: Column(
        children: [
          _buildWithdrawalExtraInfoRow(label: firstLabel, value: firstValue),
          10.heightSpace,
          _buildWithdrawalExtraInfoRow(label: secondLabel, value: secondValue),
          if (!isKuaizhuan) 10.heightSpace,
          if (!isKuaizhuan)
            _buildWithdrawalExtraInfoRow(label: thirdLabel, value: thridValue),
        ],
      ),
    );
  }

  Widget _buildWithdrawalExtraInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96.w,
          child: AppText(
            label,
            fontSize: kFont12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryTextColor,
          ),
        ),
        8.widthSpace,
        Expanded(
          child: AppText(
            value,
            fontSize: kFont13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge({
    required bool isLocked,
    required bool lockedByMe,
    required bool lockedByOther,
  }) {
    Color bgColor;
    Color textColor = AppColors.whiteColor;
    String text;

    if (lockedByOther) {
      bgColor = AppColors.incompleteButtonColor;
      text = context.tr(AppStrings.locked);
    } else if (lockedByMe) {
      bgColor = AppColors.primaryNoContextColor;
      text = context.tr(AppStrings.lockedByMe);
    } else {
      bgColor = AppColors.completedButtonColor;
      text = context.tr(AppStrings.available);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4).r,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: AppText(
        text,
        fontSize: kFont13,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }

  String _formatDateHeader(String dateKey) {
    if (dateKey == "-" || dateKey.isEmpty) {
      return "-";
    }

    try {
      final DateTime dateTime = DateTime.parse(dateKey);

      final List<String> weekdays = [
        context.tr(AppStrings.monShort),
        context.tr(AppStrings.tueShort),
        context.tr(AppStrings.wedShort),
        context.tr(AppStrings.thuShort),
        context.tr(AppStrings.friShort),
        context.tr(AppStrings.satShort),
        context.tr(AppStrings.sunShort),
      ];

      final List<String> months = [
        context.tr(AppStrings.janShort),
        context.tr(AppStrings.febShort),
        context.tr(AppStrings.marShort),
        context.tr(AppStrings.aprShort),
        context.tr(AppStrings.mayShort),
        context.tr(AppStrings.junShort),
        context.tr(AppStrings.julShort),
        context.tr(AppStrings.augShort),
        context.tr(AppStrings.sepShort),
        context.tr(AppStrings.octShort),
        context.tr(AppStrings.novShort),
        context.tr(AppStrings.decShort),
      ];

      final String weekday = weekdays[dateTime.weekday - 1];
      final String month = months[dateTime.month - 1];

      return "$weekday，${dateTime.day.toString().padLeft(2, "0")} $month ${dateTime.year}";
    } catch (e) {
      return dateKey;
    }
  }
}
