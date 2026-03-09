// Project imports:

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension NumExtensions on num {
  /// height spacer
  SizedBox get heightSpace => SizedBox(height: (this).h);

  /// width spacer
  SizedBox get widthSpace => SizedBox(width: (this).w);

  /// horizontal divider
  Widget get dividerHorizontal => Container(
    height: (this).h,
    color: const Color.fromARGB(255, 235, 235, 235),
  );

  /// vertical divider
  Widget get dividerVertical => Container(
    width: (this).w,
    color: const Color.fromARGB(255, 235, 235, 235),
  );

  /// Checks if num a LOWER than num b.
  bool isLowerThan(num b) => this < b;

  /// Checks if num a GREATER than num b.
  bool isGreaterThan(num b) => this > b;

  /// Checks if num a EQUAL than num b.
  bool isEqual(num b) => this == b;

  /// Utility to delay some callback (or code execution).
  Future delay([FutureOr Function()? callback]) async =>
      Future.delayed(Duration(milliseconds: (this * 1000).round()), callback);

  Duration get milliseconds => Duration(microseconds: (this * 1000).round());

  Duration get seconds => Duration(milliseconds: (this * 1000).round());

  Duration get minutes =>
      Duration(seconds: (this * Duration.secondsPerMinute).round());

  Duration get hours =>
      Duration(minutes: (this * Duration.minutesPerHour).round());

  Duration get days => Duration(hours: (this * Duration.hoursPerDay).round());
}
