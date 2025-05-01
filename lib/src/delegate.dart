import '../in_app_database.dart';

abstract class InAppDatabaseDelegate {
  Future<void> init(String dbName);

  Future<Iterable<String>> paths(String dbName);

  Future<bool> drop(String dbName, String path);

  Future<Object?> read(String dbName, String path);

  Future<bool> write(String dbName, String path, String? data);

  Future<InAppWriteLimitation?> limitation(String dbName, PathDetails details);
}
