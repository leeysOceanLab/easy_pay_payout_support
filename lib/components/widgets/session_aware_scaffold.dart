import '../../imports.dart';

class SessionAwareScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const SessionAwareScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        SessionActivity.mark(context, source: "scaffold_scroll");
        return false;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SessionActivity.mark(context, source: "scaffold_tap");
        },
        child: Scaffold(
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
          backgroundColor: backgroundColor ?? AppColors.whiteColor,
        ),
      ),
    );
  }
}
