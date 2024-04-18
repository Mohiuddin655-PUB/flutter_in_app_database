typedef InAppDatabaseReader = Future<String?> Function(String key);
typedef InAppDatabaseWriter = Future<bool> Function(String key, String? value);

class InAppParams {
  final String reference;
  final String collectionPath;
  final String collectionId;
  final String documentPath;
  final String documentId;

  const InAppParams({
    required this.reference,
    required this.collectionPath,
    required this.collectionId,
    required this.documentPath,
    required this.documentId,
  });
}

enum InAppReadType {
  collection,
  document;

  bool get isCollection => this == collection;

  bool get isDocument => this == document;
}

class InAppReadParams extends InAppParams {
  final InAppReadType type;

  const InAppReadParams({
    required super.reference,
    required super.collectionPath,
    required super.collectionId,
    required super.documentPath,
    required super.documentId,
    required this.type,
  });
}

enum InAppWriteType {
  collection,
  document;

  bool get isCollection => this == collection;

  bool get isDocument => this == document;
}

class InAppWriteParams extends InAppParams {
  final String? value;
  final InAppWriteType type;

  const InAppWriteParams({
    required super.reference,
    required super.collectionPath,
    required super.collectionId,
    required super.documentPath,
    required super.documentId,
    required this.value,
    required this.type,
  });
}
