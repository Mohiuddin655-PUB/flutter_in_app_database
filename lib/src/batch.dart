import 'database.dart';

enum _BatchOperationType { set, update, delete }

/// Internal operation details
class _BatchOperation {
  final _BatchOperationType type;
  final String path;
  final Map<String, dynamic>? data;
  final InAppSetOptions? options;

  _BatchOperation({
    required this.type,
    required this.path,
    this.data,
    this.options,
  });
}

class InAppWriteBatch {
  final InAppDatabase _db;
  final List<_BatchOperation> _operations = [];

  InAppWriteBatch.instanceOf(this._db);

  /// Add a `set` operation
  void set(
    String docPath,
    Map<String, dynamic> data, {
    InAppSetOptions options = const InAppSetOptions(),
  }) {
    _operations.add(_BatchOperation(
      type: _BatchOperationType.set,
      path: docPath,
      data: data,
      options: options,
    ));
  }

  /// Add an `update` operation
  void update(String docPath, Map<String, dynamic> data) {
    _operations.add(_BatchOperation(
      type: _BatchOperationType.update,
      path: docPath,
      data: data,
    ));
  }

  /// Add a `delete` operation
  void delete(String docPath) {
    _operations.add(_BatchOperation(
      type: _BatchOperationType.delete,
      path: docPath,
    ));
  }

  /// Execute all operations directly (not as Firestore batch)
  Future<void> commit() async {
    for (final op in _operations) {
      final ref = _db.doc(op.path);
      switch (op.type) {
        case _BatchOperationType.set:
          await ref.set(op.data!, op.options!);
          break;
        case _BatchOperationType.update:
          await ref.update(op.data!);
          break;
        case _BatchOperationType.delete:
          await ref.delete();
          break;
      }
    }
    _operations.clear();
  }
}
