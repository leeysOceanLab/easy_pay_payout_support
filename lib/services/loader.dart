// Project imports:
import '../imports.dart';

const defaultValue = 56.0;

class Loader extends StatefulWidget {
  const Loader(this._status, this._cancelEnabled, {super.key});

  static OverlayEntry? _overlayEntry;
  static OverlayState? _overlayState;
  static final ValueNotifier<String?> _statusNotifier = ValueNotifier<String?>(
    null,
  );

  final String? _status;
  final bool _cancelEnabled;

  /// 🟢 Show overlay loader
  static Future<void> show({
    String? status,
    bool cancelEnabled = false,
    Color? overlayColor,
    BuildContext? context,
  }) async {
    await 0.01.delay();

    _statusNotifier.value = status;

    if (_overlayEntry != null) {
      return;
    }

    OverlayState? overlayState;

    if (context != null) {
      try {
        overlayState = Overlay.maybeOf(context, rootOverlay: true);
      } catch (e) {
        overlayState = null;
      }
    }

    overlayState ??= NavigationService.navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      printLog("Loader.show error: overlayState is null");
      return;
    }

    _overlayState = overlayState;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: <Widget>[
          Container(color: overlayColor ?? Colors.black45),
          Center(child: Loader(status, cancelEnabled)),
        ],
      ),
    );

    try {
      _overlayState?.insert(_overlayEntry!);
    } catch (e) {
      printLog("Loader.show insert error: $e");
      _overlayEntry = null;
    }
  }

  /// 🟠 Update loader text dynamically
  static void updateStatus(String? newStatus) {
    if (_overlayEntry != null) {
      _statusNotifier.value = newStatus;
    }
  }

  /// 🔴 Hide overlay loader
  static Future<void> hide() async {
    await 0.01.delay();

    if (_overlayEntry != null) {
      try {
        _overlayEntry?.remove();
      } catch (e) {
        printLog("Loader.hide remove error: $e");
      } finally {
        _overlayEntry = null;
        _overlayState = null;
        _statusNotifier.value = null;
      }
    }
  }

  /// 🧩 Inline version (used directly inside a widget tree)
  static Widget loaderWidget({String? status, bool cancelEnabled = false}) {
    _statusNotifier.value = status;
    return Stack(
      children: <Widget>[
        Container(color: Colors.black45),
        Center(child: Loader(status, cancelEnabled)),
      ],
    );
  }

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  late AssetImage image;
  final loaderKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    image = const AssetImage("assets/images/splash.gif");
  }

  @override
  void dispose() {
    image.evict();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      key: loaderKey,
      child: Container(
        margin: const EdgeInsets.all(15).r,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20).r,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(10).r,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicatorWidget(),

            ValueListenableBuilder<String?>(
              valueListenable: Loader._statusNotifier,
              builder: (_, status, _) {
                if (status == null || status.isEmpty) {
                  return const SizedBox();
                }

                return Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: AppText(status, textAlign: TextAlign.center),
                );
              },
            ),

            if (widget._cancelEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 20).r,
                child: AppButtonWidget(
                  onTap: Loader.hide,
                  text: context.tr(AppStrings.cancel),
                  padding: const EdgeInsets.symmetric(
                    horizontal: kHorizontalPadding,
                    vertical: 10,
                  ).r,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
