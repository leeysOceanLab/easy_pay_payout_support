import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/shared_prefs_constant.dart';

class SecureStorage {
  static FlutterSecureStorage? _flutterSecureStorage;

  factory SecureStorage() => SecureStorage._internal();

  SecureStorage._internal();

  Future<void> init() async {
    _flutterSecureStorage ??= const FlutterSecureStorage();
  }

  Future<FlutterSecureStorage> get _storage async {
    await init();
    return _flutterSecureStorage!;
  }

  Future<String?> readString(String key) async {
    final storage = await _storage;
    return await storage.read(key: key);
  }

  Future<void> writeString(String key, String? value) async {
    final storage = await _storage;

    if (value == null) {
      await storage.delete(key: key);
      return;
    }

    await storage.write(key: key, value: value);
  }

  Future<void> deleteAll() async {
    final storage = await _storage;
    await storage.deleteAll();
  }

  Future<void> delete(String key) async {
    final storage = await _storage;
    await storage.delete(key: key);
  }

  Future<String?> readLoginToken() async {
    return await readString(kLoginTokenSP);
  }

  Future<void> writeLoginToken(String? value) async {
    await writeString(kLoginTokenSP, value);
  }

  Future<void> deleteLoginToken() async {
    await delete(kLoginTokenSP);
  }
}
