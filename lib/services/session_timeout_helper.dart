import "../imports.dart";

class SessionTimeoutHelper {
  static bool _isDialogShowing = false;
  static bool _isNavigatingToLogin = false;

  static Future<void> handleTimeout() async {
    if (_isDialogShowing || _isNavigatingToLogin) return;

    _isDialogShowing = true;

    try {
      await ApiService.deleteApiToken();

      final BuildContext? dialogContext =
          NavigationService.navigatorKey.currentContext;
      if (dialogContext == null) return;

      await showDialog<void>(
        context: dialogContext,
        barrierDismissible: false,
        builder: (popupContext) {
          return AlertDialog(
            title: AppText(
              dialogContext.tr(AppStrings.sessionExpired),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryTextColor,
            ),
            content: AppText(
              dialogContext.tr(AppStrings.inactiveLogoutMessage),
              fontSize: 14,
              color: AppColors.primaryTextColor,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(popupContext).pop();
                },
                child: AppText(
                  dialogContext.tr(AppStrings.confirm),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          );
        },
      );
    } finally {
      _isDialogShowing = false;
    }

    if (_isNavigatingToLogin) return;

    _isNavigatingToLogin = true;

    try {
      final navigatorState = NavigationService.navigatorKey.currentState;
      if (navigatorState == null) return;

      navigatorState.pushNamedAndRemoveUntil(
        RouteName.loginPage,
        (route) => false,
      );
    } finally {
      _isNavigatingToLogin = false;
    }
  }
}
