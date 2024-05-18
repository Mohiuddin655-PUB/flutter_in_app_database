part of 'database.dart';

abstract class InAppCollectionReference extends InAppReference {
  final String path;
  final String id;

  const InAppCollectionReference({
    required super.db,
    required super.reference,
    required this.path,
    required this.id,
  });

  _InAppQueryNotifier? get _notifier {
    final x = _db._notifiers[path];
    return x is _InAppQueryNotifier ? x : null;
  }

  T _n<T>(T value, [InAppQuerySnapshot? snapshot]) {
    if (_notifier != null) {
      if (snapshot == null) {
        get().then((_) => _notifier!.value = _);
      } else {
        _notifier!.value = snapshot;
      }
    }
    return value;
  }

  void _notify([InAppQuerySnapshot? snapshot]) => _n(null, snapshot);

  String push() => _id;

  InAppDocumentReference doc(String field) {
    return InAppDocumentReference(
      db: _db,
      reference: "$reference/$field",
      id: field,
      parent: this,
    );
  }

  Future<InAppDocumentSnapshot?> add(InAppDocument data) {
    final i = data[_idField];
    final id = i is String ? i : _id;
    data[_idField] = id;
    return doc(id).set(data).then(_n);
  }

  Future<InAppQuerySnapshot?> set(
    List<InAppDocumentSnapshot> data, {
    bool notifiable = false,
  }) {
    final query = InAppQuerySnapshot(id, data);
    return _db
        ._w(
          reference: reference,
          collectionPath: path,
          collectionId: id,
          documentId: id,
          type: InAppWriteType.collection,
          value: query.rootDocs,
        )
        .then((_) => notifiable ? _n(_) : _)
        .then((_) => _ ? query : null);
  }

  Future<bool> delete({
    bool notifiable = false,
  }) {
    return _db
        ._w(
          reference: reference,
          collectionPath: path,
          collectionId: id,
          documentId: id,
          type: InAppWriteType.collection,
        )
        .then((_) => notifiable ? _n(_) : _);
  }

  Future<InAppQuerySnapshot> get() {
    return _db
        ._r(
          reference: reference,
          collectionPath: path,
          collectionId: id,
          documentId: id,
          type: InAppReadType.collection,
        )
        .then((_) => _ is InAppQuerySnapshot ? _ : InAppQuerySnapshot(_id));
  }

  Stream<InAppQuerySnapshot> snapshots() {
    final c = StreamController<InAppQuerySnapshot>();
    final n = _db._addNotifier(path);
    n.addListener(() => c.add(n.value ?? InAppQuerySnapshot(id)));
    Future.delayed(const Duration(seconds: 1)).whenComplete(_notify);
    return c.stream;
  }
}
