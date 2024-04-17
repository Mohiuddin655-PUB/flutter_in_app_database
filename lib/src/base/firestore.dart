import 'package:in_app_database/src/base/test.dart';

class Firestore {
  List<Map<String, dynamic>> _collection;

  Firestore(this._collection);

  FirestoreQuery collection(String collectionName) {
    return FirestoreQuery(_collection);
  }
}

class FirestoreQuery {
  List<Map<String, dynamic>> _data;

  FirestoreQuery(this._data);

  FirestoreQuery where(
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
    return FirestoreQuery(List.from(_data));
  }

  FirestoreQuery orderBy(String field, {bool descending = false}) {
    _data.sort((a, b) {
      var comparison = a[field].compareTo(b[field]);
      return descending ? -comparison : comparison;
    });
    return this;
  }

  FirestoreQuery orderByIterable(Iterable<Sorting> fields) {
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
    return FirestoreQuery(List.from(_data));
  }

  FirestoreQuery startAt(List<dynamic> values) {
    _data = _data.where((doc) {
      for (int i = 0; i < values.length; i++) {
        if (doc.values.elementAt(i).compareTo(values[i]) < 0) {
          return false;
        }
        if (doc.values.elementAt(i).compareTo(values[i]) > 0) {
          return true;
        }
      }
      return true;
    }).toList();
    return FirestoreQuery(List.from(_data));
  }

  FirestoreQuery startAfter(List<dynamic> values) {
    _data = _data.where((doc) {
      for (int i = 0; i < values.length; i++) {
        if (doc.values.elementAt(i).compareTo(values[i]) <= 0) {
          return false;
        }
      }
      return true;
    }).toList();
    return FirestoreQuery(List.from(_data));
  }

  FirestoreQuery startAfterDocument(Map<String, dynamic> document) {
    _data = _data.skipWhile((doc) {
      for (int i = 0; i < doc.length; i++) {
        var field = doc.keys.elementAt(i);
        if (doc[field].compareTo(document[field]) <= 0) {
          return true;
        }
        if (doc[field].compareTo(document[field]) > 0) {
          return false;
        }
      }
      return false;
    }).toList();
    return FirestoreQuery(List.from(_data));
  }

  FirestoreQuery endAt(List<dynamic> values) {
    _data = _data.where((doc) {
      for (int i = 0; i < values.length; i++) {
        if (doc.values.elementAt(i).compareTo(values[i]) > 0) {
          return false;
        }
        if (doc.values.elementAt(i).compareTo(values[i]) < 0) {
          return true;
        }
      }
      return true;
    }).toList();
    return FirestoreQuery(List.from(_data));
  }

  FirestoreQuery endBefore(List<dynamic> values) {
    _data = _data.where((doc) {
      for (int i = 0; i < values.length; i++) {
        if (doc.values.elementAt(i).compareTo(values[i]) >= 0) {
          return false;
        }
      }
      return true;
    }).toList();
    return FirestoreQuery(List.from(_data));
  }

  FirestoreQuery endBeforeDocument(Map<String, dynamic> document) {
    _data = _data.takeWhile((doc) {
      for (int i = 0; i < doc.length; i++) {
        var field = doc.keys.elementAt(i);
        var fieldValue = doc[field];
        var documentValue = document[field];
        if (fieldValue.compareTo(documentValue) < 0) {
          return true;
        }
        if (fieldValue.compareTo(documentValue) > 0) {
          return false;
        }
      }
      return false;
    }).toList();
    return FirestoreQuery(List.from(_data));
  }

  FirestoreQuery limit(int limit) {
    _data = _data.take(limit).toList();
    return FirestoreQuery(List.from(_data));
  }

  Future<List<Map<String, dynamic>>> get() {
    return Future.delayed(const Duration(milliseconds: 100)).then((_) => _data);
  }
}
