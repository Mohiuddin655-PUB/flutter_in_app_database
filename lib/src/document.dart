part of 'database.dart';

class InAppDocumentReference extends InAppReference {
  final String id;
  final InAppCollectionReference _p;

  const InAppDocumentReference({
    required super.reference,
    required super.db,
    required this.id,
    required InAppCollectionReference parent,
  }) : _p = parent;

  String get path => "${_p.path}/$id";

  InAppQueryNotifier? get _cn {
    final x = _db._notifiers[_p.path];
    return x is InAppQueryNotifier ? x : null;
  }

  InAppDocumentNotifier? get _dn => _cn?.children[id];

  T _n<T>(T value, [InAppDocumentSnapshot? snapshot]) {
    if (_cn != null) _p._notify();
    if (_dn != null) {
      if (snapshot == null) {
        get().then((_) => _dn!.value = _);
      } else {
        _dn!.value = snapshot;
      }
    }
    return value;
  }

  void _notify([InAppDocumentSnapshot? snapshot]) => _n(null, snapshot);

  InAppQueryReference collection(String field) {
    return InAppQueryReference(
      db: _db,
      reference: "$reference/$field",
      path: "$path/$field",
      id: field,
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
    final i = data[_idField];
    final mId = i is String ? i : id;
    data[_idField] = mId;
    if (options.merge) {
      return update(data);
    } else {
      return _db
          ._w(
            reference: reference,
            collectionPath: _p.path,
            collectionId: _p.id,
            documentId: mId,
            type: InAppWriteType.document,
            value: data,
          )
          .then(_n)
          .then((_) => _ ? InAppDocumentSnapshot(mId, data) : null);
    }
  }

  /// Method to update data in the document.
  ///
  /// Parameters:
  /// - [data]: The data to be updated in the document.
  ///
  /// Example:
  /// ```dart
  /// documentRef.update({
  ///     'name': Mr. X,
  ///     'age': InAppFieldValue.increment(2),
  ///     'balance': InAppFieldValue.increment(-10.2),
  ///     'hobbies': InAppFieldValue.arrayUnion(['swimming']),
  ///     'skills': InAppFieldValue.arrayRemove(['coding', 'gaming']),
  ///     'timestamp': InAppFieldValue.serverTimestamp(),
  ///     'extra': InAppFieldValue.delete(),
  ///   });
  /// ```
  Future<InAppDocumentSnapshot?> update(InAppDocument data) {
    return get().then((base) {
      final current = _InAppMerger(base.data).merge(data);
      current[_idField] = id;
      return _db
          ._w(
            reference: reference,
            collectionPath: _p.path,
            collectionId: _p.id,
            documentId: id,
            type: InAppWriteType.document,
            value: current,
          )
          .then(_n)
          .then((_) => _ ? InAppDocumentSnapshot(_id, current) : null);
    });
  }

  /// Method to delete the document.
  ///
  /// Example:
  /// ```dart
  /// documentRef.delete();
  /// ```
  Future<bool> delete() {
    return _db
        ._w(
      reference: reference,
      collectionPath: _p.path,
      collectionId: _p.id,
      documentId: id,
      type: InAppWriteType.document,
    )
        .then<bool>((_) {
      if (_) {
        return _p.get().then((value) {
          if (!value.exists) {
            return _db._w(
              type: InAppWriteType.collection,
              reference: _p.reference,
              collectionPath: _p.path,
              collectionId: _p.id,
              documentId: _p.id,
            );
          } else {
            return true;
          }
        });
      } else {
        return _;
      }
    }).then(_n);
  }

  /// Method to get all data in the document.
  ///
  /// Example:
  /// ```dart
  /// Data documentData = documentRef.get();
  /// ```
  Future<InAppDocumentSnapshot> get() {
    return _db
        ._r(
      reference: reference,
      collectionPath: _p.path,
      collectionId: _p.id,
      documentId: id,
      type: InAppReadType.document,
    )
        .then((_) {
      return _ is InAppDocumentSnapshot ? _ : InAppDocumentSnapshot(id);
    });
  }

  Stream<InAppDocumentSnapshot> snapshots() {
    final n = _db._addChildNotifier(_p.path, id);
    Future.delayed(const Duration(seconds: 1)).whenComplete(_notify);
    return Stream.multi((c) {
      void update() => c.add(n.value ?? InAppDocumentSnapshot(id));
      n.addListener(update);
      c.onCancel = () => n.removeListener(update);
    });
  }
}
