// Project imports:

import '../imports.dart';

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

  Future<void> logout(BuildContext context) async {
    final String loggingOutText = context.tr(AppStrings.loggingOut);

    Loader.show(status: "$loggingOutText...");

    await ApiService.deleteApiToken();

    if (!context.mounted) {
      Loader.hide();
      return;
    }

    Loader.hide();

    AppNavigator.popUntil(context, RouteName.mainPage);
    AppNavigator.pushReplacementNamed(context, RouteName.loginPage);
  }
}
