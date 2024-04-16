part of 'base.dart';

/// Alias for a map representing data in the database.
typedef InAppSnapshot = Map<String, dynamic>;

abstract class InAppReference {
  final String reference;
  final InAppDatabaseInstance instance;

  const InAppReference(
    this.reference,
    this.instance,
  );

  String get id => DateTime.now().millisecondsSinceEpoch.toString();

  InAppCollectionReference ref(String field) {
    return InAppCollectionReference(field, instance);
  }

  /// Private method to delete data at a specific path in the database.
  ///
  /// Parameters:
  /// - [path]: The path to the data to be deleted.
  ///
  /// Example:
  /// ```dart
  /// localDB._d('users/123');
  /// ```
  Future<void> _d(String path) async {
    Object? temp = instance.collections;
    final segments = path.split('/').where((_) => _.isNotEmpty);
    for (final segment in segments) {
      if (temp is InAppSnapshot && temp.containsKey(segment)) {
        if (segments.last == segment) {
          temp.remove(segment);
        } else {
          temp = temp[segment];
        }
      } else {
        return;
      }
    }
    instance.build();
  }

  /// Private method to read data at a specific path in the database.
  ///
  /// Parameters:
  /// - [path]: The path to the data to be read.
  ///
  /// Example:
  /// ```dart
  /// Data userData = localDB._r('users/123');
  /// ```
  Future<InAppSnapshot> _r(String path) async {
    Object? temp = instance.root;
    final segments = path.split('/').where((_) => _.isNotEmpty);
    for (final segment in segments) {
      if (temp is InAppSnapshot && temp.containsKey(segment)) {
        temp = temp[segment];
      } else {
        return {};
      }
    }
    return temp is InAppSnapshot ? temp : {};
  }

  /// Private method to update data at a specific path in the database.
  ///
  /// Parameters:
  /// - [path]: The path to the data to be updated.
  /// - [value]: The new data to be added or updated.
  ///
  /// Example:
  /// ```dart
  /// localDB._u('users/123', {'name': 'John', 'age': 30});
  /// ```
  Future<InAppCollections> _u(String path, InAppSnapshot value) async {
    if (value.isNotEmpty) {
      final current = await _r(path);
      current.addAll(value);
      _w(path, current);
      return instance.build();
    } else {
      return instance.collections;
    }
  }

  /// Private method to write data at a specific path in the database.
  ///
  /// Parameters:
  /// - [path]: The path to the data to be written.
  /// - [value]: The data to be written.
  ///
  /// Example:
  /// ```dart
  /// localDB._w('users/123', {'name': 'John', 'age': 30});
  /// ```
  Future<InAppCollections> _w(String path, InAppSnapshot value) {
    Object? temp = instance.collections;
    final segments = path.split('/').where((_) => _.isNotEmpty);
    for (final segment in segments) {
      if (temp is InAppSnapshot) {
        if (!temp.containsKey(segment)) {
          if (segments.last == segment) {
            temp[segment] = value;
          } else {
            temp = temp[segment] = <String, dynamic>{};
          }
        } else {
          temp = temp[segment];
        }
      }
    }
    return instance.build();
  }
}
