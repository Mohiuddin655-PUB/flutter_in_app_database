part of 'query.dart';

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
