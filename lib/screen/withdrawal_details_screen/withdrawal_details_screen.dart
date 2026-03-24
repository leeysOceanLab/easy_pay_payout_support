import '../../imports.dart';

class WithdrawalDetailsScreen extends StatefulWidget {
  final int id;
  final WithdrawalDetailsModel? initialDetails;
  final bool? isHistory;
  final bool? isLockedByMe;

  const WithdrawalDetailsScreen({
    super.key,
    required this.id,
    this.initialDetails,
    this.isHistory,
    this.isLockedByMe,
  });

  @override
  State<WithdrawalDetailsScreen> createState() =>
      _WithdrawalDetailsScreenState();
}

class _WithdrawalDetailsScreenState extends State<WithdrawalDetailsScreen> {
  late final WithdrawalDetailsController _withdrawalDetailsController;

  @override
  void initState() {
    super.initState();
    NotificationService.clearOrderNotification();
    _withdrawalDetailsController = WithdrawalDetailsController()
      ..setInit(
        widget.id,
        initialDetails: widget.initialDetails,
        isLockedByMe: widget.isLockedByMe,
      );
  }

  @override
  void dispose() {
    _withdrawalDetailsController.dispose();
    NotificationService.clearOrderNotification();
    super.dispose();
  }

  void _syncToNotification(
    WithdrawalDetailsModel details,
    WithdrawalDetailsController controller,
  ) {
    final bool isKuaizhuan = _isKuaizhuan(details.type);
    if (!controller.isLoading && details.txId != null) {
      Future.microtask(() {
        NotificationService.showOrderNotificationIfNeeded(
          withdrawalId: controller.withdrawalDetails.id ?? 0,
          isKuaizhuan: controller.isKuaizhuan,
          type: controller.withdrawalDetails.type ?? "",
          txId: controller.withdrawalDetails.txId ?? "",
          amount: controller.withdrawalDetails.withdrawAmount ?? "",
          name: controller.withdrawalDetails.holderName ?? "",
          bankName: controller.withdrawalDetails.bankName ?? "",
          accountNumber: controller.withdrawalDetails.accountNumber ?? "",
          mobile: controller.withdrawalDetails.mobileNo ?? "",
        );
      });
    }
  }

  Future<void> _handleBack() async {
    await _withdrawalDetailsController.releaseWithdrawal(null);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<bool> _showCopyAgainDialog({
    required BuildContext context,
    required String label,
    required String copiedTimeText,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: AppText(
            context.tr(AppStrings.copyAgainTitle),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryTextColor,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                context.tr(
                  AppStrings.copyAgainMessage,
                  namedArgs: {"item": label},
                ),
                fontSize: 14,
                color: AppColors.primaryTextColor,
              ),
              if (copiedTimeText.isNotEmpty) ...[
                10.heightSpace,
                AppText(
                  "${context.tr(AppStrings.lastCopiedAt)}: $copiedTimeText",
                  fontSize: 12,
                  color: AppColors.secondaryTextColor,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: AppText(
                context.tr(AppStrings.cancel),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryTextColor,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: AppText(
                context.tr(AppStrings.copyAgainConfirm),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryNoContextColor,
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<bool> _showIncompleteConfirmDialog(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.whiteColor,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24).r,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24).r,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16).r,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: AppColors.redColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18).r,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.incompleteButtonColor,
                    size: 28.sp,
                  ),
                ),
                16.heightSpace,
                AppText(
                  context.tr(AppStrings.confirmProblemOrderTitle),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTextColor,
                  textAlign: TextAlign.center,
                ),
                10.heightSpace,
                AppText(
                  context.tr(AppStrings.confirmProblemOrderMessage),
                  fontSize: 14,
                  color: AppColors.secondaryTextColor,
                  textAlign: TextAlign.center,
                ),
                22.heightSpace,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(0, 48.h),
                          side: BorderSide(color: AppColors.greyLightColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14).r,
                          ),
                        ),
                        child: AppText(
                          context.tr(AppStrings.cancel),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),
                    12.widthSpace,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.incompleteButtonColor,
                          minimumSize: Size(0, 48.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14).r,
                          ),
                        ),
                        child: AppText(
                          context.tr(AppStrings.confirm),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.whiteColor,
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

    return result ?? false;
  }

  Future<bool> _showCompleteConfirmDialog(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.whiteColor,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24).r,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24).r,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16).r,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: AppColors.completedButtonColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18).r,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.completedButtonColor,
                    size: 28.sp,
                  ),
                ),
                16.heightSpace,
                AppText(
                  context.tr(AppStrings.confirmCompleteTitle),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTextColor,
                  textAlign: TextAlign.center,
                ),
                10.heightSpace,
                AppText(
                  context.tr(AppStrings.confirmCompleteMessage),
                  fontSize: 14,
                  color: AppColors.secondaryTextColor,
                  textAlign: TextAlign.center,
                ),
                22.heightSpace,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(0, 48.h),
                          side: BorderSide(color: AppColors.greyLightColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14).r,
                          ),
                        ),
                        child: AppText(
                          context.tr(AppStrings.cancel),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),
                    12.widthSpace,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.completedButtonColor,
                          minimumSize: Size(0, 48.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14).r,
                          ),
                        ),
                        child: AppText(
                          context.tr(AppStrings.confirm),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.whiteColor,
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

    return result ?? false;
  }

  Future<void> _copyText(
    BuildContext context, {
    required String value,
    required String label,
    required String fieldCopied,
  }) async {
    final String copiedTimeText = _withdrawalDetailsController
        .getLatestCopiedTimeText(fieldCopied);

    if (copiedTimeText.isNotEmpty) {
      final bool shouldCopy = await _showCopyAgainDialog(
        context: context,
        label: label,
        copiedTimeText: copiedTimeText,
      );

      if (!shouldCopy) return;
    }

    await Clipboard.setData(ClipboardData(text: value));

    await _withdrawalDetailsController.onCopyField(
      fieldCopied: fieldCopied,
      valueCopied: value,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(
          context.tr(AppStrings.copiedItem, namedArgs: {"item": label}),
          color: AppColors.whiteColor,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleIncompleteConfirmed(
    BuildContext context,
    WithdrawalDetailsController controller,
  ) async {
    final bool shouldContinue = await _showIncompleteConfirmDialog(context);
    if (!shouldContinue) return;

    await controller.incompleteWithdrawal();

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _handleConfirmCompleted(
    BuildContext context,
    WithdrawalDetailsController controller,
  ) async {
    final bool shouldContinue = await _showCompleteConfirmDialog(context);
    if (!shouldContinue) return;

    if (!context.mounted) return;

    final ConfirmWithdrawalResult result = await controller.confirmWithdrawal();

    if (!context.mounted) return;
    if (!result.isSuccess) return;

    final WithdrawalDetailsModel? nextWithdrawal = result.nextWithdrawal;

    if (nextWithdrawal == null) {
      final String successText = context.tr(AppStrings.success);
      final String confirmedText = context.tr(
        AppStrings.withdrawalConfirmedSuccessfully,
      );
      final String okayText = context.tr(AppStrings.okay);

      final bool? shouldBack = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20).r,
            ),
            title: AppText(
              successText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryTextColor,
            ),
            content: AppText(
              confirmedText,
              fontSize: 14,
              color: AppColors.primaryTextColor,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: AppText(
                  okayText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.completedButtonColor,
                ),
              ),
            ],
          );
        },
      );

      if (!context.mounted) return;

      if (shouldBack == true) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    final String nextOrderId = nextWithdrawal.txId ?? "-";

    String typeText = nextWithdrawal.type ?? "-";
    if (typeText.toLowerCase() == "kuaizhuan") {
      typeText = context.tr(AppStrings.fastTransfer);
    } else if (typeText.toLowerCase() == "bank" ||
        typeText.toLowerCase() == "bank_transfer") {
      typeText = context.tr(AppStrings.bankTransfer);
    }

    final String successText = context.tr(AppStrings.success);
    final String confirmedText = context.tr(
      AppStrings.withdrawalConfirmedSuccessfully,
    );
    final String nextOrderText = context.tr(AppStrings.nextOrder);
    final String amountText = context.tr(AppStrings.amount);
    final String hkdText = context.tr(AppStrings.hkd);
    final String merchantText = context.tr(AppStrings.merchant);
    final String typeLabelText = context.tr(AppStrings.type);
    final String endText = context.tr(AppStrings.end);
    final String nextOneText = context.tr(AppStrings.nextOne);

    final String? action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: AppText(
            successText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryTextColor,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                confirmedText,
                fontSize: 14,
                color: AppColors.primaryTextColor,
              ),
              10.heightSpace,
              AppText(
                "$nextOrderText: $nextOrderId",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
              10.heightSpace,
              AppText(
                "$amountText: $hkdText ${nextWithdrawal.withdrawAmount}",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
              6.heightSpace,

              AppText(
                "$typeLabelText: $typeText",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop("end");
              },
              child: AppText(
                endText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.redColor,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop("next");
              },
              child: AppText(
                nextOneText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.completedButtonColor,
              ),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    // continue your action handling here
    if (action == "end") {
      await controller.releaseWithdrawal(nextWithdrawal.id);
      AppNavigator.pop(context);
      return;
    }

    if (action == "next") {
      controller.getMyLockedWithdrawal(nextWithdrawal.id ?? 0);
    }
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty || value.trim() == "null") {
      return "-";
    }
    return value.trim();
  }

  String _formatAmountDisplay(String? amount) {
    final raw = _sanitizeAmountForCopy(amount);

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

  String _sanitizeAmountForCopy(String? amount) {
    if (amount == null) return "";

    return amount
        .replaceAll("RM", "")
        .replaceAll("rm", "")
        .replaceAll("HKD", "")
        .replaceAll("hkd", "")
        .replaceAll(",", "")
        .trim();
  }

  bool _isKuaizhuan(String? type) {
    return (type ?? "").toLowerCase() == "kuaizhuan";
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WithdrawalDetailsController>.value(
      value: _withdrawalDetailsController,
      child: Consumer<WithdrawalDetailsController>(
        builder: (BuildContext context, controller, _) {
          final details = controller.withdrawalDetails;
          final bool isKuaizhuan = _isKuaizhuan(details.type);

          final String createdAt = _displayValue(details.createdAt);
          final String txId = _displayValue(details.txId);
          final String amountDisplay = _formatAmountDisplay(
            details.withdrawAmount ?? details.withdrawAmount,
          );
          final String amountCopy = _sanitizeAmountForCopy(
            details.withdrawAmount ?? details.withdrawAmount,
          );

          final String mobileNo = _displayValue(details.mobileNo);
          final String bankAccount = _displayValue(details.accountNumber);
          final String bankName = _displayValue(details.bankName);
          final String merchantName = _displayValue(details.merchantName);

          final String nameLabel = isKuaizhuan
              ? context.tr(AppStrings.holderName)
              : context.tr(AppStrings.accountName);

          final String nameValue = isKuaizhuan
              ? _displayValue(details.holderName)
              : _displayValue(details.accountName);

          final String nameFieldCopied = isKuaizhuan
              ? "holder_name"
              : "account_name";

          final String typeText = isKuaizhuan
              ? context.tr(AppStrings.fastTransfer)
              : context.tr(AppStrings.bankTransfer);

          // 当数据加载完成，且不是在加载状态时，更新通知
          if (!controller.isLoading && details.id != null) {
            // 建议使用 Future.microtask 确保不在 build 过程中直接触发 setState 相关操作
            Future.microtask(() => _syncToNotification(details, controller));
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              await _handleBack();
            },
            child: SessionAwareScaffold(
              backgroundColor: AppColors.pageBgColor,
              appBar: AppBar(
                elevation: 0,
                centerTitle: true,
                backgroundColor: AppColors.pageBgColor,
                surfaceTintColor: AppColors.pageBgColor,
                leading: IconButton(
                  onPressed: _handleBack,
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primaryTextColor,
                  ),
                ),
                title: AppText(
                  context.tr(AppStrings.transferDetails),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTextColor,
                  fontSize: kFont20,
                ),
              ),
              body: SafeArea(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicatorWidget())
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20).r,
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.blackColor.wOpacity(
                                            0.05,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          createdAt,
                                          fontSize: kFont14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryTextColor,
                                        ),
                                        12.heightSpace,
                                        _headerInfoRow(
                                          context: context,
                                          label: context.tr(
                                            AppStrings.merchant,
                                          ),
                                          value: merchantName,
                                        ),
                                        12.heightSpace,
                                        _headerInfoRow(
                                          context: context,
                                          label: context.tr(AppStrings.trxId),
                                          value: txId,
                                        ),
                                        12.heightSpace,
                                        _headerInfoRow(
                                          context: context,
                                          label: context.tr(AppStrings.type),
                                          value: typeText,
                                        ),
                                        12.heightSpace,
                                        _buildRemainingTimeBox(controller),
                                        24.heightSpace,
                                        if (isKuaizhuan)
                                          _infoTile(
                                            context: context,
                                            label: context.tr(
                                              AppStrings.mobileNumber,
                                            ),
                                            value: mobileNo,
                                            onCopy: () => _copyText(
                                              context,
                                              value: mobileNo,
                                              label: context.tr(
                                                AppStrings.mobileNumber,
                                              ),
                                              fieldCopied: "mobile_no",
                                            ),
                                            copiedTimeText: controller
                                                .getLatestCopiedTimeText(
                                                  "mobile_no",
                                                ),
                                          )
                                        else ...[
                                          _infoTile(
                                            context: context,
                                            label: context.tr(
                                              AppStrings.bankAccount,
                                            ),
                                            value: bankAccount,
                                            onCopy: () => _copyText(
                                              context,
                                              value: bankAccount,
                                              label: context.tr(
                                                AppStrings.bankAccount,
                                              ),
                                              fieldCopied: "account_number",
                                            ),
                                            copiedTimeText: controller
                                                .getLatestCopiedTimeText(
                                                  "account_number",
                                                ),
                                          ),
                                          16.heightSpace,
                                          _infoTile(
                                            context: context,
                                            label: context.tr(
                                              AppStrings.bankName,
                                            ),
                                            value: bankName,
                                            onCopy: () => _copyText(
                                              context,
                                              value: bankName,
                                              label: context.tr(
                                                AppStrings.bankName,
                                              ),
                                              fieldCopied: "bank_name",
                                            ),
                                            copiedTimeText: controller
                                                .getLatestCopiedTimeText(
                                                  "bank_name",
                                                ),
                                          ),
                                        ],
                                        16.heightSpace,
                                        _infoTile(
                                          context: context,
                                          label: nameLabel,
                                          value: nameValue,
                                          onCopy: () => _copyText(
                                            context,
                                            value: nameValue,
                                            label: nameLabel,
                                            fieldCopied: nameFieldCopied,
                                          ),
                                          copiedTimeText: controller
                                              .getLatestCopiedTimeText(
                                                nameFieldCopied,
                                              ),
                                        ),
                                        16.heightSpace,
                                        _infoTile(
                                          context: context,
                                          label: context.tr(AppStrings.amount),
                                          value: amountDisplay,
                                          isAmount: true,
                                          onCopy: () => _copyText(
                                            context,
                                            value: amountCopy,
                                            label: context.tr(
                                              AppStrings.amount,
                                            ),
                                            fieldCopied: "withdraw_amount",
                                          ),
                                          copiedTimeText: controller
                                              .getLatestCopiedTimeText(
                                                "withdraw_amount",
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  50.heightSpace,
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: AppColors.pageBgColor,
                            padding: EdgeInsets.fromLTRB(
                              kHorizontalPadding.w,
                              12.h,
                              kHorizontalPadding.w,
                              20.h,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 56.h,
                                    child: ElevatedButton(
                                      onPressed: controller.isActionDisabled
                                          ? null
                                          : () async {
                                              await _handleIncompleteConfirmed(
                                                context,
                                                controller,
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor:
                                            AppColors.incompleteButtonColor,
                                        foregroundColor: AppColors.whiteColor,
                                        disabledBackgroundColor:
                                            AppColors.disableColor,
                                        disabledForegroundColor:
                                            AppColors.whiteColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ).r,
                                        ),
                                      ),
                                      child: AppText(
                                        context.tr(AppStrings.problemOrder),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                  ),
                                ),
                                12.widthSpace,
                                Expanded(
                                  child: SizedBox(
                                    height: 56.h,
                                    child: ElevatedButton(
                                      onPressed: controller.isActionDisabled
                                          ? null
                                          : () async {
                                              await _handleConfirmCompleted(
                                                context,
                                                controller,
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor:
                                            AppColors.completedButtonColor,
                                        foregroundColor: AppColors.whiteColor,
                                        disabledBackgroundColor:
                                            AppColors.disableColor,
                                        disabledForegroundColor:
                                            AppColors.whiteColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ).r,
                                        ),
                                      ),
                                      child: AppText(
                                        context.tr(AppStrings.completed),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRemainingTimeBox(WithdrawalDetailsController controller) {
    final bool showExpired = controller.isTakenByOther || controller.isExpired;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14).r,
      decoration: BoxDecoration(
        color: AppColors.lightRedBackgroundColor,
        borderRadius: BorderRadius.circular(16).r,
        border: Border.all(color: AppColors.lightRedBorderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 18.sp, color: AppColors.redColor),
          8.widthSpace,
          Expanded(
            child: AppText(
              context.tr(AppStrings.remainingTime),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.redColor,
            ),
          ),
          AppText(
            showExpired
                ? context.tr(AppStrings.expired)
                : controller.countdownText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.redColor,
          ),
        ],
      ),
    );
  }

  Widget _headerInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104.w,
          child: AppText(
            label,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryTextColor,
          ),
        ),
        Expanded(
          child: AppText(
            value,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.primaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _infoTile({
    required BuildContext context,
    required String label,
    required String value,
    VoidCallback? onCopy,
    bool isAmount = false,
    bool showCopyButton = true,
    String copiedTimeText = "",
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18).r,
      decoration: BoxDecoration(
        color: AppColors.lightGreyBackgroundColor,
        borderRadius: BorderRadius.circular(18).r,
        border: Border.all(color: AppColors.greyLightColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  fontSize: kFont13,
                  color: AppColors.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
                8.heightSpace,
                isAmount
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.h, right: 6.w),
                            child: AppText(
                              context.tr(AppStrings.hkd),
                              fontSize: kFont15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          Expanded(
                            child: AppText(
                              value,
                              fontSize: kFont28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryTextColor,
                              maxLines: 1,
                              isOverflow: true,
                            ),
                          ),
                        ],
                      )
                    : AppText(
                        value,
                        fontSize: kFont24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryTextColor,
                      ),
                if (copiedTimeText.isNotEmpty) ...[
                  8.heightSpace,
                  AppText(
                    "${context.tr(AppStrings.lastCopiedAt)}: $copiedTimeText",
                    fontSize: kFont12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryTextColor,
                  ),
                ],
              ],
            ),
          ),
          if (showCopyButton && onCopy != null) ...[
            12.widthSpace,
            InkWell(
              onTap: value == "-" ? null : onCopy,
              borderRadius: BorderRadius.circular(14).r,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ).r,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimaryColor,
                  borderRadius: BorderRadius.circular(14).r,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.copy_rounded,
                      size: 18.sp,
                      color: AppColors.primaryNoContextColor,
                    ),
                    6.widthSpace,
                    AppText(
                      context.tr(AppStrings.copy),
                      color: AppColors.primaryNoContextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
