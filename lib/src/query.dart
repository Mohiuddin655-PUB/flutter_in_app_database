import 'dart:async';

import 'package:in_app_database/in_app_database.dart';
import 'package:in_app_query/in_app_query.dart';

import 'counter.dart';

class InAppQueryReference extends InAppCollectionReference {
  final List<Query> queries;
  final List<Selection> selections;
  final List<Sorting> sorts;
  final InAppPagingOptions options;
  final bool counterMode;

  const InAppQueryReference({
    required super.db,
    required super.reference,
    required super.collectionPath,
    required super.collectionId,
    this.queries = const [],
    this.selections = const [],
    this.sorts = const [],
    this.options = const InAppPagingOptions(),
    this.counterMode = false,
  });

  InAppCounterReference count() {
    return InAppCounterReference(
      db: db,
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      parent: this,
    );
  }

  InAppQueryReference _limit(int limit, [bool fetchFromLast = false]) {
    return InAppQueryReference(
      db: db,
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      queries: queries,
      selections: selections,
      sorts: sorts,
      options: options.copy(
        initialSize: limit,
        fetchingSize: limit,
        fetchFromLast: fetchFromLast,
      ),
      counterMode: counterMode,
    );
  }

  InAppQueryReference limit(int limit) => _limit(limit);

  InAppQueryReference limitToLast(int limit) => _limit(limit, true);

  InAppQueryReference orderBy(
    Object field, {
    bool descending = false,
  }) {
    if (field is String) {
      sorts.add(Sorting(field, descending: descending));
    }
    return InAppQueryReference(
      db: db,
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      queries: queries,
      selections: selections,
      sorts: sorts,
      options: options,
      counterMode: counterMode,
    );
  }

  InAppQueryReference _selection(Object? snapshot, Selections type) {
    if (snapshot is InAppDocument || snapshot is Iterable<InAppValue>) {
      selections.add(Selection.from(snapshot, type));
    }
    return InAppQueryReference(
      db: db,
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      queries: queries,
      selections: selections,
      sorts: sorts,
      options: options,
      counterMode: counterMode,
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
      db: db,
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      queries: queries,
      selections: selections,
      sorts: sorts,
      options: options,
      counterMode: counterMode,
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
  InAppQueryNotifier? get notifier => db.notifier("$collectionPath-query");

  T _n<T>(T value, [InAppQuerySnapshot? snapshot]) {
    if (notifier != null) {
      if (snapshot == null) {
        get().then((value) => notifier!.value = value);
      } else {
        notifier!.value = snapshot;
      }
    }
    return value;
  }

  @override
  void notify([InAppQuerySnapshot? snapshot]) => _n(null, snapshot);

  @override
  Future<InAppQuerySnapshot> get() {
    return super.get().then((raw) {
      final data = raw.docs.map((e) => e.data ?? {}).toList();
      QueryBuilder builder = QueryBuilder(data);
      if (queries.isNotEmpty) {
        for (var i in queries) {
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
      if (sorts.isNotEmpty) {
        for (var i in sorts) {
          builder = builder.orderBy(i.field, descending: i.descending);
        }
      }
      if (selections.isNotEmpty) {
        for (var i in selections) {
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
      final fetchingSize = options.fetchingSize;
      if (fetchingSize != null && fetchingSize > 0) {
        if (options.fetchFromLast) {
          builder = builder.limitToLast(fetchingSize);
        } else {
          builder = builder.limit(fetchingSize);
        }
      }
      return builder.execute().then((processed) {
        final docs = processed.map((e) {
          return InAppDocumentSnapshot(id, e);
        }).toList();
        return InAppQuerySnapshot(raw.id, docs);
      });
    });
  }

  @override
  Stream<InAppQuerySnapshot> snapshots() {
    final controller = StreamController<InAppQuerySnapshot>();
    db.setNotifier("$collectionPath-query");
    notifier?.addListener(() {
      controller.add(notifier?.value ?? InAppQuerySnapshot(collectionId));
    });
    _n(null);
    return controller.stream;
  }
}
