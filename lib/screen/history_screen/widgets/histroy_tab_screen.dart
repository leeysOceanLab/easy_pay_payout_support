import 'package:easy_pay_bank_infomrm/controller/history_list_controller.dart';

import '../../../imports.dart';

class HistoryTabContent extends StatefulWidget {
  final HistoryTabType type;

  const HistoryTabContent({super.key, required this.type});

  @override
  State<HistoryTabContent> createState() => _HistoryTabContentState();
}

class _HistoryTabContentState extends State<HistoryTabContent> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryListController()..setInit(widget.type),
      child: Consumer<HistoryListController>(
        builder: (BuildContext context, controller, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0).r,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16).r,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.type == HistoryTabType.history
                          ? _buildDateRangePicker(controller)
                          : _buildCurrentDateView(controller),
                      10.heightSpace,
                      1.dividerHorizontal,
                      5.heightSpace,
                      _buildTotalAmountCard(controller),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SmartRefresherWrapper(
                  controller: controller.refreshController,
                  enablePullDown: true,
                  enablePullUp:
                      !controller.isLoading &&
                      controller.withdrawalList.isNotEmpty,
                  isLoading: controller.isLoading,
                  onRefresh: controller.onRefresh,
                  onLoading: controller.onLoading,
                  child: controller.withdrawalList.isEmpty
                      ? _buildEmptyView()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24).r,
                          itemCount: controller.withdrawalList.length,
                          itemBuilder: (context, index) {
                            final item = controller.withdrawalList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12).r,
                              child: _buildTransactionItem(item, controller),
                            );
                          },
                        ),
                ),
              ),
            ],
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
            Icon(
              Icons.history_rounded,
              size: 56.sp,
              color: AppColors.greyColor,
            ),
            12.heightSpace,
            AppText(
              context.tr(AppStrings.noHistoryYet),
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

  Widget _buildCurrentDateView(HistoryListController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AppText(
          context.tr(AppStrings.dateRange),
          fontSize: kFont14,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryTextColor,
        ),
        5.heightSpace,
        AppText(
          "${_formatTopDate(tryParseDate(controller.shiftStart), context.tr(AppStrings.fromDate))} - ${_formatTopDate(tryParseDate(controller.shiftEnd), context.tr(AppStrings.untilNow))}",
          fontSize: kFont14,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryTextColor,
        ),
      ],
    );
  }

  Widget _buildDateRangePicker(HistoryListController controller) {
    return InkWellWrapper(
      onTap: () async {
        final List<DateTime>? results = await showOmniDateTimeRangePicker(
          context: context,
          startInitialDate:
              controller.selectedDateFrom ??
              DateTime.now().subtract(const Duration(days: 7)),
          startFirstDate: DateTime.now().subtract(const Duration(days: 30)),
          startLastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          endInitialDate: controller.selectedDateTo ?? DateTime.now(),
          endFirstDate: DateTime(2024, 1, 1),
          endLastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          is24HourMode: true,
          isShowSeconds: false,
          minutesInterval: 1,
          secondsInterval: 1,
          isForce2Digits: true,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          constraints: const BoxConstraints(maxWidth: 360, maxHeight: 650),
          transitionDuration: const Duration(milliseconds: 200),
          barrierDismissible: true,
        );

        if (results == null || results.length < 2) return;
        if (!mounted) return;

        final DateTime dateFrom = DateTime(
          results[0].year,
          results[0].month,
          results[0].day,
          results[0].hour,
          results[0].minute,
          0,
        );

        final DateTime dateTo = DateTime(
          results[1].year,
          results[1].month,
          results[1].day,
          results[1].hour,
          results[1].minute,
          59,
        );

        if (dateTo.isBefore(dateFrom)) {
          ToastHelper.showToast("日期時間範圍不正確");
          return;
        }

        await controller.applyDateRange(dateFrom: dateFrom, dateTo: dateTo);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            context.tr(AppStrings.dateRange),
            fontSize: kFont14,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryTextColor,
          ),
          5.heightSpace,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      context.tr(AppStrings.fromDate),
                      fontSize: kFont12,
                      fontWeight: FontWeight.normal,
                      color: AppColors.secondaryTextColor,
                    ),
                    6.heightSpace,
                    AppText(
                      _formatTopDate(controller.selectedDateFrom, null),
                      fontSize: kFont14,
                      fontWeight: FontWeight.normal,
                      color: AppColors.primaryTextColor,
                    ),
                  ],
                ),
              ),
              16.widthSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      context.tr(AppStrings.toDate),
                      fontSize: kFont12,
                      fontWeight: FontWeight.normal,
                      color: AppColors.secondaryTextColor,
                    ),
                    6.heightSpace,
                    AppText(
                      _formatTopDate(controller.selectedDateTo, null),
                      fontSize: kFont14,
                      fontWeight: FontWeight.normal,
                      color: AppColors.primaryTextColor,
                    ),
                  ],
                ),
              ),
              if (controller.selectedDateFrom != null &&
                  controller.selectedDateTo != null) ...[
                12.widthSpace,
                InkWell(
                  onTap: () async {
                    await controller.clearDateRange();
                  },
                  borderRadius: BorderRadius.circular(8).r,
                  child: Padding(
                    padding: const EdgeInsets.all(6).r,
                    child: Icon(
                      Icons.filter_alt_off_rounded,
                      size: 20.sp,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTopDate(DateTime? value, String? msg) {
    if (value == null) return msg ?? "請選擇";

    final String day = value.day.toString().padLeft(2, "0");
    final String month = value.month.toString().padLeft(2, "0");
    final String year = value.year.toString();
    final String hour = value.hour.toString().padLeft(2, "0");
    final String minute = value.minute.toString().padLeft(2, "0");

    return "$day/$month/$year $hour:$minute";
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

  Widget _buildTransactionItem(
    WithdrawalDetailsModel item,
    HistoryListController controller,
  ) {
    String typeText = item.type ?? "-";
    if (typeText.toLowerCase() == "kuaizhuan") {
      typeText = context.tr(AppStrings.fastTransfer);
    } else if (typeText.toLowerCase() == "bank" ||
        typeText.toLowerCase() == "bank_transfer") {
      typeText = context.tr(AppStrings.bankTransfer);
    }

    final String txId = _displayValue(item.txId);
    final String completedAt = _displayValue(item.completedAt);

    return InkWellWrapper(
      onTap: () async {
        await controller.goToWithdrawalDetails(item);
      },
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AppText(
                              typeText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                          _buildAmountDisplay(item.withdrawAmount),
                        ],
                      ),
                      10.heightSpace,
                      AppText(
                        txId,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryTextColor,
                      ),
                      10.heightSpace,
                      AppText(
                        "${context.tr(AppStrings.completedAt)}: $completedAt",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryTextColor,
                      ),
                    ],
                  ),
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

  Widget _buildWithdrawalExtraInfoSection(WithdrawalDetailsModel item) {
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

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty || value.trim() == "null") {
      return "-";
    }
    return value.trim();
  }

  Widget _buildTotalAmountCard(HistoryListController controller) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                context.tr(AppStrings.totalAmount),
                fontSize: kFont14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryTextColor,
              ),
              6.heightSpace,
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h, right: 6.w),
                    child: AppText(
                      context.tr(AppStrings.hkd),
                      fontSize: kFont13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      controller.totalAmount ?? "0.00",
                      fontSize: kFont26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                      maxLines: 1,
                      isOverflow: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
