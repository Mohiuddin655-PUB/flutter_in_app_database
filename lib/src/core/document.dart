part of 'base.dart';

class InAppDocumentSnapshot {
  final String id;
  final InAppDocument? _doc;

  InAppDocument? get data => _doc;

  bool get exists => _doc != null && _doc!.isNotEmpty;

  const InAppDocumentSnapshot(
      this.id, [
        this._doc,
      ]);

  InAppDocumentSnapshot copy({
    String? id,
    InAppDocument? doc,
  }) {
    return InAppDocumentSnapshot(id ?? this.id, doc ?? _doc);
  }

  @override
  String toString() {
    return "InAppDocumentSnapshot(id: $id, doc: $_doc)";
  }
}

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

  InAppCollectionNotifier get collectionNotifier {
    return db.notifier(collectionPath) ?? InAppCollectionNotifier(null);
  }

  InAppDocumentNotifier? get documentNotifier {
    return collectionNotifier.children[documentId];
  }

  T _n<T>(T value, [InAppDocumentSnapshot? snapshot]) {
    if (documentNotifier != null) {
      get().then((value) {
        documentNotifier!.value = value;
        parent.notify();
      });
    }
    return value;
  }

  void notify([InAppDocumentSnapshot? snapshot]) => _n(null, snapshot);

  InAppCollectionReference collection(String field) {
    return InAppCollectionReference(
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
  Future<bool> set(
    InAppDocument data, [
    InAppSetOptions options = const InAppSetOptions(),
  ]) {
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
          .then(_n);
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
  Future<bool> update(InAppDocument data) {
    return get().then((value) {
      final current = value?.data ?? {};
      current.addAll(data);
      return db
          .write(
            reference: reference,
            collectionPath: collectionPath,
            collectionId: collectionId,
            documentId: documentId,
            type: InAppWriteType.document,
            value: current,
          )
          .then(_n);
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
        .then((value) {
      final x = value.docs.firstOrNull;
      if (x is InAppDocumentSnapshot) {
        return x.data != null && x.data!.isNotEmpty ? x : null;
      } else {
        return null;
      }
    });
  }

  Stream<InAppDocumentSnapshot> snapshots() {
    final controller = StreamController<InAppDocumentSnapshot>();
    db.setNotifier(collectionPath, collectionNotifier.set(documentId));
    documentNotifier?.addListener(() {
      controller.add(
        documentNotifier?.value ?? InAppDocumentSnapshot(documentId),
      );
    });
    _n(null);
    return controller.stream;
  }
}
