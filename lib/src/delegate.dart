import '../in_app_database.dart';

abstract class InAppDatabaseDelegate {
  Future<void> init(String name);

  Future<Iterable<String>> paths(String dbName);

  Future<bool> drop(String key);

  Future<Object?> read(String key);

  Future<bool> write(String key, String? value);

  Future<InAppWriteLimitation?> limitation(String key);
}
