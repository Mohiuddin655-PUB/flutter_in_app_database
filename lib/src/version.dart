part of 'database.dart';

class InAppDatabaseVersion {
  final String code;

  const InAppDatabaseVersion.custom(this.code);

  static InAppDatabaseVersion get v1 => InAppDatabaseVersion.custom("v1");

  static InAppDatabaseVersion get v2 => InAppDatabaseVersion.custom("v2");

  String get documentId {
    switch (code) {
      case "v1":
        return DateTime.now().millisecondsSinceEpoch.toString();
      default:
        return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  String get documentIdRef {
    switch (code) {
      case "v1":
        return "_id";
      default:
        return "id";
    }
  }

  String _root(String dbName) {
    switch (code) {
      case 'v1':
        return dbName;
      default:
        return "$dbName/$code/";
    }
  }

  String ref(String dbName, [String? path]) {
    final root = _root(dbName);
    if (path == null || path.isEmpty) return root;
    return "$root$path";
  }

  String collectionRef(String dbName, String path) {
    switch (code) {
      case "v1":
        return path;
      default:
        return ref(dbName, path);
    }
  }

  T call<T extends Object?>(String action, T Function() callback) {
    return callback();
  }
}
