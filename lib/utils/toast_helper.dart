// Package imports:
import 'package:bot_toast/bot_toast.dart';

import '../imports.dart';

// Project imports:

class ToastHelper {
  static void showToast(
    String message, {
    ToastType type = ToastType.normal,
    double spacing = 12.0,
    double iconSize = 20,
    double? radius,
    bool isCloseButton = false,
    IconData? icon,
    Color? leadingIconColor,
    Color? suffixIconColor,
    Color? textColor,
    Alignment? align,
  }) {
    BotToast.showCustomNotification(
      onlyOne: true,
      align: align ?? const Alignment(0, 0.85),
      useSafeArea: true,
      toastBuilder: (cancelFunc) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7).r,
          margin: const EdgeInsets.symmetric(horizontal: 25).r,
          decoration: BoxDecoration(
            color: _getBgColor(type),
            borderRadius: BorderRadius.circular(radius ?? 4).r,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Padding(
                  padding: EdgeInsets.only(right: spacing).r,
                  child: Icon(
                    icon,
                    color: leadingIconColor ?? colorAuto(_getBgColor(type)),
                    size: iconSize.w,
                  ),
                ),
              Flexible(
                child: AppText(
                  message,
                  color: textColor ?? colorAuto(_getBgColor(type)),
                  maxLines: 10,
                  textAlign: TextAlign.center,
                ),
              ),
              if (isCloseButton)
                InkWellWrapper(
                  onTap: () {
                    cancelFunc();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: spacing).r,
                    child: Icon(
                      Icons.close,
                      size: iconSize.w,
                      color: suffixIconColor ?? Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static Color _getBgColor(ToastType type) {
    switch (type) {
      case ToastType.normal:
        return AppColors.toastNormalColor;

      case ToastType.success:
        return AppColors.toastSuccessColor;

      case ToastType.error:
        return AppColors.toastErrorColor;

      case ToastType.warning:
        return AppColors.toastWarningColor;
    }
  }
}
