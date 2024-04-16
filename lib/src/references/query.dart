part of 'base.dart';

class InAppQueryReference extends InAppReference {
  final List<InAppQuery> queries;
  final List<Selection> selections;
  final List<DataSorting> sorts;
  final PagingOptions options;
  final bool counterMode;

  const InAppQueryReference(
    super.base,
    super.reference, [
    this.queries = const [],
    this.selections = const [],
    this.sorts = const [],
    this.options = const PagingOptions(),
    this.counterMode = false,
  ]);

  InAppQueryReference count() {
    return InAppQueryReference(
      reference,
      instance,
      queries,
      selections,
      sorts,
      options,
      true,
    );
  }

  InAppQueryReference limit(int limit, bool fetchFromLast) {
    return InAppQueryReference(
      reference,
      instance,
      queries,
      selections,
      sorts,
      options.copy(
        initialFetchingSize: limit,
        fetchingSize: limit,
        fetchFromLast: fetchFromLast,
      ),
      counterMode,
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
      reference,
      instance,
      queries,
      selections,
      sorts,
      options,
      counterMode,
    );
  }

  InAppQueryReference _selection(Object? snapshot, SelectionType type) {
    if (snapshot is InAppDocument || snapshot is Iterable<InAppValue>) {
      selections.add(Selection(snapshot, type));
    }
    return InAppQueryReference(
      reference,
      instance,
      queries,
      selections,
      sorts,
      options,
      counterMode,
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
      reference,
      instance,
      queries,
      selections,
      sorts,
      options,
      counterMode,
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

  Future<InAppQuerySnapshot> get() {
    return _r(reference).then((data) {
      return InAppQuerySnapshot(
        reference,
        List.generate(data.entries.length, (index) {
          final item = data.entries.elementAt(index);
          return InAppDocumentSnapshot(item.key, item.value);
        }),
      );
    });
  }

  Stream<InAppQuerySnapshot> snapshots() {
    final controller = StreamController<InAppQuerySnapshot>();
    final data = instance.collections[reference];
    if (data is List<InAppDocument>) {
      final x = data.map((e) => InAppDocumentSnapshot(reference, e)).toList();
      controller.add(InAppQuerySnapshot(reference, x));
    } else {
      controller.add(InAppQuerySnapshot(reference, []));
    }
    return controller.stream;
  }
}
