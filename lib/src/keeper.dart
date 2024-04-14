part of 'database.dart';

class DataKeeper {
  final SharedPreferences preferences;

  const DataKeeper(
    this.preferences,
  );

  factory DataKeeper.of({
    required SharedPreferences preferences,
  }) {
    return DataKeeper(preferences);
  }

  bool isExists(String key) {
    return preferences.containsKey(key);
  }

  Map<String, dynamic>? getItem(
    String key, [
    Map<String, dynamic>? defaultValue,
  ]) {
    var value = preferences.getString(key);
    var data = jsonDecode(value ?? "{}");
    if (data is Map<String, dynamic>) {
      return data;
    } else {
      return defaultValue;
    }
  }

  List<Map<String, dynamic>>? getItems(
    String key, [
    List<Map<String, dynamic>>? defaultValue,
  ]) {
    var value = preferences.getString(key);
    var data = jsonDecode(value ?? "[]");
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    } else {
      return defaultValue;
    }
  }

  Set<String> getKeys() {
    return preferences.getKeys();
  }

  bool getBoolean(String key, [bool defaultValue = false]) {
    final value = preferences.getBool(key);
    return value ?? defaultValue;
  }

  double getDouble(String key, [double defaultValue = 0.0]) {
    final value = preferences.getDouble(key);
    return value ?? defaultValue;
  }

  int getInt(String key, [int defaultValue = 0]) {
    final value = preferences.getInt(key);
    return value ?? defaultValue;
  }

  String? getString(String key, [String? defaultValue]) {
    final value = preferences.getString(key);
    return value ?? defaultValue;
  }

  Future<bool> setItem(
    String key,
    Map<String, dynamic>? value,
  ) {
    return preferences.setString(key, jsonEncode(value ?? {}));
  }

  Future<bool> setItems(
    String key,
    List<Map<String, dynamic>>? value,
  ) {
    return preferences.setString(key, jsonEncode(value ?? []));
  }

  List<String> getStrings(String key, [List<String> defaultValue = const []]) {
    return preferences.getStringList(key) ?? defaultValue;
  }

  Future<bool> setBoolean(String key, bool value) {
    return preferences.setBool(key, value);
  }

  Future<bool> setDouble(String key, double value) {
    return preferences.setDouble(key, value);
  }

  Future<bool> setInt(String key, int value) {
    return preferences.setInt(key, value);
  }

  Future<bool> setString(String key, String? value) {
    return preferences.setString(key, value ?? "");
  }

  Future<bool> setStrings(String key, List<String>? values) {
    return preferences.setStringList(key, values ?? []);
  }

  Future<bool> removeItem(String key) {
    return preferences.remove(key);
  }

  Future<bool> clearItems(String key) {
    return preferences.remove(key);
  }

  Future<bool> clear() {
    return preferences.clear();
  }

  Future<void> reload() {
    return preferences.reload();
  }
}
