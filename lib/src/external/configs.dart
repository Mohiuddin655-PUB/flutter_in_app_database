typedef Snapshot = Object;

class PagingOptions {
  final bool fetchFromLast;
  final int? fetchingSize;
  final int? initialFetchingSize;

  const PagingOptions({
    int? initialFetchSize,
    this.fetchFromLast = false,
    this.fetchingSize,
  }) : initialFetchingSize = initialFetchSize ?? fetchingSize;

  PagingOptions copy({
    bool? fetchFromLast,
    int? fetchingSize,
    int? initialFetchingSize,
  }) {
    return PagingOptions(
      initialFetchSize: initialFetchingSize ?? this.initialFetchingSize,
      fetchingSize: fetchingSize ?? this.fetchingSize,
      fetchFromLast: fetchFromLast ?? this.fetchFromLast,
    );
  }
}

class PagingOptionsImpl extends PagingOptions {
  const PagingOptionsImpl();
}

class DataFilter {
  final Object field;
  final Object? isEqualTo;
  final Object? isNotEqualTo;
  final Object? isLessThan;
  final Object? isLessThanOrEqualTo;
  final Object? isGreaterThan;
  final Object? isGreaterThanOrEqualTo;
  final Object? arrayContains;
  final Iterable<Object?>? arrayContainsAny;
  final Iterable<Object?>? whereIn;
  final Iterable<Object?>? whereNotIn;
  final bool? isNull;

  const DataFilter(
    this.field, {
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
  });

  static DataFilter and(
    DataFilter filter1,
    DataFilter filter2, [
    DataFilter? filter3,
    DataFilter? filter4,
    DataFilter? filter5,
    DataFilter? filter6,
    DataFilter? filter7,
    DataFilter? filter8,
    DataFilter? filter9,
    DataFilter? filter10,
    DataFilter? filter11,
    DataFilter? filter12,
    DataFilter? filter13,
    DataFilter? filter14,
    DataFilter? filter15,
    DataFilter? filter16,
    DataFilter? filter17,
    DataFilter? filter18,
    DataFilter? filter19,
    DataFilter? filter20,
    DataFilter? filter21,
    DataFilter? filter22,
    DataFilter? filter23,
    DataFilter? filter24,
    DataFilter? filter25,
    DataFilter? filter26,
    DataFilter? filter27,
    DataFilter? filter28,
    DataFilter? filter29,
    DataFilter? filter30,
  ]) {
    return DataFilter.and(
      filter1,
      filter2,
      filter3,
      filter4,
      filter5,
      filter6,
      filter7,
      filter8,
      filter9,
      filter10,
      filter11,
      filter12,
      filter13,
      filter14,
      filter15,
      filter16,
      filter17,
      filter18,
      filter19,
      filter20,
      filter21,
      filter22,
      filter23,
      filter24,
      filter25,
      filter26,
      filter27,
      filter28,
      filter29,
      filter30,
    );
  }

  static DataFilter or(
    DataFilter filter1,
    DataFilter filter2, [
    DataFilter? filter3,
    DataFilter? filter4,
    DataFilter? filter5,
    DataFilter? filter6,
    DataFilter? filter7,
    DataFilter? filter8,
    DataFilter? filter9,
    DataFilter? filter10,
    DataFilter? filter11,
    DataFilter? filter12,
    DataFilter? filter13,
    DataFilter? filter14,
    DataFilter? filter15,
    DataFilter? filter16,
    DataFilter? filter17,
    DataFilter? filter18,
    DataFilter? filter19,
    DataFilter? filter20,
    DataFilter? filter21,
    DataFilter? filter22,
    DataFilter? filter23,
    DataFilter? filter24,
    DataFilter? filter25,
    DataFilter? filter26,
    DataFilter? filter27,
    DataFilter? filter28,
    DataFilter? filter29,
    DataFilter? filter30,
  ]) {
    return DataFilter.or(
      filter1,
      filter2,
      filter3,
      filter4,
      filter5,
      filter6,
      filter7,
      filter8,
      filter9,
      filter10,
      filter11,
      filter12,
      filter13,
      filter14,
      filter15,
      filter16,
      filter17,
      filter18,
      filter19,
      filter20,
      filter21,
      filter22,
      filter23,
      filter24,
      filter25,
      filter26,
      filter27,
      filter28,
      filter29,
      filter30,
    );
  }
}

/// You can use like
/// * [ApiSorting]
/// * [FirestoreSorting]
/// * [LocalstoreSorting]
/// * [RealtimeSorting]
class DataSorting {
  final String field;
  final bool descending;

  const DataSorting(
    this.field, [
    this.descending = true,
  ]);
}

/// You can use like
/// * [ApiQuery]
/// * [FirestoreQuery]
/// * [LocalstoreQuery]
/// * [RealtimeQuery]
class Query {
  final Object? field;

  const Query([this.field]);
}

/// You can use like
/// * [ApiSelection]
/// * [FirestoreSelection]
/// * [LocalstoreSelection]
/// * [RealtimeSelection]
class Selection {
  final SelectionType type;
  final Object? value;

  const Selection(
    this.value, [
    this.type = SelectionType.none,
  ]);
}

enum SelectionType {
  endAt,
  endAtDocument,
  endBefore,
  endBeforeDocument,
  startAfter,
  startAfterDocument,
  startAt,
  startAtDocument,
  none;

  bool get isNone => this == none;

  bool get isEndAt => this == endAt;

  bool get isEndAtDocument => this == endAtDocument;

  bool get isEndBefore => this == endBefore;

  bool get isEndBeforeDocument => this == endBeforeDocument;

  bool get isStartAfter => this == startAfter;

  bool get isStartAfterDocument => this == startAfterDocument;

  bool get isStartAt => this == startAt;

  bool get isStartAtDocument => this == startAtDocument;
}

/// You can use like
/// * [Params]
/// * [IterableParams]
abstract class FieldParams {
  const FieldParams();
}

/// Replaces placeholders in the given [path] using the provided [params] map.
///
/// Example:
/// ```dart
/// FieldParams params = Params({'param1': 'value1', 'param2': 'value2'});     // Params: param1 = value1, param2 = value2
/// String root = "/path/{param1}/endpoint/{param2}";                          // Input : /path/{param1}/endpoint/{param2}
/// String path = params.generate(root);                                       // Output: /path/value1/endpoint/value2
/// ```
class Params extends FieldParams {
  final Map<String, String> values;

  const Params(this.values);
}

/// Replaces placeholders in the given [path] using values from the [params] iterable.
///
/// Example:
/// ```dart
/// FieldParams params = IterableParams(['value1', 'value2']);     // Params: param1 = value1, param2 = value2
/// String root = "/path/{param1}/endpoint/{param2}";              // Input : /path/{param1}/endpoint/{param2}
/// String path = params.generate(root);                           // Output: /path/value1/endpoint/value2
/// ```
class IterableParams extends FieldParams {
  final List<String> values;

  const IterableParams(this.values);
}
