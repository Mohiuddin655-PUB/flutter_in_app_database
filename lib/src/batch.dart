import 'database.dart';

enum _BatchOperationType { set, update, delete }

/// Internal operation details
class _BatchOperation {
  final _BatchOperationType type;
  final InAppDocumentReference document;
  final Map<String, dynamic>? data;
  final InAppSetOptions? options;

  _BatchOperation({
    required this.type,
    required this.document,
    this.data,
    this.options,
  });
}

class InAppWriteBatch {
  InAppWriteBatch();

  final List<_BatchOperation> _operations = [];

  /// Add a `set` operation
  void set(
    InAppDocumentReference document,
    Object data, [
    InAppSetOptions? options,
  ]) {
    if (data is! Map<String, dynamic>) return;
    _operations.add(_BatchOperation(
      type: _BatchOperationType.set,
      document: document,
      data: data,
      options: options,
    ));
  }

  /// Add an `update` operation
  void update(InAppDocumentReference document, Map<String, dynamic> data) {
    _operations.add(_BatchOperation(
      type: _BatchOperationType.update,
      document: document,
      data: data,
    ));
  }

  /// Add a `delete` operation
  void delete(InAppDocumentReference document) {
    _operations.add(_BatchOperation(
      type: _BatchOperationType.delete,
      document: document,
    ));
  }

  /// Execute all operations directly (not as Firestore batch)
  Future<void> commit() async {
    for (final op in _operations) {
      switch (op.type) {
        case _BatchOperationType.set:
          await op.document.set(op.data!, op.options!);
          break;
        case _BatchOperationType.update:
          await op.document.update(op.data!);
          break;
        case _BatchOperationType.delete:
          await op.document.delete();
          break;
      }
    }
    _operations.clear();
  }
}
