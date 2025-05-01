import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:in_app_query/in_app_query.dart';

import '../core/field_value.dart';
import '../core/paging_options.dart';
import '../core/path.dart';
import 'delegate.dart';

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

class InAppDatabase extends ChangeNotifier {
  String _name;
  final bool showLogs;
  final InAppDatabaseDelegate _delegate;
  final Map<String, _InAppNotifier> _notifiers = {};
  InAppDatabaseVersion _version;

  String get name => _name == _defaultName ? "default" : _name;

  String get version => _version.code;

  set version(String code) => _version = InAppDatabaseVersion.custom(code);

  String get ref => _version.ref();

  Future<List<String>> get keys async {
    final paths = await _delegate.paths(_name);
    return paths
        .where((e) {
          if (version == InAppDatabaseVersion.v1.code) return true;
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

  InAppDatabase._({
    required String name,
    this.showLogs = false,
    InAppDatabaseVersion? version,
    required InAppDatabaseDelegate delegate,
  })  : _name = name,
        _version = version ?? InAppDatabaseVersion.v1,
        _delegate = delegate;

  static InAppDatabase? _i;

  static InAppDatabase get i {
    if (_i != null) return _i!;
    throw "$InAppDatabase not initialized yet!";
  }

  static InAppDatabase get I => i;

  static InAppDatabase get instance => i;

  static String _defaultName = '__in_app_database__';

  static Future<bool> init({
    String? name,
    bool showLogs = false,
    InAppDatabaseVersion? version,
    required InAppDatabaseDelegate delegate,
  }) async {
    try {
      _defaultName = name ?? _defaultName;
      _i = InAppDatabase._(
        name: _defaultName,
        showLogs: showLogs,
        version: version,
        delegate: delegate,
      );
      await i._delegate.init(i._name);
      _databases.add(_defaultName);
      i._log("$InAppDatabase initialized!");
      return true;
    } catch (msg) {
      return false;
    }
  }

  static final Set<String> _databases = {};

  static List<String> get databases => _databases.toList();

  static bool activate([String? name]) {
    name ??= _defaultName;
    if (!databases.contains(name)) {
      i._log(
        "$InAppDatabase($name) not activated for reason $InAppDatabase($name) not created yet",
      );
      return false;
    }
    i._name = name;
    i.notifyListeners();
    i._log(
      "$InAppDatabase(${name == _defaultName ? "default" : name}) activated!",
    );
    return true;
  }

  static Future<bool> create(String name) async {
    try {
      if (_databases.contains(name)) {
        throw "$InAppDatabase($name) already exists!";
      }
      await i._delegate.init(name);
      _databases.add(name);
      i._log("$InAppDatabase($name) created successfully.");
      return true;
    } catch (msg) {
      i._log(msg);
      rethrow;
    }
  }

  static Future<bool> delete(String name) async {
    try {
      if (!_databases.contains(name)) {
        throw "This database has already been deleted!";
      }
      if (name == "default" || name == _defaultName) {
        throw "The database is protected and can't be deleted!";
      }
      if (name == i._name) {
        throw "The database is currently active. Please deactivate it before deletion.";
      }
      await i._delegate.drop(name);
      _databases.remove(name);
      i._log("$InAppDatabase($name) has deleted!");
      i.notifyListeners();
      return true;
    } catch (msg) {
      i._log(msg);
      rethrow;
    }
  }

  InAppQueryReference collection(String field) {
    final reference = _version.ref(field);
    return InAppQueryReference(
      db: this,
      reference: reference,
      path: field,
      id: field,
    );
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

  Future<bool> _delete(
    String collectionPath, {
    bool related = true,
    Iterable<String> Function(String path, Iterable<String>)? filter,
  }) async {
    final ref = _version.ref(collectionPath);
    try {
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
    } catch (msg) {
      return false;
    }
  }

  Future<Iterable<String>> _k(String path) async {
    try {
      final paths = await _delegate.paths(_name);
      final ref = _version.ref(path);
      final children = paths.where((key) => key.startsWith(ref)).toList();
      return children;
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
  }) {
    final ref = _version.ref(collectionPath);
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
  }

  Future<bool> _w({
    required InAppWriteType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
    InAppDocument? value,
  }) {
    final ref = _version.ref(collectionPath);
    return _delegate.read(_name, ref).then((root) {
      final raw = root is String ? jsonDecode(root) : root;
      final base = raw is Map ? raw : {};
      if (type.isDocument) {
        final data = value == null ? null : jsonEncode(value);
        final id = documentId;
        if (data != null) {
          base[id] = data;
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
      return _wb(collectionPath, base).then((value) {
        return _delegate.write(_name, ref, value);
      });
    });
  }

  Future<String?> _wb(String path, Map base) async {
    String? body;
    if (base.isNotEmpty) {
      final limitation = await _delegate.limitation(
        _name,
        PathModifier.format(path),
      );
      if (limitation != null && limitation.limit > 0) {
        final limit = limitation.limit;
        final entries = base.entries;
        if (entries.length > limit) {
          final x = limitation.limitByRecent
              ? List.of(entries).reversed.take(limit)
              : entries.take(limit);
          body = jsonEncode(Map.fromEntries(x));
        } else {
          body = jsonEncode(base);
        }
      } else {
        body = jsonEncode(base);
      }
    }
    return body;
  }

  @override
  void dispose() {
    for (var value in _notifiers.values) {
      value.dispose();
    }
    _notifiers.clear();
    _databases.clear();
    _log("disposed!");
    super.dispose();
  }
}
