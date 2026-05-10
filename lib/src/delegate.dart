import '../core/path.dart' show PathDetails;
import 'database.dart' show InAppWriteLimitation;

abstract class InAppDatabaseDelegate {
  const InAppDatabaseDelegate();

  Future<bool> init(String dbName);

  Future<bool> delete(String dbName, String path);

  Future<bool> drop(String dbName);

  Future<Iterable<String>> paths(String dbName);

  Future<Object?> read(String dbName, String path);

  Future<bool> write(String dbName, String path, Object? data);

  Future<InAppWriteLimitation?> limitation(String dbName, PathDetails details);
}
