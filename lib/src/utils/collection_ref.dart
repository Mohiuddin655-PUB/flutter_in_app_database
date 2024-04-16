import 'dart:async';

import '../external/configs.dart';
import 'query.dart';

typedef InAppDocument = Map<String, dynamic>;
typedef InAppValue = Object?;

abstract class InAppReference {
  final String reference;
  final Map<String, dynamic> database;

  const InAppReference(
    this.database,
    this.reference,
  );

  String get id => DateTime.now().millisecondsSinceEpoch.toString();

  InAppCollectionReference ref(String field) {
    return InAppCollectionReference(database, field);
  }
}

class InAppDocumentReference extends InAppReference {
  const InAppDocumentReference(super.database, super.reference);

  InAppCollectionReference collection(String field) {
    return InAppCollectionReference(database, "$reference/$field");
  }

  Future<InAppDocumentSnapshot> set(
    InAppDocument data, [
    InAppSetOptions options = const InAppSetOptions(),
  ]) {
    if (options.merge) {
      return update(data);
    } else {
      database[reference] = data;
      return get();
    }
  }

  Future<InAppDocumentSnapshot> update(InAppDocument data) {
    return get().then((value) {
      final current = (value.data ?? {})..addAll(data);
      database[reference] = current;
      return get();
    });
  }

  Future<InAppDocumentSnapshot> delete() {
    database.remove(reference);
    return get();
  }

  Future<InAppDocumentSnapshot> get() async {
    final data = database[reference];
    if (data is InAppDocument) {
      return InAppDocumentSnapshot(reference, data);
    } else {
      return InAppDocumentSnapshot(reference, null);
    }
  }

  Stream<InAppDocumentSnapshot> snapshots() {
    final controller = StreamController<InAppDocumentSnapshot>();
    final data = database[reference];
    if (data is InAppDocument) {
      controller.add(InAppDocumentSnapshot(reference, data));
    } else {
      controller.add(InAppDocumentSnapshot(reference, null));
    }
    return controller.stream;
  }
}

class InAppQueryReference extends InAppReference {
  final List<Query> queries;
  final List<Selection> selections;
  final List<DataSorting> sorts;
  final PagingOptions options;
  final bool counterMode;

  const InAppQueryReference(
    super.database,
    super.reference, [
    this.queries = const [],
    this.selections = const [],
    this.sorts = const [],
    this.options = const PagingOptions(),
    this.counterMode = false,
  ]);

  InAppQueryReference count() {
    return InAppQueryReference(
      database,
      reference,
      queries,
      selections,
      sorts,
      options,
      true,
    );
  }

  InAppQueryReference limit(int limit, bool fetchFromLast) {
    return InAppQueryReference(
      database,
      reference,
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
      database,
      reference,
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
      database,
      reference,
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
      database,
      reference,
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

  Future<InAppQuerySnapshot> get() async {
    final data = database[reference];
    if (data is List<InAppDocument>) {
      final x = data.map((e) => InAppDocumentSnapshot(reference, e)).toList();
      return InAppQuerySnapshot(reference, x);
    } else {
      return InAppQuerySnapshot(reference, []);
    }
  }

  Stream<InAppQuerySnapshot> snapshots() {
    final controller = StreamController<InAppQuerySnapshot>();
    final data = database[reference];
    if (data is List<InAppDocument>) {
      final x = data.map((e) => InAppDocumentSnapshot(reference, e)).toList();
      controller.add(InAppQuerySnapshot(reference, x));
    } else {
      controller.add(InAppQuerySnapshot(reference, []));
    }
    return controller.stream;
  }
}

class InAppCollectionReference extends InAppQueryReference {
  const InAppCollectionReference(super.database, super.reference);

  InAppDocumentReference doc(String field) {
    return InAppDocumentReference(database, "$reference/$field");
  }

  Future<InAppDocumentSnapshot> add(InAppDocument data) {
    return doc(id).set(data);
  }

  Future<InAppQuerySnapshot> set(List<InAppDocument> data) {
    database[reference] = data;
    return get();
  }

  Future<InAppQuerySnapshot> delete() {
    database.remove(reference);
    return get();
  }
}

class InAppSetOptions {
  final bool merge;

  const InAppSetOptions({
    this.merge = true,
  });
}

class InAppDocumentSnapshot {
  final String path;
  final InAppDocument? _doc;

  InAppDocument? get data => _doc;

  bool get exists => _doc != null && _doc!.isNotEmpty;

  String get id => path.split("/").where((i) => i.isNotEmpty).last;

  const InAppDocumentSnapshot(
    this.path,
    this._doc,
  );
}

class InAppQuerySnapshot {
  final String path;
  final List<InAppDocumentSnapshot> docs;
  final List<InAppDocumentChange> docChanges;

  bool get exists => docs.isNotEmpty;

  const InAppQuerySnapshot(
    this.path,
    this.docs, [
    this.docChanges = const [],
  ]);
}

class InAppDocumentChange {
  final InAppDocumentSnapshot doc;

  const InAppDocumentChange({
    required this.doc,
  });
}
