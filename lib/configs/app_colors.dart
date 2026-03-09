// Project imports:

import 'package:flutter/material.dart';

import '../extensions/color_extensions.dart';

class AppColors {
  AppColors._();

  static late BuildContext _context;
  static AppColors of(BuildContext context) {
    _context = context;
    return AppColors._();
  }

  // normal colors
  static const Color dividerColor = Color.fromRGBO(224, 224, 224, 1);
  static const Color primaryColor = Colors.black;
  static const Color primaryTextColor = Colors.black;
  static const Color disableColor = Color.fromRGBO(171, 170, 175, 1);
  static const Color buttonTextColor = Colors.white;
  static const Color primaryNoContextColor = Color.fromRGBO(0, 102, 246, 1);
  static const Color blackColor = Colors.black;
  static const Color blackLightColor = Color.fromARGB(255, 112, 112, 112);
  static const Color whiteColor = Colors.white;
  static const Color redColor = Colors.red;
  static const Color greyColor = Colors.grey;
  static const Color blueColor = Colors.blue;
  static const Color greenColor = Colors.green;
  static const Color greyLightColor = Color.fromARGB(255, 225, 225, 225);
  static const Color toastNormalColor = Color.fromRGBO(57, 57, 57, 1);
  static const Color toastSuccessColor = Colors.green;
  static const Color toastErrorColor = Colors.red;
  static const Color toastWarningColor = Colors.orange;
  static const Color primaryLightColor = Color.fromRGBO(45, 45, 45, 0.6);
  static const Color transparentColor = Colors.transparent;
  static const Color darkRedColor = Color.fromRGBO(213, 45, 31, 1);
  static const Color orangeColor = Colors.orange;
  static const Color textLightColor = Color.fromARGB(255, 80, 80, 80);
  static const Color greyBackgroundColor = Color.fromARGB(255, 245, 245, 245);
  static const Color lightGreyBackgroundColor = Color.fromARGB(
    255,
    250,
    250,
    250,
  );
  static const Color successGreen = Color.fromRGBO(0, 175, 26, 1.0);
  static const Color lightBlueCyan = Color.fromARGB(255, 154, 203, 208);
  static const Color labelColor = Colors.black38;
  static const Color lightPrimaryColor = Color.fromRGBO(225, 238, 254, 1);
  static const Color hintColor = Colors.grey;
  static const Color containerBgColor = Colors.white;

  static const Color pageBgColor = Color(0xFFF5F7FB);
  static const Color secondaryTextColor = Color(0xFF6B7280);

  static const Color listingBorderColor = Color(0xFFEBEEF2);
  static const Color listingSubTextColor = Color(0xFF4B5563);

  static const Color listingDisabledBgColor = Color(0xFFF8FAFC);
  static const Color listingDisabledBorderColor = Color(0xFFE5E7EB);
  static const Color listingDisabledTitleColor = Color(0xFF6B7280);
  static const Color listingDisabledTextColor = Color(0xFF9CA3AF);
  static const Color listingDisabledIconColor = Color(0xFF9CA3AF);

  static const Color listingArrowColor = Color(0xFF9CA3AF);

  static const Color lockedByMeBgColor = Color(0xFFDBEAFE);
  static const Color lockedByMeTextColor = Color(0xFF1D4ED8);

  static const Color availableBgColor = Color(0xFFDCFCE7);
  static const Color availableTextColor = Color(0xFF15803D);

  static const Color incompleteButtonColor = Color(0xFFDC2626);
  static const Color completedButtonColor = Color(0xFF0D9488);

  static const Color lightRedBackgroundColor = Color(0xFFFEECEC);
  static const Color lightRedBorderColor = Color(0xFFF5B5B5);

  // gradient
  // gradient
  static LinearGradient get greyTransparentGradientColor => LinearGradient(
    colors: [
      Colors.black26.wOpacity(0.50),
      Colors.transparent,
      Colors.black26.wOpacity(0.65),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static LinearGradient get whiteGradientColor => const LinearGradient(
    colors: [Colors.white, Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static LinearGradient get buttonGradientColor => const LinearGradient(
    colors: [Color.fromRGBO(0, 102, 246, 1), Color.fromRGBO(0, 43, 103, 1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // shadow
  static final List<BoxShadow> shadowDefault = [
    BoxShadow(
      color: Colors.grey.shade200,
      spreadRadius: 0.0,
      blurRadius: 1,
      offset: const Offset(0.5, 1.0),
    ),
    BoxShadow(
      color: Colors.grey.shade400,
      spreadRadius: 0.0,
      blurRadius: 1,
      offset: const Offset(0.5, 1.0),
    ),
  ];

  static final List<BoxShadow> shadowLight = [
    BoxShadow(
      color: Colors.grey.shade100,
      spreadRadius: 0.0,
      blurRadius: 2,
      offset: const Offset(0, 1.0),
    ),
    BoxShadow(
      color: Colors.grey.shade300,
      spreadRadius: 0.0,
      blurRadius: 2,
      offset: const Offset(0, 1.0),
    ),
  ];

  static final List<BoxShadow> shadowDark = [
    BoxShadow(
      color: Colors.grey.shade600.wOpacity(0.5),
      spreadRadius: 1,
      blurRadius: 6,
      offset: const Offset(0, 3),
    ),
    BoxShadow(
      color: Colors.black.wOpacity(0.25),
      spreadRadius: 0,
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
