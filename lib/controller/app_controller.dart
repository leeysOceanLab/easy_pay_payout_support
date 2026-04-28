// Project imports:

import 'package:easy_pay_bank_infomrm/controller/session_controller.dart';

import '../imports.dart';
import '../services/notification/bubble_service.dart';

class AppController with ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  UserModel? user;

  bool isLoading = true;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // update user
  set setUser(UserModel value) {}

  Future<void> logout() async {
    final BuildContext? currentContext =
        NavigationService.navigatorKey.currentContext;

    Loader.show(status: currentContext?.tr(AppStrings.loggingOut) ?? "登出中...");

    try {
      await BubbleService.notifyLogout();
      await ApiService.deleteApiToken();

      final navigatorState = NavigationService.navigatorKey.currentState;
      if (navigatorState == null) {
        Loader.hide();
        return;
      }

      navigatorState.pushNamedAndRemoveUntil(
        RouteName.loginPage,
        (route) => false,
      );
    } finally {
      Loader.hide();
    }
  }
}
