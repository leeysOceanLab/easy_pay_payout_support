import '../imports.dart';

class LoginController extends ChangeNotifier {
  bool _isDisposed = false;
  BuildContext context = NavigationService.context;

  final formKey = GlobalKey<FormState>();

  final TextEditingController usernameTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController twoFaTextController = TextEditingController();

  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode twoFaFocusNode = FocusNode();

  bool isRememberMe = false;
  bool isSubmit = false;
  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    _isDisposed = true;

    usernameTextController.dispose();
    passwordTextController.dispose();
    twoFaTextController.dispose();

    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    twoFaFocusNode.dispose();

    super.dispose();
  }

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void setInit() {}

  void unfocusAll() {
    usernameFocusNode.unfocus();
    passwordFocusNode.unfocus();
    twoFaFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void onTapPasswordVisibility() {
    obscurePassword = !obscurePassword;
    update();
  }

  void onTapRememberMe(bool val) {
    isRememberMe = val;
    update();
  }

  void onUsernameEditingComplete(BuildContext context) {
    FocusScope.of(context).requestFocus(passwordFocusNode);
  }

  void onPasswordEditingComplete() {
    unfocusAll();
  }

  void onTwoFaEditingComplete() {
    unfocusAll();
  }

  String? validateUsername(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter username';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final text = value ?? '';

    if (text.isEmpty) {
      return 'Please enter password';
    }

    return null;
  }

  String? validateTwoFa(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter 2FA code';
    }

    if (text.length != 6) {
      return '2FA code must be 6 digits';
    }

    return null;
  }

  Future<void> onTapLogIn({VoidCallback? onSuccess}) async {
    unfocusKeyboard();
    isSubmit = true;
    update();

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    formKey.currentState?.save();

    if ((twoFaTextController.text.trim()).length != 6) {
      throw Exception("Invalid 2FA code");
    }

    Loader.show();

    try {
      printLog(
        "Calling login API with username: ${usernameTextController.text.trim()}",
      );

      await ApiService.api.login(
        password: passwordTextController.text,
        g2faToken: twoFaTextController.text.trim(),
        username: usernameTextController.text.trim(),
        deviceInfo: "",
        onSuccess: (response) async {
          await ApiService.updateApiToken(response.data["token"]);

          Loader.hide();

          if (onSuccess != null) {
            onSuccess();
          }

          await Future.delayed(const Duration(milliseconds: 100));

          AppNavigator.pushNamedAndRemoveUntil(context, RouteName.mainPage);
        },
        onError: (error) {
          print("Login response Login error: $error");
          ToastHelper.showToast(error);
          Loader.hide();
        },
      );
    } catch (e) {
      Loader.hide();
      rethrow;
    }
  }
}
