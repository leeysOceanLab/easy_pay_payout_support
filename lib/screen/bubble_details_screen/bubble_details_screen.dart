import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../api/api_service.dart';
import '../../configs/app_strings.dart';
import '../../controller/withdrawal_details_controller.dart';
import '../../models/uu_member_model.dart';

/// Embedded Flutter screen shown inside the Android Bubble.
/// Reuses [WithdrawalDetailsController] for copy-logs, API actions,
/// and copy-again dialog — exactly the same logic as WithdrawalDetailsScreen.
class BubbleDetailsScreen extends StatefulWidget {
  final int withdrawalId;

  const BubbleDetailsScreen({super.key, required this.withdrawalId});

  @override
  State<BubbleDetailsScreen> createState() => _BubbleDetailsScreenState();
}

class _BubbleDetailsScreenState extends State<BubbleDetailsScreen> {
  // Nullable until first frame (NavigationService.context needs Navigator ready).
  WithdrawalDetailsController? _controller;

  // ── Colours (inline to avoid AppColors / ScreenUtil dependency) ──────────
  static const Color _bg = Color(0xFF1C1C1E);
  static const Color _surface = Color(0xFF2C2C2E);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _grey = Color(0xFF8E8E93);
  static const Color _greyText = Color(0xFFAAAAAA);
  static const Color _teal = Color(0xFF2DD4BF);
  static const Color _amber = Color(0xFFFBBF24);
  static const Color _red = Color(0xFFFF453A);
  static const Color _green = Color(0xFF30D158);
  static const Color _disabled = Color(0xFF3A3A3C);

  List<UUMemberModel> _uuMembers = [];
  bool _isLoadingUUMembers = false;

  String get _activeUUMemberName {
    final List<UUMemberModel> active = _uuMembers
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
  void initState() {
    super.initState();
    _loadUUMembers();
    // Defer to post-frame so NavigationService.navigatorKey.currentContext
    // is set before WithdrawalDetailsController accesses it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = WithdrawalDetailsController();
      ctrl.setInit(widget.withdrawalId);
      if (mounted) {
        setState(() => _controller = ctrl);
      }
    });
  }

  Future<void> _loadUUMembers() async {
    if (!mounted) return;
    setState(() => _isLoadingUUMembers = true);

    await ApiService.api.getUUMembers(
      onSuccess: (response) {
        final raw = response.data['members'];
        if (raw is List) {
          _uuMembers = raw
              .map((e) => UUMemberModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      },
      onError: (error) {},
    );

    if (!mounted) return;
    setState(() => _isLoadingUUMembers = false);
  }

  Future<void> _confirmActivateUUMember(
    BuildContext context,
    UUMemberModel member,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        iconColor: _teal,
        icon: Icons.swap_horiz_rounded,
        title: '切换 UUPay 账号',
        message: '确定要切换到「${member.name ?? '-'}」吗？',
        confirmLabel: context.tr(AppStrings.confirm),
        confirmColor: _teal,
      ),
    );
    if (confirmed != true || !mounted) return;

    bool success = false;
    await ApiService.api.activateUUMember(
      memberId: member.id ?? 0,
      onSuccess: (response) {
        success = true;
      },
    );
    if (!success) return;

    await _loadUUMembers();
  }

  void _showUUMemberPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UUPay账号',
                  style: TextStyle(
                    color: _white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (_uuMembers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        '暂无可选账号',
                        style: const TextStyle(color: _greyText),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _uuMembers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final UUMemberModel member = _uuMembers[index];
                        final bool isActive = member.isActive == true;

                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: isActive
                              ? null
                              : () {
                                  Navigator.of(ctx).pop();
                                  _confirmActivateUUMember(context, member);
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isActive ? _teal.withOpacity(0.15) : _bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isActive ? _teal : Colors.white12,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${member.name ?? '-'} - ${member.bank ?? '-'}',
                                        style: const TextStyle(
                                          color: _white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '账号: ${member.accountNumber ?? '-'}',
                                        style: const TextStyle(
                                          color: _greyText,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _teal,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      '使用中',
                                      style: TextStyle(
                                        color: Color(0xFF1C1C1E),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: _grey,
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUUMemberBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showUUMemberPicker(context),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 14,
                    color: _teal,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'UUPay账号 - $_activeUUMemberName',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _grey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _isLoadingUUMembers ? null : _loadUUMembers,
            child: SizedBox(
              width: 16,
              height: 16,
              child: _isLoadingUUMembers
                  ? const Padding(
                      padding: EdgeInsets.all(2),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _teal,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 16, color: _teal),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ── Copy with "copy-again" confirmation dialog ───────────────────────────

  Future<void> _copyText(
    BuildContext context, {
    required String value,
    required String label,
    required String fieldCopied,
  }) async {
    if (value == '-') return;
    final ctrl = _controller;
    if (ctrl == null) return;

    final String copiedTimeText = ctrl.getLatestCopiedTimeText(fieldCopied);

    if (copiedTimeText.isNotEmpty) {
      final bool shouldCopy = await _showCopyAgainDialog(
        context: context,
        label: label,
        copiedTimeText: copiedTimeText,
      );
      if (!shouldCopy) return;
    }

    await Clipboard.setData(ClipboardData(text: value));
    await ctrl.onCopyField(fieldCopied: fieldCopied, valueCopied: value);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(AppStrings.copiedItem, namedArgs: {'item': label}),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: _teal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _showCopyAgainDialog({
    required BuildContext context,
    required String label,
    required String copiedTimeText,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: Text(
          context.tr(AppStrings.copyAgainTitle),
          style: const TextStyle(
            color: _white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(
                AppStrings.copyAgainMessage,
                namedArgs: {'item': label},
              ),
              style: const TextStyle(color: _greyText, fontSize: 14),
            ),
            if (copiedTimeText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${context.tr(AppStrings.lastCopiedAt)}: $copiedTimeText',
                style: const TextStyle(color: _grey, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              context.tr(AppStrings.cancel),
              style: const TextStyle(color: _grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              context.tr(AppStrings.copyAgainConfirm),
              style: const TextStyle(color: _teal, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Action: 有问题 ─────────────────────────────────────────────────────────

  Future<void> _handleIncomplete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        iconColor: _red,
        icon: Icons.close_rounded,
        title: context.tr(AppStrings.confirmProblemOrderTitle),
        message: context.tr(AppStrings.confirmProblemOrderMessage),
        confirmLabel: context.tr(AppStrings.confirm),
        confirmColor: _red,
      ),
    );
    if (confirmed != true || !mounted) return;

    await _controller?.incompleteWithdrawal();
    if (!mounted) return;
    _closeWithMessage(context, context.tr(AppStrings.success));
  }

  // ── Action: 完成 ───────────────────────────────────────────────────────────

  Future<void> _handleComplete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        iconColor: _green,
        icon: Icons.check_rounded,
        title: context.tr(AppStrings.confirmCompleteTitle),
        message: context.tr(AppStrings.confirmCompleteMessage),
        confirmLabel: context.tr(AppStrings.confirm),
        confirmColor: _green,
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await _controller?.confirmWithdrawal();
    if (!mounted) return;
    if (result == null || !result.isSuccess) return;

    final next = result.nextWithdrawal;
    if (next != null) {
      await _controller?.releaseWithdrawal(next.id);
    }

    // No next order or user chose end → close bubble
    if (!mounted) return;
    _closeWithMessage(
      context,
      context.tr(AppStrings.withdrawalConfirmedSuccessfully),
    );
  }

  void _closeWithMessage(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        content: Text(
          message,
          style: const TextStyle(color: _white, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Close the bubble activity
              SystemNavigator.pop();
            },
            child: Text(
              context.tr(AppStrings.okay),
              style: const TextStyle(
                color: _green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatAmount(String? amount) {
    if (amount == null) return '-';
    final clean = amount
        .replaceAll('HKD', '')
        .replaceAll('hkd', '')
        .replaceAll('RM', '')
        .replaceAll('rm', '')
        .replaceAll(',', '')
        .trim();
    final value = double.tryParse(clean);
    if (value == null) return amount;
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final decimal = parts[1];
    final buf = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final rev = whole.length - i;
      buf.write(whole[i]);
      if (rev > 1 && rev % 3 == 1) buf.write(',');
    }
    return '${buf.toString()}.$decimal';
  }

  String _sanitizeAmount(String? amount) {
    if (amount == null) return '';
    return amount
        .replaceAll('RM', '')
        .replaceAll('rm', '')
        .replaceAll('HKD', '')
        .replaceAll('hkd', '')
        .replaceAll(',', '')
        .trim();
  }

  bool _isKuaizhuan(String? type) => (type ?? '').toLowerCase() == 'kuaizhuan';

  String _display(String? value) {
    if (value == null || value.trim().isEmpty || value.trim() == 'null') {
      return '-';
    }
    return value.trim();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;

    if (ctrl == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _teal)),
      );
    }

    return ChangeNotifierProvider<WithdrawalDetailsController>.value(
      value: ctrl,
      child: Consumer<WithdrawalDetailsController>(
        builder: (ctx, controller, _) {
          final details = controller.withdrawalDetails;
          final bool isKuaizhuan = _isKuaizhuan(details.type);

          final String txId = _display(details.txId);
          final String amountDisplay = _formatAmount(details.withdrawAmount);
          final String amountCopy = _sanitizeAmount(details.withdrawAmount);
          final String name = _display(
            isKuaizhuan ? details.holderName : details.accountName,
          );
          final String nameLabel = isKuaizhuan ? '持卡人' : '账户名';
          final String nameField = isKuaizhuan ? 'holder_name' : 'account_name';
          final String mainValue = _display(
            isKuaizhuan ? details.mobileNo : details.accountNumber,
          );
          final String mainLabel = isKuaizhuan ? '电话' : '账号';
          final String mainField = isKuaizhuan ? 'mobile_no' : 'account_number';
          final String bankName = _display(details.bankName);

          return Scaffold(
            backgroundColor: _bg,
            body: SafeArea(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator(color: _teal))
                  : Column(
                      children: [
                        _buildUUMemberBar(ctx),
                        // ── Scrollable content ───────────────────────────
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row: txId + type badge
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '交易编号',
                                            style: TextStyle(
                                              color: Color(0x99FFFFFF),
                                              fontSize: 11,
                                            ),
                                          ),
                                          Text(
                                            txId,
                                            style: const TextStyle(
                                              color: _white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _TypeBadge(isKuaizhuan: isKuaizhuan),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(color: Color(0x22FFFFFF)),
                                const SizedBox(height: 10),

                                // Amount
                                _InfoTile(
                                  label: '金额',
                                  value: amountDisplay,
                                  prefix: 'HKD',
                                  valueColor: _amber,
                                  copiedTimeText: controller
                                      .getLatestCopiedTimeText(
                                        'withdraw_amount',
                                      ),
                                  onCopy: () => _copyText(
                                    ctx,
                                    value: amountCopy,
                                    label: '金额',
                                    fieldCopied: 'withdraw_amount',
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Name
                                _InfoTile(
                                  label: nameLabel,
                                  value: name,
                                  copiedTimeText: controller
                                      .getLatestCopiedTimeText(nameField),
                                  onCopy: () => _copyText(
                                    ctx,
                                    value: name,
                                    label: nameLabel,
                                    fieldCopied: nameField,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Account / Mobile
                                _InfoTile(
                                  label: mainLabel,
                                  value: mainValue,
                                  copiedTimeText: controller
                                      .getLatestCopiedTimeText(mainField),
                                  onCopy: () => _copyText(
                                    ctx,
                                    value: mainValue,
                                    label: mainLabel,
                                    fieldCopied: mainField,
                                  ),
                                ),

                                // Bank name (bank transfer only)
                                if (!isKuaizhuan) ...[
                                  const SizedBox(height: 8),
                                  _InfoTile(label: '银行', value: bankName),
                                ],

                                // Expired / countdown indicator
                                if (controller.isExpired ||
                                    controller.isTakenByOther) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _red.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _red.withOpacity(0.4),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.timer_off_outlined,
                                          color: _red,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          controller.isTakenByOther
                                              ? '该订单已被他人接取'
                                              : '锁定已过期，按钮已禁用',
                                          style: const TextStyle(
                                            color: _red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (controller.countdownText !=
                                    '00:00') ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _red.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _red.withOpacity(0.25),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.timer_outlined,
                                          color: _red,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '剩余时间',
                                          style: TextStyle(
                                            color: _red,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          controller.countdownText,
                                          style: const TextStyle(
                                            color: _red,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 14),
                              ],
                            ),
                          ),
                        ),

                        // ── Action buttons ───────────────────────────────
                        Container(
                          color: _surface,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: controller.isActionDisabled
                                        ? null
                                        : () => _handleIncomplete(ctx),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _red,
                                      disabledBackgroundColor: _disabled,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      '有问题',
                                      style: TextStyle(
                                        color: _white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: controller.isActionDisabled
                                        ? null
                                        : () => _handleComplete(ctx),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _green,
                                      disabledBackgroundColor: _disabled,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      '完成',
                                      style: TextStyle(
                                        color: _white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
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
          );
        },
      ),
    );
  }
}

// ── Helpers widgets ──────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final bool isKuaizhuan;
  const _TypeBadge({required this.isKuaizhuan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isKuaizhuan ? const Color(0x330D9488) : const Color(0x220066F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isKuaizhuan ? '快转' : '银行转账',
        style: TextStyle(
          color: isKuaizhuan
              ? const Color(0xFF2DD4BF)
              : const Color(0xFF60A5FA),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final String? prefix;
  final Color? valueColor;
  final String copiedTimeText;
  final VoidCallback? onCopy;

  const _InfoTile({
    required this.label,
    required this.value,
    this.prefix,
    this.valueColor,
    this.copiedTimeText = '',
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    const Color _bg = Color(0xFF2C2C2E);
    const Color _teal = Color(0xFF2DD4BF);
    const Color _white = Color(0xFFFFFFFF);
    const Color _grey = Color(0xFF8E8E93);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0x80FFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (prefix != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1, right: 4),
                        child: Text(
                          prefix!,
                          style: const TextStyle(
                            color: Color(0x99FFFFFF),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          color: valueColor ?? _white,
                          fontSize: prefix != null ? 20 : 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (copiedTimeText.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    '上次复制: $copiedTimeText',
                    style: const TextStyle(color: _grey, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
          if (onCopy != null && value != '-') ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onCopy,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _teal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '复制',
                  style: TextStyle(
                    color: _teal,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;

  const _ConfirmDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    const Color _surface = Color(0xFF2C2C2E);
    const Color _white = Color(0xFFFFFFFF);
    const Color _greyText = Color(0xFFAAAAAA);
    const Color _grey = Color(0xFF8E8E93);

    return AlertDialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(color: _greyText, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            context.tr('cancel'),
            style: const TextStyle(color: _grey),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: confirmColor, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
