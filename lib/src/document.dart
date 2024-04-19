part of 'database.dart';

class InAppDocumentReference extends InAppReference {
  final String collectionPath;
  final String collectionId;
  final String documentId;
  final InAppCollectionReference parent;

  const InAppDocumentReference({
    required super.reference,
    required super.db,
    required this.collectionPath,
    required this.collectionId,
    required this.documentId,
    required this.parent,
  });

  InAppQueryNotifier? get collectionNotifier {
    final x = db.notifiers[collectionPath];
    return x is InAppQueryNotifier ? x : null;
  }

  InAppDocumentNotifier? get documentNotifier {
    return collectionNotifier?.children[documentId];
  }

  T _n<T>(T value, [InAppDocumentSnapshot? snapshot]) {
    if (collectionNotifier != null) parent.notify();
    if (documentNotifier != null) {
      if (snapshot == null) {
        get().then((_) => documentNotifier!.value = _);
      } else {
        documentNotifier!.value = snapshot;
      }
    }
    return value;
  }

  void notify([InAppDocumentSnapshot? snapshot]) => _n(null, snapshot);

  InAppQueryReference collection(String field) {
    return InAppQueryReference(
      db: db,
      reference: "$reference/$field",
      collectionPath: "$collectionPath/$documentId/$field",
      collectionId: field,
    );
  }

  /// Method to set data in the document.
  ///
  /// Parameters:
  /// - [data]: The data to be set in the document.
  ///
  /// Example:
  /// ```dart
  /// documentRef.set({'name': 'John', 'age': 30});
  /// ```
  Future<InAppDocumentSnapshot?> set(
    InAppDocument data, [
    InAppSetOptions options = const InAppSetOptions(),
  ]) {
    final i = data[idField];
    final id = i is String ? i : documentId;
    data[idField] = id;
    if (options.merge) {
      return update(data);
    } else {
      return db
          .write(
            reference: reference,
            collectionPath: collectionPath,
            collectionId: collectionId,
            documentId: documentId,
            type: InAppWriteType.document,
            value: data,
          )
          .then(_n)
          .then((_) => _ ? InAppDocumentSnapshot(id, data) : null);
    }
  }

  /// Method to update data in the document.
  ///
  /// Parameters:
  /// - [data]: The data to be updated in the document.
  ///
  /// Example:
  /// ```dart
  /// documentRef.update({'age': 31});
  /// ```
  Future<InAppDocumentSnapshot?> update(InAppDocument data) {
    return get().then((value) {
      final current = value?.data ?? {};
      current.addAll(data);
      current[idField] = documentId;
      return db
          .write(
            reference: reference,
            collectionPath: collectionPath,
            collectionId: collectionId,
            documentId: documentId,
            type: InAppWriteType.document,
            value: current,
          )
          .then(_n)
          .then((_) => _ ? InAppDocumentSnapshot(id, current) : null);
    });
  }

  /// Method to delete the document.
  ///
  /// Example:
  /// ```dart
  /// documentRef.delete();
  /// ```
  Future<bool> delete() {
    return db
        .write(
          reference: reference,
          collectionPath: collectionPath,
          collectionId: collectionId,
          documentId: documentId,
          type: InAppWriteType.document,
        )
        .then(_n);
  }

  /// Method to get all data in the document.
  ///
  /// Example:
  /// ```dart
  /// Data documentData = documentRef.get();
  /// ```
  Future<InAppDocumentSnapshot?> get() {
    return db
        .read(
          reference: reference,
          collectionPath: collectionPath,
          collectionId: collectionId,
          documentId: documentId,
          type: InAppReadType.document,
        )
        .then((_) => _ is InAppDocumentSnapshot ? _ : null);
  }

  Stream<InAppDocumentSnapshot> snapshots() {
    final c = StreamController<InAppDocumentSnapshot>();
    final n = db.addChildListener(collectionPath, documentId);
    n.addListener(() => c.add(n.value ?? InAppDocumentSnapshot(documentId)));
    Future.delayed(const Duration(seconds: 1)).whenComplete(notify);
    return c.stream;
  }
}
