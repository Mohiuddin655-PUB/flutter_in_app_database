part of 'base.dart';

class InAppDatabase {
  final String name;
  final InAppDatabaseReader reader;
  final InAppDatabaseWriter writer;
  final Map<String, InAppCollectionNotifier> notifiers = {};

  InAppDatabase._({
    required this.name,
    required this.reader,
    required this.writer,
  });

  static InAppDatabase? _i;

  static InAppDatabase get i => _i!;

  static Future<InAppDatabase> init({
    required InAppDatabaseReader reader,
    required InAppDatabaseWriter writer,
  }) async {
    _i ??= InAppDatabase._(
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

  Future<InAppQuerySnapshot> _r(InAppReadParams r) {
    return reader(r.collectionPath).then((raw) {
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
    });
  }

  Future<bool> _w(InAppWriteParams w) async {
    return reader(w.collectionPath).then((value) {
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
    });
  }

  Future<InAppQuerySnapshot> read({
    required InAppReadType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
  }) {
    return _r(InAppReadParams(
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      documentPath: "$collectionPath/$documentId",
      documentId: documentId,
      type: type,
    ));
  }

  Future<bool> write({
    required InAppWriteType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
    Object? value,
  }) {
    return _w(InAppWriteParams(
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
