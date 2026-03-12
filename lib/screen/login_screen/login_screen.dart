import 'package:easy_pay_bank_infomrm/constants/shared_prefs_constant.dart';
import 'package:easy_pay_bank_infomrm/controller/login_controller.dart';
import 'package:easy_pay_bank_infomrm/controller/session_controller.dart';

import '../../imports.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _loginController = LoginController()..setInit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SessionController>().stop();
    });

    _loadRememberedUsername();
  }

  void _loadRememberedUsername() {
    final String savedUsername =
        SharedPrefs.instance.readString(kREMEMBERED_USERNAME) ?? "";

    if (savedUsername.isNotEmpty) {
      _loginController.usernameTextController.text = savedUsername;
    }
  }

  Future<void> _rememberUsername() async {
    final String username = _loginController.usernameTextController.text.trim();
    await SharedPrefs.instance.writeString(kREMEMBERED_USERNAME, username);
  }

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }

  Future<void> _showTwoFADialog(LoginController loginController) async {
    loginController.twoFaTextController.clear();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TwoFADialog(
        controller: loginController.twoFaTextController,
        onVerify: (code) async {
          loginController.twoFaTextController.text = code;

          await loginController.onTapLogIn(
            onSuccess: () async {
              await _rememberUsername();

              if (!mounted) return;
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginController>.value(
      value: _loginController,
      child: Consumer<LoginController>(
        builder: (context, loginController, child) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF3F6FB),
              body: UnfocusWrapper(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Form(
                    key: loginController.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        24.heightSpace,
                        AppText(
                          AppStrings.welcomeBack.tr(),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                        8.heightSpace,
                        AppText(
                          AppStrings.login2faSubtitle.tr(),
                          fontSize: 14,
                          height: 1.5,
                          color: const Color(0xFF6B7280),
                        ),
                        28.heightSpace,
                        AppText(
                          AppStrings.emailOrUsername.tr(),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                        8.heightSpace,
                        AppTextFormField(
                          controller: loginController.usernameTextController,
                          focusNode: loginController.usernameFocusNode,
                          textInputAction: TextInputAction.next,
                          validator: loginController.validateUsername,
                          hintText: AppStrings.enterEmailOrUsername.tr(),
                        ),
                        18.heightSpace,
                        AppText(
                          AppStrings.password.tr(),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                        8.heightSpace,
                        AppTextFormField(
                          controller: loginController.passwordTextController,
                          focusNode: loginController.passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          onEditingComplete:
                              loginController.onPasswordEditingComplete,
                          validator: loginController.validatePassword,
                          obscureText: loginController.obscurePassword,
                          hintText: AppStrings.enterPassword.tr(),
                        ),
                        // 12.heightSpace,
                        // Align(
                        //   alignment: Alignment.centerRight,
                        //   child: TextButton(
                        //     onPressed: () {},
                        //     style: TextButton.styleFrom(
                        //       foregroundColor: const Color(0xFF2563EB),
                        //     ),
                        //     child: AppText(
                        //       AppStrings.forgotPassword.tr(),
                        //       fontWeight: FontWeight.w600,
                        //       color: const Color(0xFF2563EB),
                        //     ),
                        //   ),
                        // ),
                        14.heightSpace,
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AppButtonWidget(
                            onTap: () async {
                              if (!(loginController.formKey.currentState
                                      ?.validate() ??
                                  false)) {
                                return;
                              }

                              await _rememberUsername();
                              await _showTwoFADialog(loginController);
                            },
                            text: AppStrings.login.tr(),
                            textSize: kFont16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        18.heightSpace,
                        // Center(
                        //   child: AppText(
                        //     AppStrings.protectedWith2fa.tr(),
                        //     textAlign: TextAlign.center,
                        //     fontSize: 12,
                        //     color: const Color(0xFF9CA3AF),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TwoFADialog extends StatefulWidget {
  final TextEditingController controller;
  final Future<void> Function(String code) onVerify;

  const TwoFADialog({
    super.key,
    required this.controller,
    required this.onVerify,
  });

  @override
  State<TwoFADialog> createState() => _TwoFADialogState();
}

class _TwoFADialogState extends State<TwoFADialog> {
  final FocusNode _pinFocusNode = FocusNode();

  bool isVerifying = false;
  bool hasTriggered = false;

  @override
  void dispose() {
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitCode(String code) async {
    if (code.length != 6) return;
    if (isVerifying || hasTriggered) return;

    setState(() {
      isVerifying = true;
      hasTriggered = true;
    });

    try {
      await widget.onVerify(code);

      if (!mounted) return;
      setState(() {
        isVerifying = false;
        hasTriggered = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isVerifying = false;
        hasTriggered = false;
      });

      widget.controller.clear();
      _pinFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.wOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Color(0xFF2563EB),
                size: 30,
              ),
            ),
            18.heightSpace,
            AppText(
              AppStrings.twoFactorAuthentication.tr(),
              textAlign: TextAlign.center,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
            8.heightSpace,
            AppText(
              AppStrings.enter2faCode.tr(),
              textAlign: TextAlign.center,
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF6B7280),
            ),
            22.heightSpace,
            Pinput(
              controller: widget.controller,
              focusNode: _pinFocusNode,
              length: 6,
              autofocus: true,
              keyboardType: TextInputType.number,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyDecorationWith(
                border: Border.all(color: const Color(0xFF2563EB), width: 1.4),
                borderRadius: BorderRadius.circular(16),
              ),
              submittedPinTheme: defaultPinTheme.copyDecorationWith(
                border: Border.all(color: const Color(0xFF2563EB), width: 1.2),
                borderRadius: BorderRadius.circular(16),
              ),
              onCompleted: (pin) {
                _submitCode(pin);
              },
            ),
            18.heightSpace,
            if (isVerifying) ...[
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
              18.heightSpace,
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isVerifying
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    child: AppText(
                      AppStrings.cancel.tr(),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
                12.widthSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: isVerifying
                        ? null
                        : () {
                            _submitCode(widget.controller.text.trim());
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      elevation: 0,
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: AppText(
                      AppStrings.verify.tr(),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
