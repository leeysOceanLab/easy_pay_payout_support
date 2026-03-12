// Project imports:

// Project imports:
import '../../imports.dart';

class TabBarWidget extends StatelessWidget {
  final TabController? tabController;
  final List<String> labels;
  final bool showIndicator;
  final EdgeInsetsGeometry? labelPadding;
  final TabBarIndicatorSize? indicatorSize;
  final TabAlignment? tabAlignment;
  final bool isScrollable;
  final TextStyle? activeStyle;
  final TextStyle? inactiveStyle;
  final double? tabHeight;
  final Color? indicatorColor;
  final Color? dividerColor;
  final TextAlign? textAlign;

  const TabBarWidget({
    required this.tabController,
    required this.labels,
    this.showIndicator = true,
    this.labelPadding,
    this.indicatorSize,
    this.tabAlignment,
    this.isScrollable = true,
    this.activeStyle,
    this.inactiveStyle,
    this.tabHeight,
    this.indicatorColor,
    this.dividerColor,
    this.textAlign,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle activeTextStyle =
        activeStyle ??
        TextStyle(
          color: AppColors.secondaryTextColor,
          fontSize: kFont13.sp,
          fontWeight: FontWeight.w600,
        );
    TextStyle inactiveTextStyle =
        inactiveStyle ??
        TextStyle(
          color: AppColors.primaryTextColor.wOpacity(0.4),
          fontSize: kFont13.sp,
          fontWeight: FontWeight.normal,
        );

    return TabBar(
      indicatorAnimation: TabIndicatorAnimation.elastic,
      onTap: (value) => unfocusKeyboard(),
      dividerColor: dividerColor ?? Colors.transparent,
      tabAlignment: tabAlignment,
      padding: const EdgeInsets.all(0).r,
      labelPadding:
          labelPadding ??
          const EdgeInsets.symmetric(horizontal: kHorizontalPadding).r,
      isScrollable: isScrollable,
      labelStyle: activeTextStyle,
      labelColor: AppColors.blackColor,
      unselectedLabelColor: AppColors.blackColor.wOpacity(0.6),
      unselectedLabelStyle: inactiveTextStyle,
      controller: tabController,
      indicatorColor: Colors.transparent,
      indicatorPadding: const EdgeInsets.all(0).r,
      indicator: UnderlineTabIndicator(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(0).r,
          topRight: const Radius.circular(0).r,
        ),
        borderSide: BorderSide(
          width: 3.w,
          color: indicatorColor ?? AppColors.secondaryTextColor,
        ),
        insets: const EdgeInsets.only(left: 0, top: 0, right: 0),
      ),
      indicatorWeight: 2,
      indicatorSize: indicatorSize ?? TabBarIndicatorSize.label,
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      tabs: [
        for (int i = 0; i < labels.length; i++)
          SizedBox(
            height: tabHeight != null ? tabHeight!.h : 35.h,
            child: Tab(
              iconMargin: EdgeInsets.zero,
              child: AppText(
                labels[i],
                textAlign: textAlign ?? TextAlign.center,
                textStyle: tabController?.index == i
                    ? activeTextStyle
                    : inactiveTextStyle,
              ),
            ),
          ),
      ],
    );
  }
}
