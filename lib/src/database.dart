import 'dart:async' show Stream, Completer;
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:developer' show log;

import 'package:flutter/foundation.dart'
    show ChangeNotifier, kReleaseMode, ValueNotifier, VoidCallback;
import 'package:in_app_query/in_app_query.dart'
    show QueryBuilder, Query, Selection, Selections, Sorting;

import '../core/document_change_type.dart' show InAppDocumentChangeType;
import '../core/field_path.dart' show InAppFieldPath;
import '../core/field_value.dart' show InAppFieldValue, InAppFieldValues;
import '../core/paging_options.dart' show InAppPagingOptions;
import '../core/path.dart' show PathModifier;
import '../core/source.dart' show InAppSource;
import 'batch.dart' show InAppWriteBatch;
import 'delegate.dart' show InAppDatabaseDelegate;
import 'pointer.dart' show InAppPointer;
import 'transaction.dart' show InAppTransaction, InAppTransactionHandler;

part '../mixins/delete.dart';
part '../mixins/error.dart';
part '../mixins/executor.dart';
part '../mixins/logger.dart';
part '../mixins/notifier_manager.dart';
part '../mixins/reader.dart';
part '../mixins/serial.dart';
part '../mixins/writer.dart';
part 'aggregate.dart';
part 'base.dart';
part 'collection.dart';
part 'document.dart';
part 'merger.dart';
part 'notifier.dart';
part 'query.dart';
part 'reference.dart';
part 'snapshots.dart';
part 'version.dart';

enum InAppDatabaseType { json, map }

class InAppDatabase extends ChangeNotifier
    with
        _ErrorMixin,
        _LoggerMixin,
        _SerialMixin,
        _NotifierManagerMixin,
        _ExecutorMixin,
        _ReaderMixin,
        _WriterMixin,
        _DeleterMixin {
  @override
  String _name;

  @override
  final bool showLogs;

  @override
  final InAppDatabaseDelegate _delegate;

  @override
  final InAppDatabaseType _type;

  @override
  InAppDatabaseVersion _version;
  bool _disposed = false;

  final ValueNotifier<bool> initializing = ValueNotifier(false);
  final ValueNotifier<bool> activating = ValueNotifier(false);
  final ValueNotifier<bool> creating = ValueNotifier(false);
  final ValueNotifier<bool> deleting = ValueNotifier(false);

  InAppDatabase._({
    this.showLogs = false,
    required String name,
    InAppDatabaseType? type,
    InAppDatabaseVersion? version,
    required InAppDatabaseDelegate delegate,
  })  : _name = name,
        _type = type ?? InAppDatabaseType.json,
        _version = version ?? InAppDatabaseVersion.v1,
        _delegate = delegate;

  @override
  String get name => _name == _defaultName ? 'default' : _name;

  String get versionCode => _version.code;

  set versionCode(String code) => version(InAppDatabaseVersion.custom(code));

  String get ref => _version._ref();

  @override
  bool get isDisposed => _disposed;

  @override
  bool get isInitialized => isInitializedAs(_name);

  Future<List<String>> get keys async {
    final paths = await _delegate.paths(_name);
    final r = ref;
    final result = <String>{};
    for (final p in paths) {
      if (versionCode != InAppDatabaseVersion.v1.code && !p.startsWith(r)) {
        continue;
      }
      final stripped = r.isEmpty ? p : p.replaceFirst(r, '');
      final first = stripped.split('/').first;
      if (first.isNotEmpty) result.add(first);
    }
    return result.toList(growable: false);
  }

  static InAppDatabase? _i;

  static InAppDatabase get i {
    final instance = _i;
    if (instance == null) {
      throw StateError('$InAppDatabase not initialized yet!');
    }
    return instance;
  }

  static InAppDatabase get I => i;

  static InAppDatabase get instance => i;

  static String _defaultName = '__in_app_database__';

  static InAppDatabaseVersion _defaultVersion = InAppDatabaseVersion.v1;

  static bool get isDefault => i._name == _defaultName;

  static bool get isDefaultVersion => i.versionCode == _defaultVersion.code;

  static final Map<String, bool> _databases = {};

  static List<String> get databases => List.unmodifiable(_databases.keys);

  static bool isInitializedAs(String name) => _databases[name] ?? false;

  static Completer<bool>? _initCompleter;

  static Future<bool> init({
    String? name,
    bool showLogs = false,
    InAppDatabaseType? type,
    InAppDatabaseVersion? version,
    required InAppDatabaseDelegate delegate,
  }) async {
    final existing = _initCompleter;
    if (existing != null) return existing.future;
    final completer = Completer<bool>();
    _initCompleter = completer;
    try {
      _defaultName = name ?? _defaultName;
      _defaultVersion = version ?? _defaultVersion;
      _i = InAppDatabase._(
        name: _defaultName,
        type: type,
        version: _defaultVersion,
        showLogs: showLogs,
        delegate: delegate,
      );
      i.initializing.value = true;
      final initialized = await i._delegate.init(i._name);
      i.initializing.value = false;
      if (!initialized) {
        throw const InAppDatabaseException('Database not initialized.');
      }
      _databases[_defaultName] = true;
      i._log('$InAppDatabase initialized!');
      i.notifyListeners();
      if (!completer.isCompleted) completer.complete(true);
      return true;
    } catch (e) {
      _i?.initializing.value = false;
      _i?._log(e);
      _initCompleter = null;
      if (!completer.isCompleted) completer.complete(false);
      return false;
    }
  }

  static Future<bool> activate([String? name]) async {
    final inst = i;
    final target = name ?? _defaultName;
    try {
      if (!_databases.containsKey(target)) {
        throw InAppDatabaseException(
          '$InAppDatabase($target) not created yet.',
        );
      }
      if (!isInitializedAs(target)) {
        inst.activating.value = true;
        final created = await inst._delegate.init(target);
        inst.activating.value = false;
        if (!created) {
          throw InAppDatabaseException(
            '$InAppDatabase(${target == _defaultName ? "default" : target}) not activated.',
          );
        }
        _databases[target] = created;
      }
      inst._name = target;
      inst._log('activated: ${target == _defaultName ? "default" : target}');
      inst.notifyListeners();
      return true;
    } catch (e) {
      inst.activating.value = false;
      inst._log(e);
      rethrow;
    }
  }

  static bool version([InAppDatabaseVersion? version]) {
    final inst = i;
    try {
      if (!inst.isInitialized) {
        throw InAppDatabaseException(
          '$InAppDatabase(${inst.name}) not initialized.',
        );
      }
      inst._version = version ?? _defaultVersion;
      inst._log('version changed to ${inst._version.code}');
      inst.notifyListeners();
      return true;
    } catch (e) {
      inst._log(e);
      rethrow;
    }
  }

  static Future<bool> create(String name) async {
    final inst = i;
    try {
      if (name.isEmpty) {
        throw const InAppDatabaseException('Database name cannot be empty.');
      }
      if (_databases.containsKey(name)) {
        throw InAppDatabaseException('$InAppDatabase($name) already exists.');
      }
      inst.creating.value = true;
      final created = await inst._delegate.init(name);
      inst.creating.value = false;
      if (!created) {
        throw InAppDatabaseException('$InAppDatabase($name) not created.');
      }
      _databases[name] = created;
      inst._log('$InAppDatabase($name) created.');
      inst.notifyListeners();
      return true;
    } catch (e) {
      inst.creating.value = false;
      inst._log(e);
      rethrow;
    }
  }

  static Future<bool> delete(String name) async {
    final inst = i;
    try {
      if (!_databases.containsKey(name)) {
        throw const InAppDatabaseException('Database not found.');
      }
      if (name == 'default' || name == _defaultName) {
        throw const InAppDatabaseException(
          'The default database is protected and cannot be deleted.',
        );
      }
      if (name == inst._name) {
        throw const InAppDatabaseException(
          'Database is currently active. Deactivate it before deletion.',
        );
      }
      inst.deleting.value = true;
      final deleted = await inst._delegate.drop(name);
      inst.deleting.value = false;
      if (!deleted) {
        throw InAppDatabaseException('$InAppDatabase($name) not deleted.');
      }
      _databases.remove(name);
      inst._log('$InAppDatabase($name) deleted.');
      inst.notifyListeners();
      return true;
    } catch (e) {
      inst.deleting.value = false;
      inst._log(e);
      rethrow;
    }
  }

  Future<void> terminate() async {
    if (_disposed) return;
    await _drainSerial();
    dispose();
  }

  Future<void> clearPersistence() async {
    if (!isInitialized) return;
    final paths = await _delegate.paths(_name);
    for (final p in paths) {
      await _delegate.delete(_name, p);
    }
  }

  InAppWriteBatch batch() => InAppWriteBatch.of(this);

  Future<T> runTransaction<T>(
    InAppTransactionHandler<T> handler, {
    int maxAttempts = 5,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return InAppTransaction.run<T>(
      this,
      handler,
      maxAttempts: maxAttempts,
      timeout: timeout,
    );
  }

  InAppQueryReference collection(String field) {
    if (field.isEmpty) {
      throw ArgumentError.value(
        field,
        'field',
        'Collection path cannot be empty.',
      );
    }
    if (field.contains('//')) {
      throw ArgumentError.value(
        field,
        'field',
        'Collection path cannot contain "//".',
      );
    }
    final pointer = InAppPointer(field);
    if (!pointer.isCollection()) {
      throw ArgumentError.value(
        field,
        'field',
        'Path must point to a collection.',
      );
    }
    final parts = pointer.components;
    if (parts.length == 1) {
      return InAppQueryReference(
        db: this,
        ref: _version._ref(field),
        path: field,
        id: field,
      );
    }
    InAppCollectionReference current = InAppQueryReference(
      db: this,
      ref: _version._ref(parts.first),
      path: parts.first,
      id: parts.first,
    );
    var i = 1;
    while (i < parts.length) {
      final docId = parts[i];
      if (i + 1 >= parts.length) break;
      final colId = parts[i + 1];
      current = current.doc(docId).collection(colId);
      i += 2;
    }
    return current as InAppQueryReference;
  }

  InAppQueryReference collectionGroup(String collectionId) {
    if (collectionId.isEmpty || collectionId.contains('/')) {
      throw ArgumentError.value(
        collectionId,
        'collectionId',
        'Collection group id must be non-empty and not contain "/".',
      );
    }
    return collection(collectionId);
  }

  InAppDocumentReference doc(String documentPath) {
    if (documentPath.isEmpty) {
      throw ArgumentError.value(
        documentPath,
        'documentPath',
        'must be non-empty.',
      );
    }
    if (documentPath.contains('//')) {
      throw ArgumentError.value(
        documentPath,
        'documentPath',
        'cannot contain "//".',
      );
    }
    final pointer = InAppPointer(documentPath);
    if (!pointer.isDocument()) {
      throw ArgumentError.value(
        documentPath,
        'documentPath',
        'must point to a valid document (even number of segments).',
      );
    }
    final parts = pointer.components;
    InAppReference ref = collection(parts.first);
    for (var i = 1; i < parts.length; i++) {
      final seg = parts[i];
      if (ref is InAppCollectionReference) {
        ref = ref.doc(seg);
      } else if (ref is InAppDocumentReference) {
        ref = ref.collection(seg);
      }
    }
    return ref as InAppDocumentReference;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _disposeAllNotifiers();
    _serialQueue.clear();
    initializing.dispose();
    activating.dispose();
    creating.dispose();
    deleting.dispose();
    _databases.remove(_name);
    _initCompleter = null;
    if (identical(_i, this)) _i = null;
    _log('disposed!');
    super.dispose();
  }
}
