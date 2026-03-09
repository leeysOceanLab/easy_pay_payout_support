import '../../controller/history_controller.dart';
import '../../imports.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryController()..onRefresh(),
      child: Consumer<HistoryController>(
        builder: (BuildContext context, controller, _) {
          return Scaffold(
            backgroundColor: AppColors.pageBgColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppColors.pageBgColor,
              surfaceTintColor: AppColors.pageBgColor,
              titleSpacing: 16.w,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryTextColor,
                ),
              ),
              title: AppText(
                context.tr(AppStrings.history),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTextColor,
              ),
            ),
            body: SmartRefresherWrapper(
              controller: controller.refreshController,
              enablePullDown: true,
              enablePullUp:
                  !controller.isLoading && controller.withdrawalList.isNotEmpty,
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

  Widget _buildTransactionItem(
    WithdrawalDetailsModel item,
    HistoryController controller,
  ) {
    String typeText = item.type ?? "-";
    if (typeText.toLowerCase() == "kuaizhuan") {
      typeText = context.tr(AppStrings.fastTransfer);
    } else if (typeText.toLowerCase() == "bank" ||
        typeText.toLowerCase() == "bank_transfer") {
      typeText = context.tr(AppStrings.bankTransfer);
    }

    final String txId = _displayValue(item.txId);
    final String merchantName = _displayValue(item.merchantName);
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "$merchantName • $typeText",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryTextColor,
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
      ),
    );
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty || value.trim() == "null") {
      return "-";
    }
    return value.trim();
  }
}
