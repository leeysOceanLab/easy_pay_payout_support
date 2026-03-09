// Package imports:
import '../imports.dart';

// import "package:firebase_messaging/firebase_messaging.dart";

/// Copy
void copyToClipboard({String? message, required String contentToCopy}) {
  HapticFeedback.lightImpact();
  ToastHelper.showToast(
    message ?? NavigationService.context.tr(AppStrings.copied),
    icon: Icons.check_circle,
    align: const Alignment(0, 0.85),
  );
  Clipboard.setData(ClipboardData(text: contentToCopy));
}

Future<String?> getDeviceInfoId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (kIsWeb) {
    WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
    return "${webInfo.vendor ?? '-'}|${webInfo.userAgent ?? '-'}|${webInfo.hardwareConcurrency}";
  } else if (Platform.isAndroid) {
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  } else if (Platform.isIOS) {
    final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor!;
  }

  return null;
}

Future<bool> requestPermission(Permission permission) async {
  if (await permission.isGranted) {
    return true;
  } else {
    var result = await permission.request();
    if (result == PermissionStatus.granted) {
      return true;
    }
  }
  return false;
}

String getResponseMessage(String message) {
  if (message.contains("_")) return NavigationService.context.tr(message);
  return message;
}

String formatNotificationTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hour ago';
  } else if (now.difference(dateTime).inDays == 1) {
    return 'Yesterday, ${DateFormat('h:mm a').format(dateTime)}';
  } else {
    return DateFormat('MMM d, y').format(dateTime);
  }
}

bool isVideo(String filePath) {
  final mimeType = lookupMimeType(filePath);
  return mimeType != null && mimeType.startsWith("video/");
}

bool isNetworkUrl(String url) {
  return url.startsWith("http://") || url.startsWith("https://");
}

String getMonthAbbreviation(int month) {
  const monthMap = {
    1: "JAN",
    2: "FEB",
    3: "MAR",
    4: "APR",
    5: "MAY",
    6: "JUN",
    7: "JUL",
    8: "AUG",
    9: "SEP",
    10: "OCT",
    11: "NOV",
    12: "DEC",
  };

  return monthMap[month] ?? "-";
}

Future<String> getAppVersionAndBuild() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String version = packageInfo.version; // e.g. "1.0.0"
  String buildNumber = packageInfo.buildNumber; // e.g. "1"

  return "$version ($buildNumber)";
}

void unfocusKeyboard() {
  if (FocusManager.instance.primaryFocus != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
