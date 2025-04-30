import '../in_app_database.dart';

abstract class InAppDatabaseDelegate {
  Future<void> createDatabase(String name);

  Future<Iterable<String>> paths(String dbName);

  Future<bool> drop(Iterable<String> paths);

  Future<Object?> read(String key);

  Future<bool> write(String key, String? value);

  Future<InAppWriteLimitation?> limitation(String key);
}
