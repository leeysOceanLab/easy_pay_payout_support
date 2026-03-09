import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static final SharedPrefs _instance = SharedPrefs._internal();
  factory SharedPrefs() => _instance;
  SharedPrefs._internal();

  static SharedPrefs get instance => _instance;

  SharedPreferences? _sharedPreferences;

  Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_sharedPreferences == null) {
      throw Exception(
        'SharedPrefs is not initialized. Call SharedPrefs.instance.init() first.',
      );
    }
    return _sharedPreferences!;
  }

  bool? readBool(String key) {
    return prefs.getBool(key);
  }

  int readInt(String key) {
    return prefs.getInt(key) ?? 0;
  }

  String? readString(String key) {
    return prefs.getString(key);
  }

  Future<bool> writeBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  Future<bool> writeInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  Future<bool> writeString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  Future<bool> clear() async {
    return await prefs.clear();
  }
}
