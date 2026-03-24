import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import '../../imports.dart';

@pragma('vm:entry-point') // --- 必须加在这里，防止整个类被 AOT 编译器混淆或剔除 ---
class NotificationService {
  static Future<void> init() async {
    // 1. 初始化插件
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'payout_tools',
        channelName: '拨付助手',
        importance: NotificationImportance.Max,
        playSound: false,
        onlyAlertOnce: true,
        channelDescription: '助手',
      ),
    ]);

    // 2. --- 新增：检查并请求权限 ---
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // 这会弹出一个对话框，询问用户是否允许通知
      // 你也可以在这里自定义一个 Dialog 先解释为什么要权限，再调用下面这行
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // 3. 设置监听
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  // 2. 背景/后台回调逻辑 (核心：处理点击复制)
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    final String? buttonKey = receivedAction.buttonKeyPressed;
    final Map<String, String?>? payload = receivedAction.payload;
    final String? textToCopy = payload?[buttonKey];

    if (textToCopy == null || textToCopy.isEmpty || textToCopy == "-") return;

    // 检测 App 状态
    if (receivedAction.actionLifeCycle == NotificationLifeCycle.Terminated) {
      // 如果 App 已被杀掉，Android 14 严禁后台复制
      // 我们推送一个引导通知，让用户点一下打开 App
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 999,
          channelKey: 'payout_tools',
          title: "⚠️ 复制受限 (App已关闭)",
          body: "请点击此通知打开 App，以恢复快捷复制功能",
          actionType: ActionType.Default, // 点击这个通知会打开 App
        ),
      );
      return;
    }

    // 如果 App 还在后台或前台，执行复制
    try {
      await Clipboard.setData(ClipboardData(text: textToCopy));

      // 触感反馈（震动一下）
      HapticFeedback.mediumImpact();

      // 弹出一个提示
      ToastHelper.showToast("✅ 已复制: $textToCopy", textColor: Colors.white);

      print("【NotificationService】成功复制: $textToCopy");
    } catch (e) {
      print("【NotificationService】复制失败: $e");
    }
  }

  static Future<void> showOrderNotification({
    required bool isKuaizhuan,
    required String type,
    required String txId,
    required String amount,
    required String name,
    required String bankName,
    required String accountNumber,
    required String mobile,
  }) async {
    // String displayBody = "单号: $txId\n类型: $type\n金额: HKD $amount\n户名: $name\n";
    // if (isKuaizhuan) {
    //   displayBody += "电话: $mobile";
    // } else {
    //   displayBody += "银行: $bankName\n账号: $accountNumber";
    // }
    // 将 \n 替换为 <br>
    String displayBody =
        "<b>单号:</b> $txId<br><b>类型:</b> $type<br><b>金额:</b> HKD $amount<br><b>户名:</b> $name<br>";
    if (isKuaizhuan) {
      displayBody += "<b>电话:</b> $mobile";
    } else {
      displayBody += "<b>银行:</b> $bankName<br><b>账号:</b> $accountNumber";
    }

    Map<String, String> payloadData = {
      'copy_amount': amount,
      'copy_name': name,
      'copy_main': isKuaizhuan ? mobile : accountNumber,
    };

    List<NotificationActionButton> buttons = [
      NotificationActionButton(
        key: 'copy_amount',
        label: '复制金额',
        actionType: ActionType.KeepOnTop, // 保持通知栏不收起
        autoDismissible: false,
      ),
      NotificationActionButton(
        key: 'copy_name',
        label: '复制户名',
        actionType: ActionType.KeepOnTop,
        autoDismissible: false,
      ),
      NotificationActionButton(
        key: 'copy_main',
        label: isKuaizhuan ? '复制电话' : '复制账号',
        actionType: ActionType.KeepOnTop,
        autoDismissible: false,
      ),
    ];

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 888,
        channelKey: 'payout_tools',
        title: "待拨付单: $txId",
        body: displayBody,
        payload: payloadData,
        notificationLayout: NotificationLayout.BigText,
        locked: true,
        autoDismissible: false,
        category: NotificationCategory.Service,
      ),
      actionButtons: buttons,
    );
  }
}
