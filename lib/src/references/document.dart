part of 'base.dart';

class InAppDocumentReference extends InAppReference {
  const InAppDocumentReference(
    super.reference,
    super.instance,
  );

  InAppCollectionReference collection(String field) {
    return InAppCollectionReference("$reference/$field", instance);
  }

  /// Method to set data in the document.
  ///
  /// Parameters:
  /// - [data]: The data to be set in the document.
  ///
  /// Example:
  /// ```dart
  /// documentRef.set({'name': 'John', 'age': 30});
  /// ```
  Future<InAppDocumentSnapshot> set(
    InAppDocument data, [
    InAppSetOptions options = const InAppSetOptions(),
  ]) {
    if (options.merge) {
      return update(data);
    } else {
      return _w(reference, data).then((_) => get());
    }
  }

  /// Method to update data in the document.
  ///
  /// Parameters:
  /// - [data]: The data to be updated in the document.
  ///
  /// Example:
  /// ```dart
  /// documentRef.update({'age': 31});
  /// ```
  Future<InAppDocumentSnapshot> update(InAppDocument data) {
    return _u(reference, data).then((_) => get());
  }

  /// Method to delete the document.
  ///
  /// Example:
  /// ```dart
  /// documentRef.delete();
  /// ```
  Future<InAppDocumentSnapshot> delete() {
    return _d(reference).then((_) => get());
  }

  /// Method to get all data in the document.
  ///
  /// Example:
  /// ```dart
  /// Data documentData = documentRef.get();
  /// ```
  Future<InAppDocumentSnapshot> get() {
    return _r(reference).then((data) {
      return InAppDocumentSnapshot(reference, data);
    });
  }

  Stream<InAppDocumentSnapshot> snapshots() {
    final controller = StreamController<InAppDocumentSnapshot>();
    final data = instance.collections[reference];
    if (data is InAppDocument) {
      controller.add(InAppDocumentSnapshot(reference, data));
    } else {
      controller.add(InAppDocumentSnapshot(reference, null));
    }
    return controller.stream;
  }
}
