// Project imports:
import '../../imports.dart';

class SmartRefresherWrapper extends StatelessWidget {
  final Widget? child;
  final bool enablePullUp;
  final bool enableTwoLevel;
  final bool enablePullDown;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final RefreshController controller;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool reverse;
  final bool? isLoading;
  final bool scrollShadowEnabled;
  final bool enableStartShadow;
  final bool enableEndShadow;

  const SmartRefresherWrapper({
    super.key,
    required this.controller,
    this.child,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.enableTwoLevel = false,
    this.onRefresh,
    this.onLoading,
    this.physics,
    this.scrollController,
    this.reverse = false,
    this.isLoading,
    this.scrollShadowEnabled = false,
    this.enableStartShadow = true,
    this.enableEndShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return scrollShadowEnabled
        ? ScrollShadow(
            enableStartShadow: enableStartShadow,
            enableEndShadow: enableEndShadow,
            child: mainWidget(context),
          )
        : mainWidget(context);
  }

  Widget mainWidget(BuildContext context) {
    return Stack(
      children: [
        SmartRefresher(
          physics: physics ?? const CustomBouncingScrollPhysics(),
          enablePullDown: enablePullDown,
          enablePullUp: enablePullUp,
          reverse: reverse,
          header: ClassicHeader(
            idleText: context.tr(AppStrings.refreshPullDownRefresh),
            refreshingText: context.tr(AppStrings.refreshRefreshing),
            releaseText: context.tr(AppStrings.refreshReleaseToRefresh),
            completeText: context.tr(AppStrings.refreshCompleted),
            failedText: context.tr(AppStrings.refreshFailed),
            refreshingIcon: SizedBox(
              height: 32.h,
              width: 32.h,
              child: const CircularProgressIndicatorWidget(),
            ),
            failedIcon: Icon(
              Icons.error,
              color: AppColors.primaryTextColor,
              size: 25.w,
            ),
            completeIcon: Icon(
              Icons.done,
              color: AppColors.primaryTextColor,
              size: 25.w,
            ),
            idleIcon: Icon(
              Icons.arrow_downward,
              color: AppColors.primaryTextColor,
              size: 25.w,
            ),
            releaseIcon: Icon(
              Icons.refresh,
              color: AppColors.primaryTextColor,
              size: 25.w,
            ),
            textStyle: TextStyle(color: AppColors.primaryTextColor),
          ),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus? mode) {
              Widget body;

              if (mode == LoadStatus.idle) {
                body = AppText(
                  context.tr(AppStrings.pullUpToLoad),
                  color: AppColors.primaryTextColor,
                );
              } else if (mode == LoadStatus.failed) {
                body = AppText(
                  context.tr(AppStrings.loadFailTryAgain),
                  color: AppColors.primaryTextColor,
                );
              } else if (mode == LoadStatus.canLoading) {
                body = AppText(
                  context.tr(AppStrings.releaseToLoad),
                  color: AppColors.primaryTextColor,
                );
              } else if (mode == LoadStatus.loading) {
                body = Padding(
                  padding: const EdgeInsets.only(top: 10).r,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 32.h,
                        width: 32.h,
                        child: const CircularProgressIndicatorWidget(),
                      ),
                      const SizedBox(width: 10),
                      AppText(
                        context.tr(AppStrings.refreshRefreshing),
                        color: AppColors.primaryTextColor,
                      ),
                    ],
                  ),
                );
              } else {
                body = Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 25,
                      height: 1,
                      color: AppColors.greyColor.wOpacity(0.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5).r,
                      child: AppText(
                        context.tr(AppStrings.loadNoData),
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    Container(
                      width: 25,
                      height: 1,
                      color: AppColors.greyColor.wOpacity(0.5),
                    ),
                  ],
                );
              }

              return SizedBox(
                height: 55.0,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10).r,
                    child: body,
                  ),
                ),
              );
            },
          ),
          controller: controller,
          onRefresh: onRefresh,
          onLoading: onLoading,
          scrollController: scrollController,
          child: isLoading == null
              ? child
              : (isLoading! ? const SizedBox.shrink() : child),
        ),
        if (isLoading != null)
          if (isLoading!)
            const Center(child: CircularProgressIndicatorWidget()),
      ],
    );
  }
}

class CustomBouncingScrollPhysics extends BouncingScrollPhysics {
  final double stiffness; // higher = less bounce
  const CustomBouncingScrollPhysics({this.stiffness = 4.5, super.parent});

  // Higher stiffness = less bounce
  // Lower stiffness = more bounce
  @override
  CustomBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomBouncingScrollPhysics(
      stiffness: stiffness,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Modify overscroll resistance (reduce bounce)
    final overscroll = super.applyBoundaryConditions(position, value);
    return overscroll / stiffness; // 👈 scale how much bounce occurs
  }
}
