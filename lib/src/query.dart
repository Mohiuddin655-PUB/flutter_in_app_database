part of 'database.dart';

class InAppQueryReference extends InAppCollectionReference {
  final List<Query> _q;
  final List<Selection> _s;
  final List<Sorting> _o;
  final InAppPagingOptions _op;
  final bool _cm;

  const InAppQueryReference({
    required super.db,
    required super.reference,
    required super.path,
    required super.id,
    List<Query> queries = const [],
    List<Selection> selections = const [],
    List<Sorting> sorts = const [],
    InAppPagingOptions options = const InAppPagingOptions(),
    bool counterMode = false,
  })  : _q = queries,
        _s = selections,
        _o = sorts,
        _op = options,
        _cm = counterMode;

  InAppCounterReference count() {
    return InAppCounterReference(
      db: _db,
      reference: reference,
      parent: this,
    );
  }

  InAppQueryReference _limit(int limit, [bool fetchFromLast = false]) {
    return InAppQueryReference(
      db: _db,
      reference: reference,
      path: path,
      id: id,
      queries: _q,
      selections: _s,
      sorts: _o,
      options: _op.copy(
        initialSize: limit,
        fetchingSize: limit,
        fetchFromLast: fetchFromLast,
      ),
      counterMode: _cm,
    );
  }

  InAppQueryReference limit(int limit) => _limit(limit);

  InAppQueryReference limitToLast(int limit) => _limit(limit, true);

  InAppQueryReference orderBy(
    Object field, {
    bool descending = false,
  }) {
    List<Sorting> sorts = List.from(_o);
    if (field is String) {
      sorts.add(Sorting(field, descending: descending));
    }
    return InAppQueryReference(
      db: _db,
      reference: reference,
      path: path,
      id: id,
      queries: _q,
      selections: _s,
      sorts: sorts,
      options: _op,
      counterMode: _cm,
    );
  }

  InAppQueryReference _selection(Object? snapshot, Selections type) {
    List<Selection> selections = List.from(_s);
    if (snapshot is InAppDocument || snapshot is Iterable<InAppValue>) {
      selections.add(Selection.from(snapshot, type));
    }
    return InAppQueryReference(
      db: _db,
      reference: reference,
      path: path,
      id: id,
      queries: _q,
      selections: selections,
      sorts: _o,
      options: _op,
      counterMode: _cm,
    );
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
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    List<Query> queries = List.from(_q);
    queries.add(Query(
      field,
      isEqualTo: isEqualTo,
      isNotEqualTo: isNotEqualTo,
      isLessThan: isLessThan,
      isLessThanOrEqualTo: isLessThanOrEqualTo,
      isGreaterThan: isGreaterThan,
      isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
      arrayContains: arrayContains,
      arrayContainsAny: arrayContainsAny,
      whereIn: whereIn,
      whereNotIn: whereNotIn,
      isNull: isNull,
    ));
    return InAppQueryReference(
      db: _db,
      reference: reference,
      path: path,
      id: id,
      queries: queries,
      selections: _s,
      sorts: _o,
      options: _op,
      counterMode: _cm,
    );
  }

  InAppQueryReference endAtDocument(InAppValue? snapshot) {
    return _selection(snapshot, Selections.endAtDocument);
  }

  InAppQueryReference endAt(Iterable<InAppValue>? values) {
    return _selection(values, Selections.endAt);
  }

  InAppQueryReference endBeforeDocument(InAppValue? snapshot) {
    return _selection(snapshot, Selections.endBeforeDocument);
  }

  InAppQueryReference endBefore(Iterable<InAppValue>? values) {
    return _selection(values, Selections.endBefore);
  }

  InAppQueryReference startAfterDocument(InAppValue? snapshot) {
    return _selection(snapshot, Selections.startAfterDocument);
  }

  InAppQueryReference startAfter(Iterable<InAppValue>? values) {
    return _selection(values, Selections.startAfter);
  }

  InAppQueryReference startAtDocument(InAppValue? snapshot) {
    return _selection(snapshot, Selections.startAfterDocument);
  }

  InAppQueryReference startAt(Iterable<InAppValue>? values) {
    return _selection(values, Selections.startAt);
  }

  @override
  Future<InAppQuerySnapshot> get() {
    final fetchingSize = _op.fetchingSize ?? 0;
    final isQuery = _q.isNotEmpty;
    final isSorting = _o.isNotEmpty;
    final isSelections = _s.isNotEmpty;
    final isLimit = fetchingSize > 0;
    final sortingSize = _o.length;
    if (isQuery || isSorting || isSelections || isLimit) {
      return super.get().then((raw) {
        final data = raw.docs.map((e) => e.data ?? {}).toList();
        QueryBuilder builder = QueryBuilder(data);
        if (isQuery) {
          for (var i in _q) {
            builder = builder.where(
              i.field,
              isEqualTo: i.isEqualTo,
              isNotEqualTo: i.isNotEqualTo,
              isNull: i.isNull,
              isGreaterThan: i.isGreaterThan,
              isGreaterThanOrEqualTo: i.isGreaterThanOrEqualTo,
              isLessThan: i.isLessThan,
              isLessThanOrEqualTo: i.isLessThanOrEqualTo,
              whereIn: i.whereIn,
              whereNotIn: i.whereNotIn,
              arrayContains: i.arrayContains,
              arrayNotContains: i.arrayNotContains,
              arrayContainsAny: i.arrayContainsAny,
              arrayNotContainsAny: i.arrayNotContainsAny,
            );
          }
        }
        if (isSorting) {
          for (var i in _o) {
            builder = builder.orderBy(i.field, descending: i.descending);
          }
        }
        if (isSelections) {
          for (var i in _s) {
            final v = i.value;
            final vs = i.values;
            if (v is Map<String, dynamic> || vs is Iterable<Object?>) {
              final value = v is Map<String, dynamic> ? v : <String, dynamic>{};
              final values = List.from(vs ?? []);
              switch (i.type) {
                case Selections.endAt:
                  builder = builder.endAt(values);
                  break;
                case Selections.endAtDocument:
                  builder = builder.endAtDocument(value);
                  break;
                case Selections.endBefore:
                  builder = builder.endBefore(values);
                  break;
                case Selections.endBeforeDocument:
                  builder = builder.endBeforeDocument(value);
                  break;
                case Selections.startAfter:
                  builder = builder.startAfter(values);
                  break;
                case Selections.startAfterDocument:
                  builder = builder.startAfterDocument(value);
                  break;
                case Selections.startAt:
                  builder = builder.startAt(values);
                  break;
                case Selections.startAtDocument:
                  builder = builder.startAtDocument(value);
                  break;
                case Selections.none:
                  break;
              }
            }
          }
        }
        if (isLimit) {
          if (_op.fetchFromLast) {
            builder = builder.limitToLast(fetchingSize);
          } else {
            builder = builder.limit(fetchingSize);
          }
        }
        return builder
            .execute(isSorting ? sortingSize * data.length : 0)
            .then((processed) {
          final docs = processed.map((e) {
            return InAppDocumentSnapshot(_id, e);
          }).toList();
          return InAppQuerySnapshot(raw.id, docs);
        });
      });
    } else {
      return super.get();
    }
  }

  @override
  Stream<InAppQuerySnapshot> snapshots() {
    final c = StreamController<InAppQuerySnapshot>();
    final n = _db._addNotifier(path);
    n.addListener(() => get().then(c.add));
    Future.delayed(const Duration(seconds: 1)).whenComplete(_notify);
    return c.stream;
  }
}
