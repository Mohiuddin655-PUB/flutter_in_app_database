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

  InAppQueryNotifier? get _notifier {
    final x = _db._notifiers[path];
    return x is InAppQueryNotifier ? x : null;
  }

  T _n<T>(T value, [InAppQuerySnapshot? snapshot]) {
    if (_notifier != null) {
      if (snapshot == null) {
        get().then((value) => _notifier!.value = value);
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
    final i = data[_idField] ?? data[_idFieldSecondary];
    final id = i is String ? i : _id;
    data[_idField] = id;
    return doc(id).set(data);
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
        .then((value) => notifiable ? _n(value) : value)
        .then((value) {
      _db._log(value ? "done!" : "failed!", action: "set", field: id);
      return value;
    }).then((value) => value ? query : null);
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
        .then((value) => notifiable ? _n(value) : value)
        .then((value) {
      _db._log(value ? "done!" : "failed!", action: "delete", field: id);
      return value;
    });
  }

  Future<bool> drop({
    bool related = true,
    bool notifiable = false,
    Iterable<String> Function(String path, Iterable<String>)? filter,
  }) async {
    return _db
        ._drop(path, related: related, filter: filter)
        .then((value) => notifiable ? _n(value) : value)
        .then((value) {
      _db._log(value ? "done!" : "failed!", action: "drop", field: id);
      return value;
    });
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
        .then((v) => v is InAppQuerySnapshot ? v : InAppQuerySnapshot(_id));
  }

  Stream<InAppQuerySnapshot> snapshots() {
    final n = _db._addNotifier(path);
    Future.delayed(const Duration(seconds: 1)).whenComplete(_notify);
    return Stream.multi((c) {
      void update() => c.add(n.value ?? InAppQuerySnapshot(id));
      n.addListener(update);
      c.onCancel = () => n.removeListener(update);
    });
  }
}
