/*
part of 'base.dart';

typedef InAppCollections = Map<String, Object?>;
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

enum InAppDataReaderType {
  collection,
  document;

  bool get isCollection => this == collection;

  bool get isDocument => this == document;
}

class InAppDataReader extends InAppParams {
  final InAppDataReaderType type;

  const InAppDataReader({
    required super.reference,
    required super.collectionPath,
    required super.collectionId,
    required super.documentPath,
    required super.documentId,
    required this.type,
  });
}

enum InAppDataWriterType {
  collection,
  document;

  bool get isCollection => this == collection;

  bool get isDocument => this == document;
}

class InAppDataWriter extends InAppParams {
  final String? value;
  final InAppDataWriterType type;

  const InAppDataWriter({
    required super.reference,
    required super.collectionPath,
    required super.collectionId,
    required super.documentPath,
    required super.documentId,
    required this.value,
    required this.type,
  });
}

class InAppDatabaseInstance {
  final String name;
  final InAppDatabaseReader reader;
  final InAppDatabaseWriter writer;
  final Map<String, InAppCollectionNotifier> notifiers = {};

  InAppDatabaseInstance._({
    required this.name,
    required this.reader,
    required this.writer,
  });

  static InAppDatabaseInstance? _i;

  static InAppDatabaseInstance get i => _i!;

  static Future<InAppDatabaseInstance> init({
    required InAppDatabaseReader reader,
    required InAppDatabaseWriter writer,
  }) async {
    _i ??= InAppDatabaseInstance._(
      name: "__in_app_database__",
      reader: reader,
      writer: writer,
    );
    return _i!;
  }

  InAppCollectionNotifier? notifier(String reference) {
    final x = notifiers[reference];
    if (x != null) {
      return x;
    } else {
      return null;
    }
  }

  void setNotifier(
      String reference, [
        InAppCollectionNotifier? notifier,
      ]) {
    notifiers.putIfAbsent(reference, () {
      return notifier ?? InAppCollectionNotifier(null);
    });
  }

  void removeNotifier(String reference) {
    notifiers.remove(reference);
  }

  InAppCollectionReference ref(String field) {
    return InAppCollectionReference(
      db: this,
      reference: "$name$field",
      collectionPath: field,
      collectionId: field,
    );
  }

  Future<InAppQuerySnapshot> _r(InAppDataReader r) async {
    final raw = await reader(r.collectionPath);
    final value = raw is String ? jsonDecode(raw) : raw;
    if (r.type.isCollection && value is Map) {
      final data = value.entries
          .map((e) {
        final x = e.value;
        final y = x is String ? jsonDecode(x) : x;
        final z = y is InAppDocument ? y : null;
        return InAppDocumentSnapshot(e.key, z);
      })
          .where((i) => i.data != null && i.data!.isNotEmpty)
          .toList();
      return InAppQuerySnapshot(r.collectionId, data);
    } else if (value is InAppDocument) {
      final snapshot = InAppDocumentSnapshot(r.documentId, value);
      return InAppQuerySnapshot(r.collectionId, [snapshot]);
    } else {
      return InAppQuerySnapshot(r.collectionId);
    }
  }

  Future<bool> _w(InAppDataWriter w) async {
    final value = await reader(w.collectionPath);
    final raw = value is String ? jsonDecode(value) : null;
    final base = raw is Map ? raw : {};
    if (w.type.isCollection) {
      base[w.collectionPath] = w.value;
    } else {
      base.putIfAbsent(w.collectionPath, () => {});
      base[w.collectionPath]?[w.documentId] = w.value;
    }
    final body = jsonEncode(base);
    return writer(w.collectionPath, body).then((value) {
      return true;
    });
  }

  Future<InAppQuerySnapshot> read({
    required InAppDataReaderType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
  }) {
    return _r(InAppDataReader(
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      documentPath: "$collectionPath/$documentId",
      documentId: documentId,
      type: type,
    ));
  }

  Future<bool> write({
    required InAppDataWriterType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
    Object? value,
  }) {
    return _w(InAppDataWriter(
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      documentPath: "$collectionPath/$documentId",
      documentId: documentId,
      value: value == null ? null : jsonEncode(value),
      type: type,
    ));
  }
}
*/
