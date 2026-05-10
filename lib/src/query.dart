part of 'database.dart';

class InAppQueryReference extends InAppCollectionReference {
  final List<Query> _q;
  final List<Selection> _s;
  final List<Sorting> _o;
  final InAppPagingOptions _op;

  const InAppQueryReference({
    required super.db,
    required super.ref,
    required super.path,
    required super.id,
    super.parent,
    List<Query> queries = const [],
    List<Selection> selections = const [],
    List<Sorting> sorts = const [],
    InAppPagingOptions options = const InAppPagingOptions(),
  })  : _q = queries,
        _s = selections,
        _o = sorts,
        _op = options;

  InAppQueryReference _copyWith({
    List<Query>? queries,
    List<Selection>? selections,
    List<Sorting>? sorts,
    InAppPagingOptions? options,
  }) {
    return InAppQueryReference(
      db: _db,
      ref: ref,
      path: path,
      id: id,
      parent: _parent,
      queries: queries ?? _q,
      selections: selections ?? _s,
      sorts: sorts ?? _o,
      options: options ?? _op,
    );
  }

  InAppAggregateQuery count() {
    return InAppAggregateQuery(db: _db, ref: ref, parent: this);
  }

  InAppQueryReference _limit(int limit, [bool fetchFromLast = false]) {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'must be > 0');
    }
    return _copyWith(
      options: _op.copy(
        initialSize: limit,
        fetchingSize: limit,
        fetchFromLast: fetchFromLast,
      ),
    );
  }

  InAppQueryReference limit(int limit) => _limit(limit);

  InAppQueryReference limitToLast(int limit) => _limit(limit, true);

  InAppQueryReference orderBy(Object field, {bool descending = false}) {
    final fieldKey = _resolveField(field);
    if (fieldKey == null || fieldKey.isEmpty) return this;
    final sorts = List<Sorting>.of(_o)
      ..add(Sorting(fieldKey, descending: descending));
    return _copyWith(sorts: sorts);
  }

  String? _resolveField(Object field) {
    if (field is String) return field;
    if (field is InAppFieldPath) {
      if (field.isDocumentId) return _idField;
      return field.segments.join('.');
    }
    return null;
  }

  InAppQueryReference _selection(Object? snapshot, Selections type) {
    Object? value = snapshot;
    if (snapshot is InAppDocumentSnapshot) {
      value = snapshot.data();
    }
    if (value is! InAppDocument && value is! Iterable<InAppValue>) {
      return this;
    }
    final selections = List<Selection>.of(_s)..add(Selection.from(value, type));
    return _copyWith(selections: selections);
  }

  InAppQueryReference where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Object? arrayNotContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? arrayNotContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    final fieldKey = _resolveField(field) ?? '';
    final queries = List<Query>.of(_q)
      ..add(
        Query(
          fieldKey,
          isEqualTo: isEqualTo,
          isNotEqualTo: isNotEqualTo,
          isLessThan: isLessThan,
          isLessThanOrEqualTo: isLessThanOrEqualTo,
          isGreaterThan: isGreaterThan,
          isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
          arrayContains: arrayContains,
          arrayNotContains: arrayNotContains,
          arrayContainsAny: arrayContainsAny,
          arrayNotContainsAny: arrayNotContainsAny,
          whereIn: whereIn,
          whereNotIn: whereNotIn,
          isNull: isNull,
        ),
      );
    return _copyWith(queries: queries);
  }

  InAppQueryReference endAtDocument(Object? snapshot) =>
      _selection(snapshot, Selections.endAtDocument);

  InAppQueryReference endAt(Iterable<InAppValue>? values) =>
      _selection(values, Selections.endAt);

  InAppQueryReference endBeforeDocument(Object? snapshot) =>
      _selection(snapshot, Selections.endBeforeDocument);

  InAppQueryReference endBefore(Iterable<InAppValue>? values) =>
      _selection(values, Selections.endBefore);

  InAppQueryReference startAfterDocument(Object? snapshot) =>
      _selection(snapshot, Selections.startAfterDocument);

  InAppQueryReference startAfter(Iterable<InAppValue>? values) =>
      _selection(values, Selections.startAfter);

  InAppQueryReference startAtDocument(Object? snapshot) =>
      _selection(snapshot, Selections.startAtDocument);

  InAppQueryReference startAt(Iterable<InAppValue>? values) =>
      _selection(values, Selections.startAt);

  bool get _hasPipeline =>
      _q.isNotEmpty || _o.isNotEmpty || _s.isNotEmpty || _op.hasLimit;

  @override
  Future<InAppQuerySnapshot> get([
    InAppSource source = InAppSource.cache,
  ]) async {
    if (!_hasPipeline) return super.get(source);

    final raw = await super.get(source);
    final data = raw.docs.map((e) => e.data()).toList(growable: false);

    QueryBuilder builder = QueryBuilder(data);

    for (final q in _q) {
      builder = builder.where(
        q.field,
        isEqualTo: q.isEqualTo,
        isNotEqualTo: q.isNotEqualTo,
        isNull: q.isNull,
        isGreaterThan: q.isGreaterThan,
        isGreaterThanOrEqualTo: q.isGreaterThanOrEqualTo,
        isLessThan: q.isLessThan,
        isLessThanOrEqualTo: q.isLessThanOrEqualTo,
        whereIn: q.whereIn,
        whereNotIn: q.whereNotIn,
        arrayContains: q.arrayContains,
        arrayNotContains: q.arrayNotContains,
        arrayContainsAny: q.arrayContainsAny,
        arrayNotContainsAny: q.arrayNotContainsAny,
      );
    }

    for (final s in _o) {
      builder = builder.orderBy(s.field, descending: s.descending);
    }

    for (final sel in _s) {
      final v = sel.value;
      final vs = sel.values;
      if (v is! Map<String, dynamic> && vs is! Iterable<Object?>) continue;
      final mapValue =
          v is Map<String, dynamic> ? v : const <String, dynamic>{};
      final listValues = vs == null ? const <Object?>[] : List<Object?>.of(vs);
      switch (sel.type) {
        case Selections.endAt:
          builder = builder.endAt(listValues);
          break;
        case Selections.endAtDocument:
          builder = builder.endAtDocument(mapValue);
          break;
        case Selections.endBefore:
          builder = builder.endBefore(listValues);
          break;
        case Selections.endBeforeDocument:
          builder = builder.endBeforeDocument(mapValue);
          break;
        case Selections.startAfter:
          builder = builder.startAfter(listValues);
          break;
        case Selections.startAfterDocument:
          builder = builder.startAfterDocument(mapValue);
          break;
        case Selections.startAt:
          builder = builder.startAt(listValues);
          break;
        case Selections.startAtDocument:
          builder = builder.startAtDocument(mapValue);
          break;
        case Selections.none:
          break;
      }
    }

    if (_op.hasLimit) {
      final size = _op.fetchingSize!;
      builder =
          _op.fetchFromLast ? builder.limitToLast(size) : builder.limit(size);
    }

    final processed = await builder.execute();
    final docs = <InAppQueryDocumentSnapshot>[];
    for (final e in processed) {
      final i = e[_idField] ?? e[_idFieldSecondary];
      final docId = i is String && i.isNotEmpty ? i : _id;
      docs.add(InAppQueryDocumentSnapshot(docId, e, doc(docId)));
    }
    return InAppQuerySnapshot(raw.id, docs, raw.docChanges, raw.metadata);
  }

  @override
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

      void listener() {
        get().then((s) {
          if (!controller.isClosed) emit(s);
        }).catchError((_) {});
      }

      n.addListener(listener);
      controller.onCancel = () {
        n.removeListener(listener);
        _db._maybeCleanupNotifier(path);
      };

      Future<void>(() async {
        try {
          final s = await get();
          if (!controller.isClosed) emit(s);
        } catch (_) {}
      });
    });
  }
}
