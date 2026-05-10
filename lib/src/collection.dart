part of 'database.dart';

abstract class InAppCollectionReference extends InAppReference {
  final String path;
  final String id;
  final InAppDocumentReference? _parent;

  const InAppCollectionReference({
    required super.db,
    required super.ref,
    required this.path,
    required this.id,
    InAppDocumentReference? parent,
  }) : _parent = parent;

  InAppDocumentReference? get parent => _parent;

  Future<List<String>> get keys async {
    final paths = await _db._k(path);
    final prefix = '$ref/';
    final result = <String>{};
    for (final p in paths) {
      if (p == ref) continue;
      if (!p.startsWith(prefix)) continue;
      final remainder = p.substring(prefix.length);
      final first = remainder.split('/').first;
      if (first.isNotEmpty) result.add(first);
    }
    return result.toList(growable: false);
  }

  InAppQueryNotifier? get _notifier {
    final n = _db._notifiers[path];
    return n is InAppQueryNotifier ? n : null;
  }

  T _n<T>(T value, [InAppQuerySnapshot? snapshot]) {
    final n = _notifier;
    if (n == null || n.isDisposed) return value;
    if (snapshot == null) {
      get().then((s) {
        if (!n.isDisposed) n.value = s;
      }).catchError((_) {});
    } else {
      n.value = snapshot;
    }
    return value;
  }

  void _notify([InAppQuerySnapshot? snapshot]) => _n<void>(null, snapshot);

  String push() => _id;

  InAppDocumentReference doc([String? path]) {
    final field = path ?? _id;
    if (field.isEmpty) {
      throw ArgumentError.value(field, 'path', 'Document id cannot be empty.');
    }
    if (field.contains('/')) {
      throw ArgumentError.value(
        field,
        'path',
        'Document id cannot contain "/".',
      );
    }
    return InAppDocumentReference(
      db: _db,
      ref: '$ref/$field',
      id: field,
      parent: this,
    );
  }

  Future<InAppDocumentReference> add(InAppDocument data) async {
    final raw = data[_idField] ?? data[_idFieldSecondary];
    final newId = raw is String && raw.isNotEmpty ? raw : _id;
    final payload = Map<String, InAppValue>.of(data);
    payload[_idField] = newId;
    final ref = doc(newId);
    await ref.set(payload);
    return ref;
  }

  Future<InAppQuerySnapshot?> setAll(
    List<InAppQueryDocumentSnapshot> data, {
    bool notifiable = false,
  }) async {
    final query = InAppQuerySnapshot(id, data);
    final ok = await _db._w(
      reference: ref,
      collectionPath: path,
      collectionId: id,
      documentId: id,
      type: InAppWriteType.collection,
      value: query.rootDocs,
    );
    if (notifiable) _n<void>(null, ok ? query : null);
    _db._log(ok ? 'done!' : 'failed!', action: 'set', field: id);
    return ok ? query : null;
  }

  Future<bool> deleteAll({bool notifiable = false}) async {
    final ok = await _db._w(
      reference: ref,
      collectionPath: path,
      collectionId: id,
      documentId: id,
      type: InAppWriteType.collection,
    );
    if (notifiable) _n<void>(null, null);
    _db._log(ok ? 'done!' : 'failed!', action: 'delete', field: id);
    return ok;
  }

  Future<bool> drop({
    bool related = true,
    bool notifiable = false,
    Iterable<String> Function(String path, Iterable<String>)? filter,
  }) async {
    final ok = await _db._delete(path, related: related, filter: filter);
    if (notifiable) _n<void>(null, null);
    _db._log(ok ? 'done!' : 'failed!', action: 'drop', field: id);
    return ok;
  }

  Future<InAppQuerySnapshot> get([
    InAppSource source = InAppSource.cache,
  ]) async {
    final result = await _db._r(
      reference: ref,
      collectionPath: path,
      collectionId: id,
      documentId: id,
      type: InAppReadType.collection,
    );
    return result is InAppQuerySnapshot ? result : InAppQuerySnapshot(id);
  }

  Stream<InAppQuerySnapshot> snapshots({bool includeMetadataChanges = false}) {
    final n = _db._addNotifier(path);
    return Stream<InAppQuerySnapshot>.multi((controller) {
      InAppQuerySnapshot? last;
      void emit(InAppQuerySnapshot snap) {
        if (controller.isClosed) return;
        if (last == snap) return;
        last = snap;
        controller.add(snap);
      }

      void listener() => emit(n.value ?? InAppQuerySnapshot(id));

      n.addListener(listener);
      controller.onCancel = () {
        n.removeListener(listener);
        _db._maybeCleanupNotifier(path);
      };

      Future<void>(() async {
        try {
          final s = await get();
          if (!controller.isClosed) emit(s);
          if (!n.isDisposed) n.value = s;
        } catch (_) {}
      });
    });
  }
}
