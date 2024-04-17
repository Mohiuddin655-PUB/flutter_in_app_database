part of 'query.dart';

class Filter {
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

  const Filter(
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

  static Filter and(
    Filter filter1,
    Filter filter2, [
    Filter? filter3,
    Filter? filter4,
    Filter? filter5,
    Filter? filter6,
    Filter? filter7,
    Filter? filter8,
    Filter? filter9,
    Filter? filter10,
    Filter? filter11,
    Filter? filter12,
    Filter? filter13,
    Filter? filter14,
    Filter? filter15,
    Filter? filter16,
    Filter? filter17,
    Filter? filter18,
    Filter? filter19,
    Filter? filter20,
    Filter? filter21,
    Filter? filter22,
    Filter? filter23,
    Filter? filter24,
    Filter? filter25,
    Filter? filter26,
    Filter? filter27,
    Filter? filter28,
    Filter? filter29,
    Filter? filter30,
  ]) {
    return Filter.and(
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

  static Filter or(
    Filter filter1,
    Filter filter2, [
    Filter? filter3,
    Filter? filter4,
    Filter? filter5,
    Filter? filter6,
    Filter? filter7,
    Filter? filter8,
    Filter? filter9,
    Filter? filter10,
    Filter? filter11,
    Filter? filter12,
    Filter? filter13,
    Filter? filter14,
    Filter? filter15,
    Filter? filter16,
    Filter? filter17,
    Filter? filter18,
    Filter? filter19,
    Filter? filter20,
    Filter? filter21,
    Filter? filter22,
    Filter? filter23,
    Filter? filter24,
    Filter? filter25,
    Filter? filter26,
    Filter? filter27,
    Filter? filter28,
    Filter? filter29,
    Filter? filter30,
  ]) {
    return Filter.or(
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
