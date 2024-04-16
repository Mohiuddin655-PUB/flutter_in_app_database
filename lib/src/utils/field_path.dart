part of 'query.dart';

enum InAppFieldPathType {
  documentId,
  none,
}

class DataFieldPath {
  final Object? field;
  final InAppFieldPathType type;

  const DataFieldPath(
    this.field, [
    this.type = InAppFieldPathType.none,
  ]);

  static DataFieldPath get documentId {
    return const DataFieldPath(null, InAppFieldPathType.documentId);
  }
}
