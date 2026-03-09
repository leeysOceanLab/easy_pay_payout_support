// Project imports:

import '../../imports.dart';

class BottomSheetNoInternetConnection extends StatelessWidget {
  const BottomSheetNoInternetConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            15.heightSpace,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20).r,
              child: AppText(
                context.tr(AppStrings.noInternetConnection),
                fontSize: kFont15,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
            ),
            15.heightSpace,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20).r,
              child: AppText(
                context.tr(AppStrings.noInternetConnectionDesc),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ).r,
              child: InkWellWrapper(
                onTap: () async {
                  if (Platform.isAndroid) {
                    const OpenSettingsPlusAndroid().wifi();
                  } else if (Platform.isIOS) {
                    const OpenSettingsPlusIOS().wifi();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      context.tr(AppStrings.goToSettings),
                      color: AppColors.primaryNoContextColor,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            0.heightSpace,
          ],
        ),
      ),
    );
  }
}
