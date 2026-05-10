part of 'database.dart';

class InAppDocumentReference extends InAppReference {
  final String id;
  final InAppCollectionReference _p;

  const InAppDocumentReference({
    required super.ref,
    required super.db,
    required this.id,
    required InAppCollectionReference parent,
  }) : _p = parent;

  String get path => '${_p.path}/$id';

  InAppCollectionReference get parent => _p;

  InAppQueryNotifier? get _cn {
    final n = _db._notifiers[_p.path];
    return n is InAppQueryNotifier ? n : null;
  }

  InAppDocumentNotifier? get _dn => _cn?.children[id];

  T _n<T>(T value, [InAppDocumentSnapshot? snapshot]) {
    final cn = _cn;
    if (cn != null && !cn.isDisposed) _p._notify();
    final dn = _dn;
    if (dn != null && !dn.isDisposed) {
      if (snapshot == null) {
        get().then((s) {
          if (!dn.isDisposed) dn.value = s;
        }).catchError((_) {});
      } else {
        dn.value = snapshot;
      }
    }
    return value;
  }

  InAppQueryReference collection(String field) {
    if (field.isEmpty) {
      throw ArgumentError.value(
        field,
        'field',
        'Collection id cannot be empty.',
      );
    }
    if (field.contains('/')) {
      throw ArgumentError.value(
        field,
        'field',
        'Collection id cannot contain "/".',
      );
    }
    return InAppQueryReference(
      db: _db,
      ref: '$ref/$field',
      path: '$path/$field',
      id: field,
      parent: this,
    );
  }

  Future<void> set(
    InAppDocument data, [
    InAppSetOptions options = InAppSetOptions.defaults,
  ]) async {
    final raw = data[_idField];
    final mId = raw is String && raw.isNotEmpty ? raw : id;
    final payload = Map<String, InAppValue>.of(data);
    payload[_idField] = mId;

    if (options.isMerge) {
      await update(payload, onlyFields: options.mergeFields);
      return;
    }

    final ok = await _db._w(
      reference: ref,
      collectionPath: _p.path,
      collectionId: _p.id,
      documentId: mId,
      type: InAppWriteType.document,
      value: payload,
    );
    final snap = ok ? InAppDocumentSnapshot(mId, payload, this) : null;
    _n<void>(null, snap);
    _db._log(ok ? 'done!' : 'failed!', action: 'set', field: id);
    if (!ok) {
      throw InAppDatabaseException(
        'Failed to set document at "$path".',
        code: 'set-failed',
      );
    }
  }

  Future<void> update(InAppDocument data, {List<Object>? onlyFields}) async {
    Set<String>? onlySet;
    if (onlyFields != null) {
      onlySet = <String>{};
      for (final f in onlyFields) {
        if (f is String) {
          onlySet.add(f);
        } else if (f is InAppFieldPath) {
          if (f.isDocumentId) continue;
          onlySet.add(f.segments.join('.'));
        }
      }
    }

    InAppDocument? merged;
    final ok = await _db._serial(_p.path, () async {
      final base = await get();
      final m = InAppMerger(base.data()).merge(data, onlyFields: onlySet);
      m[_idField] = id;
      merged = m;
      return _db._wInner(
        reference: ref,
        collectionPath: _p.path,
        collectionId: _p.id,
        documentId: id,
        type: InAppWriteType.document,
        value: m,
      );
    });

    final snap =
        (ok && merged != null) ? InAppDocumentSnapshot(id, merged, this) : null;
    _n<void>(null, snap);
    _db._log(ok ? 'done!' : 'failed!', action: 'update', field: id);
    if (!ok) {
      throw InAppDatabaseException(
        'Failed to update document at "$path".',
        code: 'update-failed',
      );
    }
  }

  Future<void> delete() async {
    final ok = await _db._serial(_p.path, () async {
      final r = await _db._wInner(
        reference: ref,
        collectionPath: _p.path,
        collectionId: _p.id,
        documentId: id,
        type: InAppWriteType.document,
      );
      if (r) {
        final remaining = await _db._r(
          reference: _p.ref,
          collectionPath: _p.path,
          collectionId: _p.id,
          documentId: _p.id,
          type: InAppReadType.collection,
        );
        if (remaining is InAppQuerySnapshot && remaining.isEmpty) {
          await _db._wInner(
            type: InAppWriteType.collection,
            reference: _p.ref,
            collectionPath: _p.path,
            collectionId: _p.id,
            documentId: _p.id,
          );
        }
      }
      return r;
    });
    _n<void>(null, null);
    _db._log(ok ? 'done!' : 'failed!', action: 'delete', field: id);
    if (!ok) {
      throw InAppDatabaseException(
        'Failed to delete document at "$path".',
        code: 'delete-failed',
      );
    }
  }

  Future<InAppDocumentSnapshot> get([
    InAppSource source = InAppSource.cache,
  ]) async {
    final result = await _db._r(
      reference: ref,
      collectionPath: _p.path,
      collectionId: _p.id,
      documentId: id,
      type: InAppReadType.document,
    );
    if (result is InAppDocumentSnapshot) {
      return result.copy(reference: this);
    }
    return InAppDocumentSnapshot(id, null, this);
  }

  Stream<InAppDocumentSnapshot> snapshots({
    bool includeMetadataChanges = false,
  }) {
    final n = _db._addChildNotifier(_p.path, id);
    return Stream<InAppDocumentSnapshot>.multi((controller) {
      InAppDocumentSnapshot? last;
      void emit(InAppDocumentSnapshot snap) {
        if (controller.isClosed) return;
        if (last == snap) return;
        last = snap;
        controller.add(snap);
      }

      void listener() => emit(n.value ?? InAppDocumentSnapshot(id, null, this));

      n.addListener(listener);
      controller.onCancel = () {
        n.removeListener(listener);
        _db._maybeCleanupChild(_p.path, id);
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
