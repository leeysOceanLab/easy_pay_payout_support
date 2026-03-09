// Project imports:
import '../../imports.dart';

class NormalDialog extends StatelessWidget {
  final String title;
  final String? description;

  // left
  final String? leftButtonText;
  final Function()? leftFunction;
  final Color? leftTextColor;
  final Color? leftButtonColor;

  // right
  final String? rightButtonText;
  final Function()? rightFunction;
  final Color? rightTextColor;
  final Color? rightButtonColor;

  // builder content
  final Widget? builder;

  const NormalDialog({
    super.key,
    required this.title,
    this.description,
    this.leftButtonText,
    this.leftFunction,
    this.leftTextColor,
    this.leftButtonColor,
    this.rightButtonText,
    this.rightFunction,
    this.rightTextColor,
    this.rightButtonColor,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.all(kDialogPadding).r,
          decoration: BoxDecoration(
            color: AppColors.containerBgColor,
            borderRadius: BorderRadius.circular(10.w),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // upper part
              upperPart(),

              // divider
              Container(height: 1, color: AppColors.greyLightColor),

              // bottomPart
              bottomPart(),
            ],
          ),
        ),
      ],
    );
  }

  Widget upperPart() {
    return Padding(
      // padding: EdgeInsets.symmetric(
      //   horizontal: kDialogPadding.fw / 2,
      //   vertical: kDialogPadding.fw / 3,
      // ),
      padding: EdgeInsets.fromLTRB(
        kDialogPadding / 2,
        kDialogPadding / 3,
        kDialogPadding / 2,
        builder == null ? kDialogPadding / 3 : 0,
      ).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            title,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
            fontSize: kFont15,
          ),
          if (builder != null || description != null) ...[
            10.heightSpace,
            builder ??
                AppText(
                  description ?? "",
                  textAlign: TextAlign.center,
                  isOverflow: false,
                ),
          ],
        ],
      ),
    );
  }

  Widget bottomPart() {
    return IntrinsicHeight(
      child: Row(
        children: [
          // left
          if (leftButtonText != null)
            Expanded(
              child: InkWellWrapper(
                onTap: leftFunction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ).r,
                  decoration: leftButtonColor == null
                      ? null
                      : BoxDecoration(color: leftButtonColor),
                  child: Center(
                    child: AppText(
                      leftButtonText!,
                      fontWeight: FontWeight.normal,
                      color: leftTextColor,
                    ),
                  ),
                ),
              ),
            ),

          // divider
          if (leftButtonText != null)
            Container(width: 1, color: AppColors.greyLightColor),

          // right
          if (rightButtonText != null)
            Expanded(
              child: InkWellWrapper(
                onTap: rightFunction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ).r,
                  decoration: rightButtonColor == null
                      ? null
                      : BoxDecoration(color: rightButtonColor),
                  child: Center(
                    child: AppText(
                      rightButtonText!,
                      fontWeight: FontWeight.normal,
                      color: rightTextColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
