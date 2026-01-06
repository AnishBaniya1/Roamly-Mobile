import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Private named constructor
  SecureStorageService._internal();
  //Create a single static instance
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  //Public factory constructor that always returns the same instance
  factory SecureStorageService() => _instance;
  // Instance of FlutterSecureStorage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  //save data
  Future<bool> setValue(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (e) {
      return false;
    }
  }

  //retrieve data
  Future<String?> readValue(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      return null;
    }
  }

  //delete data
  Future<bool> clearValue(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all secure storage
  Future<bool> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      return false;
    }
  }
}
