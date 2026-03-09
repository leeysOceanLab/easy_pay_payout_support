import '../imports.dart';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position?> getCurrentPosition(BuildContext context) async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ToastHelper.showToast(context.tr(AppStrings.locationServiceDisabled));
        return null;
      }

      PermissionStatus permission = await Permission.location.status;

      if (permission.isDenied) {
        permission = await Permission.location.request();
      }

      if (permission.isPermanentlyDenied) {
        ToastHelper.showToast(
          context.tr(AppStrings.permissionPermanentlyDenied),
        );
        // openAppSettings();
        return null;
      }

      if (!permission.isGranted) {
        ToastHelper.showToast(context.tr(AppStrings.permissionDenied));
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      printLog("Location error: $e");
      ToastHelper.showToast(context.tr(AppStrings.somethingWentWrong));
      return null;
    }
  }
}
