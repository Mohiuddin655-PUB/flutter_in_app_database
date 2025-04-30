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

  String ref(String dbName, String collectionName) {
    switch (code) {
      case 'v1':
        return "$dbName$collectionName";
      case 'v2':
        return "$dbName/$collectionName";
      default:
        return "$dbName/$code/$collectionName";
    }
  }

  T call<T extends Object?>(String action, T Function() callback) {
    return callback();
  }
}
