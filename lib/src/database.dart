import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:in_app_query/in_app_query.dart';

import '../core/field_value.dart';
import '../core/paging_options.dart';
import '../core/path.dart';
import 'batch.dart';
import 'delegate.dart';
import 'pointer.dart';

part 'base.dart';
part 'collection.dart';
part 'counter.dart';
part 'document.dart';
part 'merger.dart';
part 'notifier.dart';
part 'query.dart';
part 'reference.dart';
part 'snapshots.dart';
part 'version.dart';

enum InAppDatabaseType { json, map }

class InAppDatabase extends ChangeNotifier {
  String _name;
  final bool showLogs;
  final InAppDatabaseDelegate _delegate;
  final InAppDatabaseType _type;
  final Map<String, _InAppNotifier> _notifiers = {};
  InAppDatabaseVersion _version;

  String get name => _name == _defaultName ? "default" : _name;

  String get versionCode => _version.code;

  set versionCode(String code) => version(InAppDatabaseVersion.custom(code));

  String get ref => _version._ref();

  Future<List<String>> get keys async {
    final paths = await _delegate.paths(_name);
    return paths
        .where((e) {
          if (versionCode == InAppDatabaseVersion.v1.code) return true;
          return e.startsWith(ref);
        })
        .map((e) {
          final x = e.replaceAll(ref, '').split('/').firstOrNull;
          if (x == null || x.isEmpty) return null;
          return x;
        })
        .toSet()
        .whereType<String>()
        .toList();
  }

  bool get isInitialized => isInitializedAs(_name);

  void _log(msg, {String field = '', String action = ''}) {
    if (!showLogs || kReleaseMode) return;
    msg = msg.toString();
    if (field.isNotEmpty) {
      msg = "${action.isEmpty ? field : '$action($field)'}: $msg";
    } else if (action.isNotEmpty) {
      msg = "$action: $msg";
    }
    log(msg, name: "IN_APP_DATABASE");
  }

  static InAppDatabase? _i;

  static InAppDatabase get i {
    if (_i != null) return _i!;
    throw "$InAppDatabase not initialized yet!";
  }

  static InAppDatabase get I => i;

  static InAppDatabase get instance => i;

  static String _defaultName = '__in_app_database__';

  static InAppDatabaseVersion _defaultVersion = InAppDatabaseVersion.v1;

  static bool get isDefault => i._name == _defaultName;

  static bool get isDefaultVersion => i.versionCode == _defaultVersion.code;

  static final Map<String, bool> _databases = {};

  static List<String> get databases => _databases.keys.toList();

  static bool isInitializedAs(String name) => _databases[name] ?? false;

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

  ValueNotifier<bool> initializing = ValueNotifier(false);

  static Future<bool> init({
    String? name,
    bool showLogs = false,
    InAppDatabaseType? type,
    InAppDatabaseVersion? version,
    required InAppDatabaseDelegate delegate,
  }) async {
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
      if (!initialized) throw "$InAppDatabase not initialized!";
      _databases[_defaultName] = true;
      i._log("$InAppDatabase initialized!");
      i.notifyListeners();
      return true;
    } catch (msg) {
      i.initializing.value = false;
      i._log(msg);
      return false;
    }
  }

  ValueNotifier<bool> activating = ValueNotifier(false);

  static Future<bool> activate([String? name]) async {
    try {
      name ??= _defaultName;
      if (!databases.contains(name)) {
        throw "$InAppDatabase($name) not activated for reason $InAppDatabase($name) not created yet";
      }
      if (!isInitializedAs(name)) {
        i.activating.value = true;
        final created = await i._delegate.init(name);
        i.activating.value = false;
        if (!created) {
          throw "$InAppDatabase(${name == _defaultName ? "default" : name}) not activated!";
        }
        _databases[name] = created;
      }
      i._name = name;
      i._log(
        "$InAppDatabase(${name == _defaultName ? "default" : name}) activated!",
      );
      i.notifyListeners();
      return true;
    } catch (msg) {
      i.activating.value = false;
      i._log(msg);
      rethrow;
    }
  }

  static bool version([InAppDatabaseVersion? version]) {
    try {
      if (!i.isInitialized) {
        throw "InAppDatabase(${i.name}) not initialized yet!";
      }
      version ??= _defaultVersion;
      i._version = version;
      i._log(
        "$InAppDatabase(${i.name}) version changed, currently activated version is ${version.code}.",
      );
      i.notifyListeners();
      return true;
    } catch (msg) {
      i._log(msg);
      rethrow;
    }
  }

  ValueNotifier<bool> creating = ValueNotifier(false);

  static Future<bool> create(String name) async {
    try {
      if (databases.contains(name)) {
        throw "$InAppDatabase($name) already exists!";
      }
      i.creating.value = true;
      final created = await i._delegate.init(name);
      i.creating.value = false;
      if (!created) {
        throw "$InAppDatabase($name) created unsuccessfully.";
      }
      _databases[name] = created;
      i._log("$InAppDatabase($name) created successfully");
      i.notifyListeners();
      return true;
    } catch (msg) {
      i.creating.value = false;
      i._log(msg);
      rethrow;
    }
  }

  ValueNotifier<bool> deleting = ValueNotifier(false);

  static Future<bool> delete(String name) async {
    try {
      if (!databases.contains(name)) {
        throw "This database has already been deleted!";
      }
      if (name == "default" || name == _defaultName) {
        throw "The database is protected and can't be deleted!";
      }
      if (name == i._name) {
        throw "The database is currently active. Please deactivate it before deletion.";
      }
      i.deleting.value = true;
      final deleted = await i._delegate.drop(name);
      i.deleting.value = false;
      if (!deleted) {
        throw "$InAppDatabase($name) deleted unsuccessfully.";
      }
      _databases.remove(name);
      i._log("$InAppDatabase($name) deleted successfully");
      i.notifyListeners();
      return true;
    } catch (msg) {
      i.deleting.value = false;
      i._log(msg);
      rethrow;
    }
  }

  InAppWriteBatch batch() => InAppWriteBatch.instanceOf(this);

  InAppQueryReference collection(String field) {
    final reference = _version._ref(field);
    return InAppQueryReference(
      db: this,
      reference: reference,
      path: field,
      id: field,
    );
  }

  InAppDocumentReference doc(String documentPath) {
    final pointer = InAppPointer(documentPath);
    if (documentPath.isEmpty) {
      throw ArgumentError('A document path must be a non-empty string.');
    } else if (documentPath.contains('//')) {
      throw ArgumentError('A document path must not contain "//".');
    } else if (!pointer.isDocument()) {
      throw ArgumentError('A document path must point to a valid document.');
    }
    final parts = List.of(pointer.components);
    InAppReference ref = collection(parts.first);
    parts.removeAt(0);
    ref = parts.fold(ref, (ref, field) {
      if (ref is InAppCollectionReference) {
        return ref.doc(field);
      } else if (ref is InAppDocumentReference) {
        return ref.collection(field);
      }
      return ref;
    });
    return ref as InAppDocumentReference;
  }

  InAppQueryNotifier _addNotifier(
    String reference, [
    InAppQuerySnapshot? value,
  ]) {
    final i = _notifiers[reference];
    if (i == null) _notifiers[reference] = InAppQueryNotifier(value);
    final x = i ?? _notifiers[reference];
    return x is InAppQueryNotifier ? x : InAppQueryNotifier(value);
  }

  InAppDocumentNotifier _addChildNotifier(
    String reference,
    String id, [
    InAppDocumentSnapshot? value,
  ]) {
    return _addNotifier(reference).set(id, value);
  }

  int _executes = 0;

  Future<T> _execute<T>(Future<T> Function() callback, [bool? internal]) async {
    try {
      if (!isInitialized) throw "$InAppDatabase<$_name> not initialized yet!";
      if (!(internal ?? false)) _executes = 0;
      return callback();
    } catch (_) {
      if (_executes > 5) {
        _executes = 0;
        rethrow;
      }
      _executes++;
      return Future.delayed(Duration(seconds: 2), () {
        return _execute(callback, true);
      });
    }
  }

  Future<bool> _delete(
    String collectionPath, {
    bool related = true,
    Iterable<String> Function(String path, Iterable<String>)? filter,
  }) async {
    final ref = _version._ref(collectionPath);
    try {
      return _execute(() async {
        if (!related) return _delegate.delete(_name, ref);
        final paths = await _delegate.paths(_name);
        if (filter != null) {
          final keys = filter(ref, paths);
          for (var i in keys) {
            await _delegate.delete(_name, i);
          }
          return true;
        }
        final keysToDelete = paths.where((key) => key.startsWith(ref)).toList();
        if (keysToDelete.isEmpty) throw "Path not found!";
        for (var i in keysToDelete) {
          await _delegate.delete(_name, i);
        }
        return true;
      });
    } catch (msg) {
      return false;
    }
  }

  Future<Iterable<String>> _k(String path) async {
    try {
      return _execute(() async {
        final paths = await _delegate.paths(_name);
        final ref = _version._ref(path);
        final children = paths.where((key) => key.startsWith(ref)).toList();
        return children;
      });
    } catch (_) {
      return [];
    }
  }

  Future<InAppSnapshot> _r({
    required InAppReadType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
  }) async {
    try {
      return _execute(() {
        final ref = _version._ref(collectionPath);
        return _delegate.read(_name, ref).then((raw) {
          final value = raw is String ? jsonDecode(raw) : raw;
          if (value is Map) {
            if (type.isCollection) {
              final data = value.entries
                  .map((e) {
                    final x = e.value;
                    final y = x is String ? jsonDecode(x) : x;
                    final z = y is InAppDocument ? y : null;
                    return InAppDocumentSnapshot(e.key, z);
                  })
                  .where((i) => i.data != null && i.data!.isNotEmpty)
                  .toList();
              return InAppQuerySnapshot(collectionId, data);
            } else if (type.isDocument) {
              final docId = documentId;
              final raw = value[docId];
              final doc = raw is String
                  ? jsonDecode(raw)
                  : raw is InAppDocument
                      ? raw
                      : null;
              return InAppDocumentSnapshot(docId, doc);
            } else {
              return const InAppErrorSnapshot("Type isn't valid!");
            }
          } else {
            return const InAppFailureSnapshot("Data not found!");
          }
        });
      });
    } catch (msg) {
      return InAppFailureSnapshot(msg.toString());
    }
  }

  Future<Object?> _wb(String path, Map base, bool isJson) async {
    if (base.isEmpty) return null;
    final l = await _delegate.limitation(_name, PathModifier.format(path));
    if (l == null || l.limit <= 0) return isJson ? jsonEncode(base) : base;
    final limit = l.limit;
    final entries = base.entries;
    if (entries.length <= limit) return isJson ? jsonEncode(base) : base;
    final x = l.limitByRecent
        ? List.of(entries).reversed.take(limit)
        : entries.take(limit);
    final data = Map.fromEntries(x);
    return isJson ? jsonEncode(data) : data;
  }

  Future<bool> _w({
    required InAppWriteType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
    InAppDocument? value,
  }) async {
    try {
      final isJson = _type == InAppDatabaseType.json;
      return _execute(() {
        final ref = _version._ref(collectionPath);
        return _delegate.read(_name, ref).then((root) {
          final raw = root is String ? jsonDecode(root) : root;
          final base = raw is Map ? raw : {};
          if (type.isDocument) {
            final data = value != null
                ? Map.fromEntries(value.entries.map((e) {
                    if (e.value is! Object) return null;
                    return MapEntry(e.key, e.value as Object);
                  }).whereType<MapEntry<String, Object>>())
                : <String, Object>{};
            final id = documentId;
            if (data.isNotEmpty) {
              base[id] = isJson ? jsonEncode(data) : data;
            } else {
              base.remove(id);
            }
          } else if (type.isCollection) {
            if (value != null) {
              for (var i in value.entries) {
                final id = i.key;
                final value = i.value;
                final data = value == null ? null : jsonEncode(value);
                if (data != null) {
                  base[id] = data;
                } else {
                  base.remove(id);
                }
              }
            } else {
              base.clear();
            }
          }
          return _wb(collectionPath, base, isJson).then((value) {
            return _delegate.write(_name, ref, value);
          });
        });
      });
    } catch (msg) {
      return false;
    }
  }

  @override
  void dispose() {
    for (var value in _notifiers.values) {
      value.dispose();
    }
    initializing.dispose();
    activating.dispose();
    creating.dispose();
    deleting.dispose();
    _notifiers.clear();
    _databases.clear();
    _log("disposed!");
    super.dispose();
  }
}
