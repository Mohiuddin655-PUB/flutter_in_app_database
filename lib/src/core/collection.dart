part of 'base.dart';

class InAppQuerySnapshot {
  final String id;
  final List<InAppDocumentSnapshot> docs;
  final List<InAppDocumentChange> docChanges;

  bool get exists => docs.isNotEmpty;

  const InAppQuerySnapshot(
    this.id, [
    this.docs = const [],
    this.docChanges = const [],
  ]);

  @override
  String toString() {
    return "InAppQuerySnapshot (path: $id, docs: $docs, docChanges: $docChanges)";
  }
}

class InAppDocumentChange {
  final InAppDocumentSnapshot doc;

  const InAppDocumentChange({
    required this.doc,
  });

  @override
  String toString() {
    return "InAppDocumentChange(doc: $doc)";
  }
}

class InAppCollectionReference extends InAppReference {
  final String collectionPath;
  final String collectionId;

  const InAppCollectionReference({
    required super.db,
    required super.reference,
    required this.collectionPath,
    required this.collectionId,
  });

  InAppCollectionNotifier? get notifier => db.notifier(collectionPath);

  T _n<T>(T value, [InAppQuerySnapshot? snapshot]) {
    if (notifier != null) {
      if (snapshot == null) {
        get().then((value) {
          return notifier!.value = value;
        });
      } else {
        notifier!.value = snapshot;
      }
    }
    return value;
  }

  void notify([InAppQuerySnapshot? snapshot]) => _n(null, snapshot);

  InAppDocumentReference doc(String field) {
    return InAppDocumentReference(
      db: db,
      reference: "$reference/$field",
      collectionPath: collectionPath,
      collectionId: collectionId,
      documentId: field,
      parent: this,
    );
  }

  Future<InAppDocumentSnapshot?> add(InAppDocument data) {
    final id = this.id;
    return doc(id).set(data).then((value) {
      return value ? InAppDocumentSnapshot(id, data) : null;
    }).then(_n);
  }

  Future<bool> delete() {
    return db
        .write(
          reference: reference,
          collectionPath: collectionPath,
          collectionId: collectionId,
          documentId: collectionId,
          type: InAppWriteType.collection,
        )
        .then(_n);
  }

  Future<InAppQuerySnapshot> get() {
    return db.read(
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      documentId: collectionId,
      type: InAppReadType.collection,
    );
  }

  Stream<InAppQuerySnapshot> snapshots() {
    final controller = StreamController<InAppQuerySnapshot>();
    db.setNotifier(collectionPath);
    notifier?.addListener(() {
      controller.add(notifier?.value ?? InAppQuerySnapshot(collectionId));
    });
    _n(null);
    return controller.stream;
  }
}
