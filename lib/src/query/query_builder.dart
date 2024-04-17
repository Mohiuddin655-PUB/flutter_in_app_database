part of 'query.dart';

class QueryBuilder {
  List<Map<String, dynamic>> _data;

  QueryBuilder(this._data);

  QueryBuilder where(
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
    _data = _data.where((doc) {
      final i = doc[field];
      if (isEqualTo != null && i == isEqualTo) {
        return true;
      } else if (isNotEqualTo != null && i != isNotEqualTo) {
        return true;
      } else if (isLessThan != null && i < isLessThan) {
        return true;
      } else if (isLessThanOrEqualTo != null && i <= isLessThanOrEqualTo) {
        return true;
      } else if (isGreaterThan != null && i > isGreaterThan) {
        return true;
      } else if (isGreaterThanOrEqualTo != null &&
          i >= isGreaterThanOrEqualTo) {
        return true;
      } else if (arrayContains != null &&
          i is Iterable &&
          i.contains(arrayContains)) {
        return true;
      } else if (arrayNotContains != null &&
          i is Iterable &&
          !i.contains(arrayNotContains)) {
        return true;
      } else if (arrayContainsAny != null &&
          i is Iterable &&
          i.any((e) => arrayContainsAny.contains(e))) {
        return true;
      } else if (arrayNotContainsAny != null &&
          i is Iterable &&
          !i.any((e) => arrayNotContainsAny.contains(e))) {
        return true;
      } else if (whereIn != null && whereIn.contains(i)) {
        return true;
      } else if (whereNotIn != null && whereNotIn.contains(i)) {
        return true;
      } else if (isNull != null && (i == null) == isNull) {
        return true;
      } else {
        return false;
      }
    }).toList();
    return QueryBuilder(List.from(_data));
  }

  QueryBuilder orderBy(Iterable<Sorting> fields) {
    _data.sort((a, b) {
      int i = 0;
      while (i < fields.length) {
        var sort = fields.elementAt(i);
        var field = sort.field;
        final x = a[field];
        final y = b[field];
        if (x != null && y != null) {
          var comparison = x.compareTo(y);
          if (comparison != 0) {
            return sort.descending ? -comparison : comparison;
          }
        } else {
          return 0;
        }
        i++;
      }
      return 0;
    });
    return this;
  }

  Future<List<Map<String, dynamic>>> get() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _data;
  }
}
