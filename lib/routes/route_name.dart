class RouteName {
  static const String splashPage = '/splash';
  static const String loginPage = '/login';
  static const String mainPage = '/main';
  static const String withdrawalDetails = '/withdrawal_details';
  static const String historyWithdrawalDetails = '/history_withdrawal_details';
  static const String historyWithdrawalList = '/history_withdrawal_list';

  static List<String> allRoutes = [
    splashPage,
    loginPage,
    mainPage,
    withdrawalDetails,
    historyWithdrawalDetails,
    historyWithdrawalList,
  ];

  static bool containsRoute(String routeName) {
    return allRoutes.contains(routeName);
  }
}
