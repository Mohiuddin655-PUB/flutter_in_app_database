import 'package:in_app_database/in_app_database.dart'
    show
        InAppDatabaseDelegate,
        PathDetails,
        InAppWriteLimitation,
        InAppDatabaseException;

class InMemoryDelegate extends InAppDatabaseDelegate {
  final Map<String, Map<String, Object?>> _stores = {};

  bool failNextRead = false;
  bool failNextWrite = false;
  bool failNextDelete = false;
  InAppWriteLimitation? Function(String dbName, PathDetails details)?
      limitationProvider;

  int readCount = 0;
  int writeCount = 0;
  int deleteCount = 0;

  Map<String, Object?>? snapshot(String dbName) =>
      _stores[dbName] == null ? null : Map.of(_stores[dbName]!);

  @override
  Future<bool> init(String dbName) async {
    _stores.putIfAbsent(dbName, () => <String, Object?>{});
    return true;
  }

  @override
  Future<bool> drop(String dbName) async {
    return _stores.remove(dbName) != null;
  }

  @override
  Future<bool> delete(String dbName, String path) async {
    if (failNextDelete) {
      failNextDelete = false;
      return false;
    }
    deleteCount++;
    final store = _stores[dbName];
    if (store == null) return false;
    return store.remove(path) != null;
  }

  @override
  Future<Iterable<String>> paths(String dbName) async {
    return List<String>.unmodifiable(_stores[dbName]?.keys ?? const <String>[]);
  }

  @override
  Future<Object?> read(String dbName, String path) async {
    if (failNextRead) {
      failNextRead = false;
      throw const InAppDatabaseException('Simulated read failure');
    }
    readCount++;
    return _stores[dbName]?[path];
  }

  @override
  Future<bool> write(String dbName, String path, Object? data) async {
    if (failNextWrite) {
      failNextWrite = false;
      return false;
    }
    writeCount++;
    final store = _stores[dbName];
    if (store == null) return false;
    if (data == null) {
      store.remove(path);
    } else {
      store[path] = data;
    }
    return true;
  }

  @override
  Future<InAppWriteLimitation?> limitation(
    String dbName,
    PathDetails details,
  ) async {
    return limitationProvider?.call(dbName, details);
  }

  void reset() {
    _stores.clear();
    failNextRead = false;
    failNextWrite = false;
    failNextDelete = false;
    limitationProvider = null;
    readCount = 0;
    writeCount = 0;
    deleteCount = 0;
  }
}
