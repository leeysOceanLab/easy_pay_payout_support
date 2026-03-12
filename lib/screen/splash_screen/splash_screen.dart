import 'package:lottie/lottie.dart';

import '../../imports.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasStarted = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasStarted) return;
      _hasStarted = true;
      initData();
    });
  }

  Future<void> initData() async {
    initScreenSize();
    await LocationHelper.getCurrentPosition(context);
    await checkLogin();
  }

  void initScreenSize() {
    final Size screenSize = MediaQuery.of(context).size;

    Globals().setScreenSize(
      screenHeight: screenSize.height,
      screenWidth: screenSize.width,
    );
  }

  Future<void> checkLogin() async {
    try {
      await SecureStorage().init();

      final String? token = await SecureStorage().readLoginToken();

      if (!mounted || _hasNavigated) return;

      if (token == null || token.isEmpty) {
        goToLoginScreen();
        return;
      }

      final bool isLoginSuccess = await loginWithToken(token);

      if (!mounted || _hasNavigated) return;

      if (isLoginSuccess) {
        goToHomeScreen();
      } else {
        await SecureStorage().writeLoginToken(null);
        goToLoginScreen();
      }
    } catch (e) {
      if (!mounted || _hasNavigated) return;
      goToLoginScreen();
    }
  }

  Future<bool> loginWithToken(String token) async {
    try {
      await ApiService.api.myLockedWithdrawal(
        onSuccess: (response) {
          if (response.status == kSuccess) {
            return true;
          } else {
            return false;
          }
        },
        onError: (error) {
          return false;
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  void goToLoginScreen() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    AppNavigator.pushReplacementNamed(context, RouteName.loginPage);
  }

  void goToHomeScreen() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    AppNavigator.pushReplacementNamed(context, RouteName.mainPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.pink,
      body: Center(
        child: SizedBox(
          height: 50.w,
          width: 50.w,
          child: Lottie.asset('assets/lotties/loading.json'),
        ),
      ),
    );
  }
}
