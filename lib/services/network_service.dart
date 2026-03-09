// Dart imports:
import "dart:developer";

// Package imports:

import '../imports.dart';
// Project imports:

class NetworkService {
  static final NetworkService _networkService = NetworkService._internal();

  factory NetworkService() {
    return _networkService;
  }

  NetworkService._internal();

  bool _isDialogOpen = false;
  bool _isFirstTime = true;

  static Future<dynamic> shouldListenNetwork() async {
    if (kIsWeb) return;

    await _networkService.initNetworkService();
  }

  Future<void> initNetworkService() async {
    try {
      InternetConnection().onStatusChange.listen((status) {
        if (status == InternetStatus.disconnected) {
          _showNoConnectionDialog();
        } else {
          if (_isFirstTime) {
            _isFirstTime = false;
            return;
          }

          _dismissDialog();
          _showSnackbar();
        }
      });
    } catch (e) {
      log("ERROR : $e");
    }
  }

  void _showNoConnectionDialog() {
    if (!_isDialogOpen) {
      if (_isFirstTime) {
        _isFirstTime = false;
      }

      _isDialogOpen = true;
      BottomSheetHelper.noInternetConnection();
    }
  }

  void _dismissDialog() {
    if (_isDialogOpen) {
      _isDialogOpen = false;
      AppNavigator.pop(NavigationService.context);
    }
  }

  void _showSnackbar() {
    ScaffoldMessenger.of(NavigationService.context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.greenColor,
        content: AppText(
          NavigationService.context.tr(AppStrings.backOnline),
          color: AppColors.whiteColor,
        ),
        duration: 2.seconds,
      ),
    );
  }
}
