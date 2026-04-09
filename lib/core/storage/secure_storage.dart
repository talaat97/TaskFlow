import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class SecureStorageService {
  SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<void> saveToken(String token) =>
      _storage.write(key: kTokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: kTokenKey);

  static Future<void> saveUserInfo({
    required String email,
    required String name,
  }) async {
    await _storage.write(key: kUserEmailKey, value: email);
    await _storage.write(key: kUserNameKey, value: name);
  }

  static Future<Map<String, String?>> getUserInfo() async {
    return {
      'email': await _storage.read(key: kUserEmailKey),
      'name': await _storage.read(key: kUserNameKey),
    };
  }

  static Future<void> clearAll() => _storage.deleteAll();
}
