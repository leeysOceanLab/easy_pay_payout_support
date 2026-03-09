// Package imports:

// Project imports:

import '../components/normal_dialog.dart';
import '../imports.dart';

class DialogHelper<T> {
  static BuildContext context = NavigationService.context;

  Future<T?> showOpenAppSettingDialog({
    String? title,
    required String description,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (_) => kIsWeb
          ? NormalDialog(
              title: title ?? context.tr(AppStrings.permissionDenied),
              description: description,
              rightButtonText: context.tr(AppStrings.okay),
              rightFunction: () {
                AppNavigator.pop(context);
              },
            )
          : NormalDialog(
              title: title ?? context.tr(AppStrings.permissionDenied),
              description: description,
              leftButtonText: context.tr(AppStrings.cancel),
              rightButtonText: context.tr(AppStrings.openSettings),
              leftFunction: () {
                AppNavigator.pop(context);
              },
              rightFunction: () {
                openAppSettings();
              },
            ),
    );
  }

  Future<T?> showDefaultDialog({
    required Widget child,
    BuildContext? context2,
    bool barrierDismissible = true,
  }) async {
    return showDialog<T>(
      context: context2 ?? context,
      barrierDismissible: barrierDismissible,
      builder: (_) => child,
    );
  }

  Future<T?> showNormalDialog({
    required String title,
    String? description,

    // left
    Function()? leftFunction,
    String? leftButtonText,
    Color? leftTextColor,
    Color? leftButtonColor,

    // right
    Function()? rightFunction,
    String? rightButtonText,
    Color? rightTextColor,
    Color? rightButtonColor,
    bool barrierDismissible = true,

    // builder
    Widget? builder,
  }) async {
    return showDialog<T>(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (_) => NormalDialog(
        title: title,
        description: description,

        // left
        leftButtonText: leftButtonText,
        leftFunction: leftFunction,
        leftTextColor: leftTextColor,
        leftButtonColor: leftButtonColor,

        // right
        rightButtonText: rightButtonText ?? context.tr(AppStrings.okay),
        rightFunction: rightFunction ?? () => AppNavigator.pop(context),
        rightTextColor: rightTextColor,
        rightButtonColor: rightButtonColor,

        // builder
        builder: builder,
      ),
    );
  }

  Future<T?> showScrollableDialog({
    required Widget child,
    BuildContext? context2,
    bool barrierDismissible = true,
    heightPercent = 0.7,
  }) async {
    return showDialog<T>(
      context: context2 ?? context,
      barrierDismissible: barrierDismissible,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(kHorizontalPadding).r,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * heightPercent,
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(child: child),
              ),
            );
          },
        ),
      ),
    );
  }
}
