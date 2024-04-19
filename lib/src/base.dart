part of 'database.dart';

typedef InAppValue = Object?;
typedef InAppDocument = Map<String, InAppValue>;

class InAppDocumentId {
  final String id;

  const InAppDocumentId(this.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => id;

  @override
  bool operator ==(Object other) {
    return super == other && hashCode == other.hashCode;
  }
}

class InAppSetOptions {
  final bool merge;

  const InAppSetOptions({
    this.merge = false,
  });
}
