part of 'database.dart';

class InAppDatabaseVersion {
  final String code;

  const InAppDatabaseVersion.custom(this.code);

  static InAppDatabaseVersion get v1 => InAppDatabaseVersion.custom("v1");

  static InAppDatabaseVersion get v2 => InAppDatabaseVersion.custom("v2");

  String get documentId => DateTime.now().millisecondsSinceEpoch.toString();

  String get documentIdRef => code == v1.code ? "_id" : "id";

  String ref([String? path]) {
    if (path == null) return code == v1.code ? '' : '$code/';
    return code == v1.code ? path : "$code/$path";
  }
}
