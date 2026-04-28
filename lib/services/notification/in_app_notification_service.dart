import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../components/widgets/app_text.dart';
import '../../configs/app_colors.dart';
import '../../configs/app_strings.dart';
import '../../services/navigation_service.dart';
import 'package:easy_localization/easy_localization.dart';

class InAppNotificationService {
  static OverlayEntry? _entry;
  static final GlobalKey<_HeadsUpBannerState> _bannerKey =
      GlobalKey<_HeadsUpBannerState>();

  static void show({
    required String txId,
    required bool isKuaizhuan,
    required String amount,
    required String name,
    required String accountNumber,
    required String mobile,
    required VoidCallback onCopyAmount,
    required VoidCallback onCopyMain,
  }) {
    final OverlayState? overlayState =
        NavigationService.navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    // If already showing same txId, skip
    if (_entry != null && _bannerKey.currentState?._txId == txId) return;

    dismiss();

    _entry = OverlayEntry(
      builder: (_) => _HeadsUpBanner(
        key: _bannerKey,
        txId: txId,
        isKuaizhuan: isKuaizhuan,
        amount: amount,
        name: name,
        accountNumber: accountNumber,
        mobile: mobile,
        onCopyAmount: onCopyAmount,
        onCopyMain: onCopyMain,
      ),
    );

    overlayState.insert(_entry!);
  }

  static void dismiss() {
    _entry?.remove();
    _entry = null;
  }
}

class _HeadsUpBanner extends StatefulWidget {
  final String txId;
  final bool isKuaizhuan;
  final String amount;
  final String name;
  final String accountNumber;
  final String mobile;
  final VoidCallback onCopyAmount;
  final VoidCallback onCopyMain;

  const _HeadsUpBanner({
    super.key,
    required this.txId,
    required this.isKuaizhuan,
    required this.amount,
    required this.name,
    required this.accountNumber,
    required this.mobile,
    required this.onCopyAmount,
    required this.onCopyMain,
  });

  @override
  State<_HeadsUpBanner> createState() => _HeadsUpBannerState();
}

class _HeadsUpBannerState extends State<_HeadsUpBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late String _txId;

  @override
  void initState() {
    super.initState();
    _txId = widget.txId;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String typeLabel = widget.isKuaizhuan
        ? context.tr(AppStrings.fastTransfer)
        : context.tr(AppStrings.bankTransfer);

    final String mainLabel = widget.isKuaizhuan
        ? context.tr(AppStrings.mobileNumber)
        : context.tr(AppStrings.bankAccount);

    final String mainValue =
        widget.isKuaizhuan ? widget.mobile : widget.accountNumber;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnim,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(16).r,
              shadowColor: Colors.black26,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(16).r,
                ),
                padding: EdgeInsets.all(14.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: icon + txId
                    Row(
                      children: [
                        Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNoContextColor,
                            borderRadius: BorderRadius.circular(8).r,
                          ),
                          child: Icon(
                            Icons.notifications_active_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                context.tr(AppStrings.txIdLabel),
                                fontSize: 11,
                                color: Colors.white60,
                                fontWeight: FontWeight.w500,
                              ),
                              AppText(
                                widget.txId,
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isKuaizhuan
                                ? const Color(0xFF0D9488).withValues(alpha: 0.25)
                                : const Color(0xFF0066F6).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6).r,
                          ),
                          child: AppText(
                            typeLabel,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: widget.isKuaizhuan
                                ? const Color(0xFF2DD4BF)
                                : const Color(0xFF60A5FA),
                          ),
                        ),
                      ],
                    ),

                    Divider(
                      height: 18.h,
                      color: Colors.white12,
                    ),

                    // Info rows
                    _infoRow(
                      label: context.tr(AppStrings.holderName),
                      value: widget.name,
                    ),
                    6.verticalSpace,
                    _infoRow(
                      label: mainLabel,
                      value: mainValue,
                    ),
                    6.verticalSpace,
                    _infoRow(
                      label: context.tr(AppStrings.amount),
                      value: '${context.tr(AppStrings.hkd)} ${widget.amount}',
                      valueColor: const Color(0xFFFBBF24),
                      valueFontSize: 16,
                      valueFontWeight: FontWeight.w800,
                    ),

                    12.verticalSpace,

                    // Copy buttons
                    Row(
                      children: [
                        Expanded(
                          child: _copyButton(
                            label: context.tr(AppStrings.copyAmount),
                            icon: Icons.attach_money_rounded,
                            onTap: widget.onCopyAmount,
                            color: const Color(0xFFFBBF24),
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: _copyButton(
                            label: widget.isKuaizhuan
                                ? context.tr(AppStrings.copyPhone)
                                : context.tr(AppStrings.copyAccountNumber),
                            icon: widget.isKuaizhuan
                                ? Icons.phone_rounded
                                : Icons.account_balance_rounded,
                            onTap: widget.onCopyMain,
                            color: AppColors.primaryNoContextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
    Color? valueColor,
    double? valueFontSize,
    FontWeight? valueFontWeight,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: AppText(
            label,
            fontSize: 12,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: AppText(
            value,
            fontSize: valueFontSize ?? 13,
            color: valueColor ?? Colors.white,
            fontWeight: valueFontWeight ?? FontWeight.w600,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _copyButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10).r,
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15.sp, color: color),
            5.horizontalSpace,
            Flexible(
              child: AppText(
                label,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                maxLines: 1,
                isOverflow: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
