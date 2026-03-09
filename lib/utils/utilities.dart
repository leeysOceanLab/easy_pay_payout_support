// Dart imports:
import "dart:developer";

import "dart:math" as math;

import '../imports.dart';

// Package imports:

// Project imports:

void printLog(dynamic message, {String name = ""}) {
  if (Globals().get("environment") == Environment.staging.name) {
    log("$message", name: name);
  }
}

Color colorAuto(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.light
      ? Colors.black
      : Colors.white;
}

Brightness colorBrightnessAuto(Color background, {bool isIos = false}) {
  if (isIos) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.light
        ? Brightness.light
        : Brightness.dark;
  }

  return ThemeData.estimateBrightnessForColor(background) == Brightness.light
      ? Brightness.dark
      : Brightness.light;
}

bool isDataEmpty(dynamic data) {
  if (data == null || data == "null" || data == "") return true;
  return false;
}

String getPrice(
  String? price, {
  bool isDecimal = true,
  bool isCurrency = true,
  bool is4Decimal = false,
  String defaultPrice = "0.00",
  String? symbol,
  bool symbolLeft = true,
  bool removeComma = false,
  bool isSpacing = true,
  bool showFree = false,
}) {
  if (isDataEmpty(price)) {
    return isCurrency
        ? '${Globals().get('currency')} $defaultPrice'
        : defaultPrice;
  }

  final priceFormatter = NumberFormat(
    is4Decimal ? "#,##0.0000" : "#,##0.00",
    "en_US",
  );

  price = priceFormatter.format(double.tryParse(price!.replaceAll(",", "")));

  if (!isDecimal) {
    final priceFormatter2 = NumberFormat("#,##0", "en_US");
    price = priceFormatter2.format(
      double.parse(price.replaceAll(",", "")).toInt(),
    );
  }

  if (removeComma) {
    price = price.replaceAll(",", "");
  }

  if (showFree) {
    if (double.parse(price.replaceAll(",", "")) == 0) {
      return price = "FREE";
    }
  }

  return isCurrency
      ? (symbolLeft
            ? '${symbol ?? Globals().get('currency')}${isSpacing ? " " : ""}$price'
            : '$price${isSpacing ? " " : ""}${symbol ?? Globals().get('currency')}')
      : price;
}

Color colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll("#", "");
  return Color(int.parse("FF$hexCode", radix: 16));
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

double roundFloorNumber(double value, int places) {
  num val = math.pow(10.0, places);
  return ((value * val).floor().toDouble() / val);
}

String calculateDistance(
  dynamic lat1,
  lon1,
  lat2,
  lon2, {
  String suffix = "km",
}) {
  var p = 0.017453292519943295;
  var c = math.cos;
  var a =
      0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return "${(12742 * math.asin(math.sqrt(a))).toStringAsFixed(2)}$suffix";
}

Size textSize({
  required BuildContext context,
  required String text,
  required TextStyle textStyle,
  int maxLines = 1,
}) {
  assert(textStyle.fontSize != null);
  return (TextPainter(
    text: TextSpan(
      text: text,
      style: textStyle.copyWith(
        fontSize: MediaQuery.textScalerOf(context).scale(textStyle.fontSize!),
      ),
    ),
    maxLines: maxLines,
    textDirection: Directionality.of(context),
  )..layout()).size;
}

String getRandomString(int length) {
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  math.Random rnd = math.Random();

  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ),
  );
}

Future<void> launchLink({required String url}) async {
  try {
    await launchUrl(Uri.parse(url));
  } catch (e) {
    ToastHelper.showToast("Could not launch $url");
  }
}

Color getRandomColor() {
  return Color.fromRGBO(
    math.Random().nextInt(255),
    math.Random().nextInt(255),
    math.Random().nextInt(255),
    1,
  );
}

String getTimeAmPm({required String? time}) {
  DateTime dateTime = DateFormat('HH:mm:ss').parse(time!).toLocal();
  return DateFormat('hh:mm a').format(dateTime);
}

String ordinal(int number) {
  if (!(number >= 1 && number <= 100)) {
    //here you change the range
    throw Exception('Invalid number');
  }

  if (number >= 11 && number <= 13) {
    return 'th';
  }

  switch (number % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }

  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String dateFormat({String? pattern = "dd MMM yyyy", String? date}) {
  if (date == null) {
    return "-";
  }

  try {
    DateTime dateTime = DateTime.parse(date).toLocal();
    return DateFormat(pattern, 'en_US').format(dateTime);
  } catch (e) {
    return "-";
  }
}

String ensureHttps(String url) {
  if (!url.startsWith("http://") && !url.startsWith("https://")) {
    return "https://$url";
  }
  return url;
}

Future<void> launchGoogleMaps({
  required double latitude,
  required double longitude,
}) async {
  final Uri url = Uri.parse(
    'https://www.google.com/maps?q=$latitude,$longitude',
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

/// **1. Take a photo from the camera**
Future<File?> takePhoto() async {
  final ImagePicker picker = ImagePicker();
  try {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      // ToastHelper.showToast("Photo taken successfully!");
      return File(photo.path);
    }
  } catch (e) {
    ToastHelper.showToast("Error taking photo: $e");
  }
  return null;
}

/// **2. Record a video using the camera**
Future<File?> takeVideo() async {
  final ImagePicker picker = ImagePicker();
  try {
    final XFile? video = await picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      // ToastHelper.showToast("Video recorded successfully!");
      return File(video.path);
    }
  } catch (e) {
    ToastHelper.showToast("Error recording video: $e");
  }
  return null;
}

/// **3. Pick a photo from the gallery**
Future<File?> uploadPhoto() async {
  final ImagePicker picker = ImagePicker();
  try {
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      // ToastHelper.showToast("Photo selected successfully!");
      return File(photo.path);
    }
  } catch (e) {
    ToastHelper.showToast("Error picking photo: $e");
  }
  return null;
}

// /// **4. Upload any file from storage**
// Future<File?> uploadFromFiles() async {
//   try {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi'],
//     );

//     if (result != null && result.files.single.path != null) {
//       // ToastHelper.showToast("File selected successfully!");
//       return File(result.files.single.path!);
//     }
//   } catch (e) {
//     ToastHelper.showToast("Error selecting file: $e");
//   }
//   return null;
// }

String formatNumToCurrency(double price, {bool hasCurrency = true}) {
  String value = NumberFormat("#,##0.00", "en_US").format(price);

  String currency = "RM";

  if (hasCurrency) {
    value = '$currency $value';
  }

  return value;
}

Future<File> uint8ListToFile(Uint8List uint8List, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(uint8List);
  return file;
}

Future<Uint8List> fileToUint8List(File file) async {
  return await file.readAsBytes();
}

int getTextMaxLinesCount(String text, TextStyle style, double maxWidth) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: null,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);

  final lineHeight = textPainter.preferredLineHeight;
  final lines = (textPainter.height / lineHeight).ceil();
  return lines;
}

double getTextLineHeight(TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: 'A', style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();

  return textPainter.height;
}
