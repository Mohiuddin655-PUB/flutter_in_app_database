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

class InAppDatabase {
  final String name;
  final bool showLogs;
  final InAppDatabaseDelegate _delegate;
  final Map<String, _InAppNotifier> _notifiers = {};
  InAppDatabaseVersion _version;

  String get version => _version.code;

  set version(String code) => _version = InAppDatabaseVersion.custom(code);

  String get ref => _version.ref();

  Future<List<String>> get keys async {
    final paths = await _delegate.paths(name);
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
    required this.name,
    this.showLogs = false,
    InAppDatabaseVersion? version,
    required InAppDatabaseDelegate delegate,
  })  : _version = version ?? InAppDatabaseVersion.v1,
        _delegate = delegate;

  static InAppDatabase? _i;

  static InAppDatabase get i {
    if (_i != null) return _i!;
    throw "$InAppDatabase not initialized yet!";
  }

  static InAppDatabase get I => i;

  static InAppDatabase get instance => i;

  static final Map<String, InAppDatabase> _proxies = {};

  static InAppDatabase of(String name) {
    final i = _proxies[name];
    if (i != null) return i;
    throw "$InAppDatabase($name) not created yet!";
  }

  static Future<void> create({
    required String name,
    bool showLogs = false,
    InAppDatabaseVersion? version,
    required InAppDatabaseDelegate delegate,
  }) async {
    _proxies[name] = InAppDatabase._(
      name: name,
      showLogs: showLogs,
      version: version,
      delegate: delegate,
    );
    final i = of(name);
    await i._delegate.init(i.name);
    i._log("${i.name} created!");
  }

  static void close() {
    for (final db in _proxies.values) {
      db.dispose();
    }
  }

  static Future<void> init({
    String? name,
    bool showLogs = false,
    InAppDatabaseVersion? version,
    required InAppDatabaseDelegate delegate,
  }) async {
    _i = InAppDatabase._(
      name: name ?? '__in_app_database__',
      showLogs: showLogs,
      version: version,
      delegate: delegate,
    );
    await i._delegate.init(i.name);
    i._log("$InAppDatabase initialized!");
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

  Future<bool> drop(
    String field, {
    bool related = true,
    bool notifiable = false,
    Iterable<String> Function(String path, Iterable<String>)? filter,
  }) async {
    return collection(field).drop(
      related: related,
      notifiable: notifiable,
      filter: filter,
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

  Future<bool> _drop(
    String collectionPath, {
    bool related = true,
    Iterable<String> Function(String path, Iterable<String>)? filter,
  }) async {
    final ref = _version.ref(collectionPath);
    try {
      if (!related) return _delegate.drop(name, ref);
      final paths = await _delegate.paths(name);
      if (filter != null) {
        final keys = filter(ref, paths);
        for (var i in keys) {
          await _delegate.drop(name, i);
        }
        return true;
      }
      final keysToDelete = paths.where((key) => key.startsWith(ref)).toList();
      if (keysToDelete.isEmpty) throw "Path not found!";
      for (var i in keysToDelete) {
        await _delegate.drop(name, i);
      }
      return true;
    } catch (msg) {
      return false;
    }
  }

  Future<Iterable<String>> _k(String path) async {
    try {
      final paths = await _delegate.paths(name);
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
    return _delegate.read(name, ref).then((raw) {
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
    return _delegate.read(name, ref).then((root) {
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
        return _delegate.write(name, ref, value);
      });
    });
  }

  Future<String?> _wb(String path, Map base) async {
    String? body;
    if (base.isNotEmpty) {
      final limitation = await _delegate.limitation(
        name,
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

  void dispose() {
    for (var value in _notifiers.values) {
      value.dispose();
    }
    _notifiers.clear();
    _proxies.remove(name);
    _log("disposed!");
  }
}
