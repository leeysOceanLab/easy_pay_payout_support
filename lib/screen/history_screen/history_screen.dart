import '../../controller/history_controller.dart';
import '../../imports.dart';
import 'widgets/histroy_tab_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<String> tabLabels = [
      context.tr(AppStrings.currentHistory),
      context.tr(AppStrings.historyRecord),
    ];

    return ChangeNotifierProvider(
      create: (_) => HistoryController()..setInit(this),
      child: Consumer<HistoryController>(
        builder: (BuildContext context, controller, _) {
          return Scaffold(
            backgroundColor: AppColors.pageBgColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppColors.pageBgColor,
              surfaceTintColor: AppColors.pageBgColor,
              titleSpacing: 16.w,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryTextColor,
                ),
              ),
              title: AppText(
                context.tr(AppStrings.history),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTextColor,
              ),
            ),
            body: Column(
              children: [
                TabBarWidget(
                  tabController: controller.tabController,
                  labels: tabLabels,
                  dividerColor: AppColors.greyLightColor,
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4).r,
                ),
                10.heightSpace,
                Expanded(
                  child: TabBarView(
                    physics: const TabBarViewScrollPhysics(),
                    controller: controller.tabController,
                    children: [
                      HistoryTabContent(type: HistoryTabType.current),
                      HistoryTabContent(type: HistoryTabType.history),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
