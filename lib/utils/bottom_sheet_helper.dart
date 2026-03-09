// Package imports:

// Project imports:

import '../imports.dart';

class BottomSheetHelper {
  static BuildContext context = NavigationService.context;
  static ShapeBorder roundShapeBorder = const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(20.0),
      topLeft: Radius.circular(20.0),
    ),
  );

  static void logout() {
    showBarModalBottomSheet(
      context: context,
      barrierColor: Colors.black54,
      shape: roundShapeBorder,
      builder: (context) => const BottomSheetLogout(),
      topControl: const SizedBox.shrink(),
    );
  }

  static Future<dynamic> noInternetConnection() async {
    return await showBarModalBottomSheet(
      context: context,
      barrierColor: Colors.black54,
      shape: roundShapeBorder,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const BottomSheetNoInternetConnection(),
      topControl: const SizedBox.shrink(),
    );
  }
}
