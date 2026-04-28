import 'package:awesome_notifications/awesome_notifications.dart';
import '../../imports.dart';

@pragma('vm:entry-point')
class NotificationService {
  static const String channelKey = 'payout_tools';
  static const int orderNotificationId = 888;
  static const int openAppGuideNotificationId = 999;


  static Future<void> init() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: channelKey,
        channelName: '拨付助手',
        channelDescription: '助手',
        importance: NotificationImportance.Max,
        playSound: false,
        onlyAlertOnce: true,
        locked: true,
        defaultPrivacy: NotificationPrivacy.Public,
      ),
    ], debug: true);

    final bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    try {
      final String? buttonKey = receivedAction.buttonKeyPressed;
      final Map<String, String?>? payload = receivedAction.payload;
      final String? txId = payload?['tx_id'];
      final String? textToCopy = buttonKey == null ? null : payload?[buttonKey];

      debugPrint(
        '【NotificationService】onActionReceivedMethod => '
        'buttonKey=$buttonKey, txId=$txId, '
        'lifeCycle=${receivedAction.actionLifeCycle}',
      );

      // 点通知本体（没按按钮）→ 打开对应订单详情
      if (buttonKey == null || buttonKey.isEmpty) {
        final int withdrawalId =
            int.tryParse(payload?['withdrawal_id'] ?? '') ?? 0;
        if (withdrawalId > 0) {
          final context = NavigationService.navigatorKey.currentContext;
          if (context != null) {
            AppNavigator.pushNamed(
              context,
              RouteName.withdrawalDetails,
              arguments: {'id': withdrawalId},
            );
          }
        }
        return;
      }

      if (textToCopy == null || textToCopy.isEmpty || textToCopy == '-') {
        debugPrint('【NotificationService】没有可复制内容');
        return;
      }

      // 如果 app 已经被系统杀掉
      if (receivedAction.actionLifeCycle == NotificationLifeCycle.Terminated) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: openAppGuideNotificationId,
            channelKey: channelKey,
            title: '⚠️ 复制受限（App 已关闭）',
            body: '请点击此通知打开 App，以恢复快捷复制功能',
            actionType: ActionType.Default,
            autoDismissible: true,
          ),
        );
        return;
      }

      // App 还活着：前台 / 后台，都可以继续做逻辑
      await Clipboard.setData(ClipboardData(text: textToCopy));
      await HapticFeedback.mediumImpact();

      debugPrint("【NotificationService】成功复制: $textToCopy");

      // 只处理 copy_amount / copy_main
      if (buttonKey == 'copy_amount' || buttonKey == 'copy_main') {
        await _notifyCopyAction(
          payload: payload,
          actionKey: buttonKey,
          copiedValue: textToCopy,
        );
      }
    } catch (e, s) {
      debugPrint("【NotificationService】onActionReceivedMethod error: $e");
      debugPrint("$s");
    }
  }

  static double _parseLocationValue(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  static Future<void> _notifyCopyAction({
    required Map<String, String?>? payload,
    required String actionKey,
    required String copiedValue,
  }) async {
    try {
      final int id = int.tryParse(payload?['withdrawal_id'] ?? '') ?? 0;

      if (id <= 0) {
        debugPrint(
          '【NotificationService】updateCopyLog skipped: invalid withdrawal_id',
        );
        return;
      }

      final bool isKuaizhuan = (payload?['is_kuaizhuan'] ?? 'false') == 'true';

      String fieldCopied = actionKey;
      if (actionKey == 'copy_main') {
        fieldCopied = isKuaizhuan ? 'copy_phone' : 'copy_account_number';
      }

      final double latitude = _parseLocationValue(Globals().get("latitude"));
      final double longitude = _parseLocationValue(Globals().get("longitude"));

      debugPrint(
        '【NotificationService】准备 call API => '
        'id=$id, fieldCopied=$fieldCopied, copiedValue=$copiedValue, '
        'lat=$latitude, lon=$longitude',
      );

      await ApiService.api.updateCopyLog(
        id: id,
        fieldCopied: fieldCopied,
        valueCopied: copiedValue,
        latitude: latitude,
        longitude: longitude,
        onSuccess: (response) {
          debugPrint(
            "【NotificationService】updateCopyLog success: ${response.data}",
          );
        },
        onError: (error) {
          debugPrint("【NotificationService】updateCopyLog error: $error");
        },
      );
    } catch (e, s) {
      debugPrint("【NotificationService】call API failed: $e");
      debugPrint("$s");
    }
  }

  // Kept for backwards compat — now just a direct passthrough.
  // Caller is responsible for throttling (see WithdrawalDetailsScreen).
  static Future<void> showOrderNotificationIfNeeded({
    required int withdrawalId,
    required bool isKuaizhuan,
    required String type,
    required String txId,
    required String amount,
    required String name,
    required String bankName,
    required String accountNumber,
    required String mobile,
  }) => showOrderNotification(
    withdrawalId: withdrawalId,
    isKuaizhuan: isKuaizhuan,
    type: type,
    txId: txId,
    amount: amount,
    name: name,
    bankName: bankName,
    accountNumber: accountNumber,
    mobile: mobile,
  );

  static Future<void> showOrderNotification({
    required int withdrawalId,
    required bool isKuaizhuan,
    required String type,
    required String txId,
    required String amount,
    required String name,
    required String bankName,
    required String accountNumber,
    required String mobile,
  }) async {
    // Always cancel first — guarantees Android re-triggers heads-up banner
    await AwesomeNotifications().cancel(orderNotificationId);

    debugPrint('【NotificationService】showOrderNotification type=$type txId=$txId');

    final String typeLabel = isKuaizhuan
        ? AppStrings.fastTransfer.tr()
        : AppStrings.bankTransfer.tr();
    final String typeIcon = isKuaizhuan ? '⚡' : '🏦';
    final String mainLabel = isKuaizhuan ? '📱' : '💳';
    final String mainValue = isKuaizhuan ? mobile : accountNumber;

    // Title: type icon + txId  (visible on heads-up peek)
    final String title = '$typeIcon  $txId';

    // Body: clean multi-line, visible when expanded
    final StringBuffer body = StringBuffer();
    body.write('💰 <b>HKD $amount</b><br>');
    body.write('👤 $name<br>');
    if (!isKuaizhuan && bankName.isNotEmpty && bankName != '-') {
      body.write('🏦 $bankName<br>');
    }
    body.write('$mainLabel $mainValue');

    // Summary line shown on collapsed (1-line) peek
    final String summary = '$typeLabel  ·  HKD $amount  ·  $name';

    final Map<String, String> payloadData = {
      'withdrawal_id': withdrawalId.toString(),
      'tx_id': txId,
      'is_kuaizhuan': isKuaizhuan.toString(),
      'copy_amount': amount,
      'copy_name': name,
      'copy_main': mainValue,
    };

    final List<NotificationActionButton> buttons = [
      NotificationActionButton(
        key: 'copy_amount',
        label: '💰 ${AppStrings.copyAmount.tr()}',
        actionType: ActionType.KeepOnTop,
        autoDismissible: false,
      ),
      NotificationActionButton(
        key: 'copy_main',
        label: isKuaizhuan
            ? '📱 ${AppStrings.copyPhone.tr()}'
            : '💳 ${AppStrings.copyAccountNumber.tr()}',
        actionType: ActionType.KeepOnTop,
        autoDismissible: false,
      ),
      NotificationActionButton(
        key: 'done',
        label: '✅ ${AppStrings.success.tr()}',
        actionType: ActionType.Default,
        autoDismissible: true,
      ),
    ];

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: orderNotificationId,
        channelKey: channelKey,
        title: title,
        body: body.toString(),
        summary: summary,
        payload: payloadData,
        notificationLayout: NotificationLayout.BigText,
        color: const Color(0xFF0066F6),
        locked: true,
        autoDismissible: false,
        category: NotificationCategory.Message,
      ),
      actionButtons: buttons,
    );

    debugPrint('【NotificationService】订单通知已生成 txId=$txId');
  }

  static Future<void> clearOrderNotification() async {
    try {
      await AwesomeNotifications().cancel(orderNotificationId);
      debugPrint('【NotificationService】订单通知已清除');
    } catch (e, s) {
      debugPrint("【NotificationService】clearOrderNotification error: $e");
      debugPrint("$s");
    }
  }
}
