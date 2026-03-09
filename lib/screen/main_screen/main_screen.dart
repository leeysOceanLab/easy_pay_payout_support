import 'package:easy_pay_bank_infomrm/controller/main_controller.dart';

import '../../imports.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<void> _onTapHistory() async {
    await AppNavigator.pushNamed(
      context,
      RouteName.historyWithdrawalList,
      arguments: {},
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
      create: (_) => MainController()..onRefresh(),
      child: Consumer<MainController>(
        builder: (BuildContext context, _mainController, _) {
          return Scaffold(
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
            body: SmartRefresherWrapper(
              controller: _mainController.refreshController,
              enablePullDown: true,
              enablePullUp:
                  !_mainController.isLoading &&
                  _mainController.withdrawalList.isNotEmpty,
              isLoading: _mainController.isLoading,
              onRefresh: _mainController.onRefresh,
              onLoading: _mainController.onLoading,
              child: _mainController.withdrawalList.isEmpty
                  ? _buildEmptyView()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24).r,
                      children: [
                        ..._mainController.groupedWithdrawalList.entries.map((
                          entry,
                        ) {
                          final String date = entry.key;
                          final List<WithdrawalOrderModel> items = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDateHeader(date),
                              12.heightSpace,
                              ...List.generate(items.length, (index) {
                                final item = items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12).r,
                                  child: _buildTransactionItem(
                                    item,
                                    _mainController,
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
          );
        },
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
            )
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16).r,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "${item.merchantName ?? "-"} • $typeText",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                  10.heightSpace,
                  AppText(
                    item.txId ?? "-",
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: txIdColor,
                  ),
                ],
              ),
            ),
            12.widthSpace,
            _buildStatusBadge(
              isLocked: isLocked,
              lockedByMe: lockedByMe,
              lockedByOther: lockedByOther,
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8).r,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: AppText(
        text,
        fontSize: 13,
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
