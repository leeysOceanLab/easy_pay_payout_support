// Project imports:
import '../controller/app_controller.dart';
import '../imports.dart';

class BottomSheetLogout extends StatelessWidget {
  const BottomSheetLogout({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: const EdgeInsets.all(kHorizontalPadding).r,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(
                context.tr(AppStrings.logout),
                fontSize: kFont15,
                fontWeight: FontWeight.w600,
              ),
              10.heightSpace,
              AppText(
                context.tr(AppStrings.logoutDescription),
                isOverflow: false,
                textAlign: TextAlign.center,
              ),
              20.heightSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: AppButtonWidget(
                      onTap: () async {},
                      text: context.tr(AppStrings.cancel),
                      radius: 100,
                      textColor: AppColors.blackColor,
                      borderColor: AppColors.blackColor,
                      buttonColor: AppColors.whiteColor,
                    ),

                    // InkWellWrapper(
                    //   onTap: () {
                    //     AppNavigator.pop(context);
                    //   },
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(vertical: 8).r,
                    //     decoration: BoxDecoration(
                    //       color: AppColors.whiteColor,
                    //       borderRadius: BorderRadius.circular(100),
                    //       border: Border.all(
                    //         color: AppColors.greyLightColor,
                    //       ),
                    //     ),
                    //     child: Center(
                    //       child: AppText(
                    //         context.tr(AppStrings.cancel),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ),
                  10.widthSpace,
                  Expanded(
                    child: AppButtonWidget(
                      onTap: () async {
                        AppNavigator.pop(context);
                        await context.read<AppController>().logout(context);
                      },
                      text: context.tr(AppStrings.yes),
                      radius: 100,
                    ),

                    // InkWellWrapper(
                    //   onTap: () async {
                    //     AppNavigator.pop(context);
                    //     await context.read<AppController>().logout();
                    //   },
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(vertical: 8).r,
                    //     decoration: BoxDecoration(
                    //       color: AppColors.of(context).buttonColor(),
                    //       borderRadius: BorderRadius.circular(100),
                    //       border: Border.all(
                    //         color: AppColors.of(context).buttonColor(),
                    //       ),
                    //     ),
                    //     child: Center(
                    //       child: AppText(
                    //         context.tr(AppStrings.yes),
                    //         color: AppColors.of(context).buttonTextColor(),
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
