import '../../imports.dart';
import 'package:easy_pay_bank_infomrm/controller/history_withdrawal_details_controller.dart';

class HistoryWithdrawalDetailsScreen extends StatefulWidget {
  final int id;
  final WithdrawalDetailsModel initialDetails;

  const HistoryWithdrawalDetailsScreen({
    super.key,
    required this.id,
    required this.initialDetails,
  });

  @override
  State<HistoryWithdrawalDetailsScreen> createState() =>
      _HistoryWithdrawalDetailsScreenState();
}

class _HistoryWithdrawalDetailsScreenState
    extends State<HistoryWithdrawalDetailsScreen> {
  late final HistoryWithdrawalDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HistoryWithdrawalDetailsController()
      ..setInit(id: widget.id, initialDetails: widget.initialDetails);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Future<void> _copyText(
    BuildContext context, {
    required String value,
    required String label,
    required String fieldCopied,
  }) async {
    final String copiedTimeText = _controller.getLatestCopiedTimeText(
      fieldCopied,
    );

    if (copiedTimeText.isNotEmpty) {
      final bool shouldCopy = await _showCopyAgainDialog(
        context: context,
        label: label,
        copiedTimeText: copiedTimeText,
      );

      if (!shouldCopy) return;
    }

    await Clipboard.setData(ClipboardData(text: value));

    await _controller.onCopyField(fieldCopied: fieldCopied, valueCopied: value);

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
    return ChangeNotifierProvider<HistoryWithdrawalDetailsController>.value(
      value: _controller,
      child: Consumer<HistoryWithdrawalDetailsController>(
        builder: (BuildContext context, controller, _) {
          final details = controller.withdrawalDetails;
          final bool isKuaizhuan = _isKuaizhuan(details.type);

          final String createdAt = _displayValue(details.createdAt);
          final String completedAt = _displayValue(details.completedAt);
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

          return Scaffold(
            backgroundColor: AppColors.pageBgColor,
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: AppColors.pageBgColor,
              surfaceTintColor: AppColors.pageBgColor,
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
                context.tr(AppStrings.transferDetails),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTextColor,
                fontSize: kFont20,
              ),
            ),
            body: SafeArea(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicatorWidget())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20).r,
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blackColor.wOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  label: context.tr(AppStrings.completedAt),
                                  value: completedAt,
                                ),
                                12.heightSpace,
                                _headerInfoRow(
                                  context: context,
                                  label: context.tr(AppStrings.merchant),
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
                                24.heightSpace,
                                if (isKuaizhuan)
                                  _infoTile(
                                    context: context,
                                    label: context.tr(AppStrings.mobileNumber),
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
                                        .getLatestCopiedTimeText("mobile_no"),
                                  )
                                else ...[
                                  _infoTile(
                                    context: context,
                                    label: context.tr(AppStrings.bankAccount),
                                    value: bankAccount,
                                    onCopy: () => _copyText(
                                      context,
                                      value: bankAccount,
                                      label: context.tr(AppStrings.bankAccount),
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
                                    label: context.tr(AppStrings.bankName),
                                    value: bankName,
                                    onCopy: () => _copyText(
                                      context,
                                      value: bankName,
                                      label: context.tr(AppStrings.bankName),
                                      fieldCopied: "bank_name",
                                    ),
                                    copiedTimeText: controller
                                        .getLatestCopiedTimeText("bank_name"),
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
                                      .getLatestCopiedTimeText(nameFieldCopied),
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
                                    label: context.tr(AppStrings.amount),
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
          );
        },
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
