part of 'database.dart';

class InAppCollectionReference extends InAppReference {
  final String collectionPath;
  final String collectionId;

  const InAppCollectionReference({
    required super.db,
    required super.reference,
    required this.collectionPath,
    required this.collectionId,
  });

  InAppQueryNotifier? get notifier {
    final x = db.notifiers[collectionPath];
    return x is InAppQueryNotifier ? x : null;
  }

  T _n<T>(T value, [InAppQuerySnapshot? snapshot]) {
    if (notifier != null) {
      if (snapshot == null) {
        get().then((_) => notifier!.value = _);
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
    final i = data[idField];
    final id = i is String ? i : this.id;
    data[idField] = id;
    return doc(id).set(data).then(_n);
  }

  Future<InAppQuerySnapshot> get() {
    return db
        .read(
          reference: reference,
          collectionPath: collectionPath,
          collectionId: collectionId,
          documentId: collectionId,
          type: InAppReadType.collection,
        )
        .then((_) => _ is InAppQuerySnapshot ? _ : InAppQuerySnapshot(id));
  }

  Stream<InAppQuerySnapshot> snapshots() {
    final c = StreamController<InAppQuerySnapshot>();
    final n = db.addListener(collectionPath);
    n.addListener(() => c.add(n.value ?? InAppQuerySnapshot(collectionId)));
    Future.delayed(const Duration(seconds: 1)).whenComplete(notify);
    return c.stream;
  }
}
