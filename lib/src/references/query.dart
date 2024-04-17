part of 'base.dart';

typedef InAppQuerySnapshotNotifier = StreamController<InAppQuerySnapshot?>;

class InAppQueryReference extends InAppCollectionReference {
  final List<InAppQuery> queries;
  final List<Selection> selections;
  final List<DataSorting> sorts;
  final PagingOptions options;
  final bool counterMode;

  const InAppQueryReference({
    required super.db,
    required super.reference,
    required super.collectionPath,
    required super.collectionId,
    this.queries = const [],
    this.selections = const [],
    this.sorts = const [],
    this.options = const PagingOptions(),
    this.counterMode = false,
  });

  InAppQueryReference count() {
    return InAppQueryReference(
      db: db,
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      queries: queries,
      selections: selections,
      sorts: sorts,
      options: options,
      counterMode: true,
    );
  }

  InAppQueryReference limit(int limit, bool fetchFromLast) {
    return InAppQueryReference(
      db: db,
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      queries: queries,
      selections: selections,
      sorts: sorts,
      options: options.copy(
        initialFetchingSize: limit,
        fetchingSize: limit,
        fetchFromLast: fetchFromLast,
      ),
      counterMode: counterMode,
    );
  }

  InAppQueryReference orderBy(
    Object field, {
    bool descending = true,
  }) {
    if (field is String) {
      sorts.add(DataSorting(field, descending));
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

  InAppQueryReference _selection(Object? snapshot, SelectionType type) {
    if (snapshot is InAppDocument || snapshot is Iterable<InAppValue>) {
      selections.add(Selection(snapshot, type));
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
    queries.add(InAppQuery(
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
    return _selection(snapshot, SelectionType.endAtDocument);
  }

  InAppQueryReference endAt(Iterable<InAppValue>? values) {
    return _selection(values, SelectionType.endAt);
  }

  InAppQueryReference endBeforeDocument(InAppValue? snapshot) {
    return _selection(snapshot, SelectionType.endBeforeDocument);
  }

  InAppQueryReference endBefore(Iterable<InAppValue>? values) {
    return _selection(values, SelectionType.endBefore);
  }

  InAppQueryReference startAfterDocument(InAppValue? snapshot) {
    return _selection(snapshot, SelectionType.startAfterDocument);
  }

  InAppQueryReference startAfter(Iterable<InAppValue>? values) {
    return _selection(values, SelectionType.startAfter);
  }

  InAppQueryReference startAtDocument(InAppValue? snapshot) {
    return _selection(snapshot, SelectionType.startAfterDocument);
  }

  InAppQueryReference startAt(Iterable<InAppValue>? values) {
    return _selection(values, SelectionType.startAt);
  }
}
