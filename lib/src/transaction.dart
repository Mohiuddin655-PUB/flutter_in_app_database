import 'batch.dart' show InAppWriteBatch;
import 'database.dart'
    show
        InAppDatabase,
        InAppDocumentSnapshot,
        InAppDocumentReference,
        InAppDocument,
        InAppSetOptions,
        InAppValue;

enum _TxnOpType { set, update, delete }

class _TxnOp {
  final _TxnOpType type;
  final InAppDocumentReference document;
  final InAppDocument? data;
  final InAppSetOptions options;

  const _TxnOp({
    required this.type,
    required this.document,
    this.data,
    this.options = InAppSetOptions.defaults,
  });
}

typedef InAppTransactionHandler<T> = Future<T> Function(
    InAppTransaction transaction);

class InAppTransaction {
  final InAppDatabase _database;
  final List<_TxnOp> _operations = [];
  bool _committed = false;

  InAppTransaction._(this._database);

  Future<InAppDocumentSnapshot> get(InAppDocumentReference document) {
    _ensureNotCommitted();
    _ensureSameDatabase(document);
    return document.get();
  }

  InAppTransaction set(
    InAppDocumentReference document,
    InAppDocument data, [
    InAppSetOptions? options,
  ]) {
    _ensureNotCommitted();
    _ensureSameDatabase(document);
    _operations.add(
      _TxnOp(
        type: _TxnOpType.set,
        document: document,
        data: Map<String, InAppValue>.of(data),
        options: options ?? InAppSetOptions.defaults,
      ),
    );
    return this;
  }

  InAppTransaction update(InAppDocumentReference document, InAppDocument data) {
    _ensureNotCommitted();
    _ensureSameDatabase(document);
    _operations.add(
      _TxnOp(
        type: _TxnOpType.update,
        document: document,
        data: Map<String, InAppValue>.of(data),
      ),
    );
    return this;
  }

  InAppTransaction delete(InAppDocumentReference document) {
    _ensureNotCommitted();
    _ensureSameDatabase(document);
    _operations.add(_TxnOp(type: _TxnOpType.delete, document: document));
    return this;
  }

  Future<void> _commit() async {
    if (_committed) return;
    _committed = true;
    if (_operations.isEmpty) return;

    final batch = InAppWriteBatch.of(_database);
    for (final op in _operations) {
      switch (op.type) {
        case _TxnOpType.set:
          batch.set(op.document, op.data!, op.options);
          break;
        case _TxnOpType.update:
          batch.update(op.document, op.data!);
          break;
        case _TxnOpType.delete:
          batch.delete(op.document);
          break;
      }
    }
    await batch.commit();
  }

  void _ensureNotCommitted() {
    if (_committed) {
      throw StateError(
        'Transaction can no longer be used after the handler has returned.',
      );
    }
  }

  void _ensureSameDatabase(InAppDocumentReference document) {
    if (!identical(document.database, _database)) {
      throw ArgumentError(
        'The document "${document.path}" belongs to a different InAppDatabase instance.',
      );
    }
  }

  static Future<T> run<T>(
    InAppDatabase firestore,
    InAppTransactionHandler<T> handler, {
    int maxAttempts = 5,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (maxAttempts <= 0) {
      throw ArgumentError.value(maxAttempts, 'maxAttempts', 'must be > 0');
    }
    Object? lastError;
    StackTrace? lastStack;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final txn = InAppTransaction._(firestore);
      try {
        final result = await handler(txn).timeout(timeout);
        await txn._commit();
        return result;
      } on ArgumentError {
        rethrow;
      } on StateError catch (e, st) {
        if (txn._committed) rethrow;
        lastError = e;
        lastStack = st;
      } catch (e, st) {
        lastError = e;
        lastStack = st;
        if (attempt < maxAttempts - 1) {
          await Future<void>.delayed(
            Duration(milliseconds: 100 * (attempt + 1)),
          );
        }
      }
    }
    Error.throwWithStackTrace(
      lastError ?? StateError('Transaction failed'),
      lastStack ?? StackTrace.current,
    );
  }
}
