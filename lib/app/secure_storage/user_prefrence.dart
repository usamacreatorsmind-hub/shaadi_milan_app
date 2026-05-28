import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserPreference {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _keyCollectionPath = 'collection_path';
  static const String _keyUserType = 'user_type';

  Future<void> setCollectionPath(String path) async {
    await _secureStorage.write(key: _keyCollectionPath, value: path);
  }

  Future<String?> getCollectionPath() async {
    return await _secureStorage.read(key: _keyCollectionPath);
  }

  Future<void> setUserType(String userType) async {
    await _secureStorage.write(key: _keyUserType, value: userType);
  }

  Future<String?> getUserType() async {
    return await _secureStorage.read(key: _keyUserType);
  }

  Future<void> clearPreferences() async {
    await _secureStorage.deleteAll();
  }
}
