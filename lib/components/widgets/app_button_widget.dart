// Project imports:
import '../../imports.dart';

class AppButtonWidget extends StatelessWidget {
  final Function()? onTap;
  final String? text;
  final EdgeInsetsGeometry? padding;
  final Color? textColor;
  final double? radius;
  final double? textSize;
  final FontWeight? fontWeight;
  final Widget? builder;
  final Color? buttonColor;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final List<double>? stops;
  final double? borderStroke;
  final bool textIgnoreLine;
  final Widget? icon;
  final bool checkLogin;
  final double? iconSpace;
  final bool isMinWidth;
  final Color? borderColor;
  final Duration cooldownDuration;
  final bool keyboardCheckingEnabled;
  final bool? safeAreaEnabled;

  const AppButtonWidget({
    this.onTap,
    this.buttonColor,
    this.begin,
    this.end,
    this.stops,
    this.borderStroke,
    this.text,
    this.builder,
    this.padding,
    this.textColor,
    this.radius,
    this.textSize,
    this.fontWeight,
    this.textIgnoreLine = false,
    this.icon,
    this.checkLogin = false,
    this.iconSpace,
    this.isMinWidth = false,
    this.borderColor,
    this.cooldownDuration = const Duration(milliseconds: 0),
    this.keyboardCheckingEnabled = false,
    this.safeAreaEnabled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = InkWellWrapper(
      cooldownDuration: cooldownDuration,
      keyboardCheckingEnabled: keyboardCheckingEnabled,
      onTap: onTap != null
          ? () {
              onTap!();
            }
          : null,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 7).r,
        margin: EdgeInsets.all(borderStroke ?? 1.0).r,
        decoration: onTap != null
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(radius ?? 6).r,
                color: buttonColor,
                gradient: buttonColor == null
                    ? AppColors.buttonGradientColor
                    : null,
                border: Border.all(
                  color: borderColor ?? AppColors.transparentColor,
                  width: borderStroke ?? 1.0,
                ),
              )
            : BoxDecoration(
                borderRadius: BorderRadius.circular(radius ?? 6).r,
                color: AppColors.disableColor,
                border: Border.all(
                  color: borderColor ?? AppColors.transparentColor,
                  width: borderStroke ?? 1.0,
                ),
              ),
        child:
            builder ??
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: isMinWidth ? MainAxisSize.min : MainAxisSize.max,
              children: [
                if (icon != null)
                  Padding(
                    padding: EdgeInsets.only(right: iconSpace ?? 5).r,
                    child: icon!,
                  ),
                AppText(
                  text ?? "",
                  fontSize: textSize ?? kFont13,
                  fontWeight: fontWeight ?? FontWeight.w600,
                  color: onTap != null
                      ? textColor ?? AppColors.buttonTextColor
                      : AppColors.whiteColor,
                  isOverflow: textIgnoreLine,
                ),
              ],
            ),
      ),
    );

    return safeAreaEnabled == true
        ? SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kHorizontalPadding,
                vertical: 12,
              ).r,
              child: button,
            ),
          )
        : button;
  }
}
