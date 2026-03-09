import 'package:easy_pay_bank_infomrm/screen/error_screen/argument.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ErrorScreen extends StatelessWidget {
  final ErrorScreenArgument errorScreenArgument;

  ErrorScreen({super.key, ErrorScreenArgument? errorScreenArgument})
    : errorScreenArgument =
          errorScreenArgument ?? ErrorScreenArgument(errorMessage: "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(errorScreenArgument.errorMessage.tr())),
    );
  }
}
