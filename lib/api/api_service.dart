// Package imports:
import "package:easy_pay_bank_infomrm/globals.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "../constants/shared_prefs_constant.dart";
import "../utils/shared_prefs.dart";
import "api.dart";

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static late Api _api;
  static Api get api => _api;

  static const FlutterSecureStorage _flutterSecureStorage =
      FlutterSecureStorage();

  static Future<void> init() async {
    await SharedPrefs.instance.init();

    _api = Api(apiUrl: Globals().get("api_base_url"));

    final bool isFirstRun = SharedPrefs.instance.readBool(kFIRST_RUN) ?? true;

    if (isFirstRun) {
      await _flutterSecureStorage.deleteAll();
      await SharedPrefs.instance.writeBool(kFIRST_RUN, false);
    }
  }

  static Future<void> updateApiToken(String token) async {
    try {
      await _flutterSecureStorage.write(key: kLoginTokenSP, value: token);
    } catch (e) {
      // ignore or log error
    }
  }

  static Future<void> deleteApiToken() async {
    try {
      await _flutterSecureStorage.delete(key: kLoginTokenSP);
    } catch (e) {
      // ignore or log error
    }
  }

  static Future<String?> getApiToken() async {
    try {
      return await _flutterSecureStorage.read(key: kLoginTokenSP);
    } catch (e) {
      return null;
    }
  }
}
