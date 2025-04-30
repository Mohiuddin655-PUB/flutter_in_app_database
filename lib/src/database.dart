import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:in_app_query/in_app_query.dart';

import '../core/field_value.dart';
import '../core/paging_options.dart';
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

  Future<Iterable<String>> get paths => _delegate.paths(name);

  InAppDatabase._({
    required this.name,
    this.showLogs = false,
    InAppDatabaseVersion? version,
    required InAppDatabaseDelegate delegate,
  })  : _version = version ?? InAppDatabaseVersion.v1,
        _delegate = delegate;

  void _log(msg, {String field = '', String action = ''}) {
    if (!showLogs) return;
    msg = msg.toString();
    if (field.isNotEmpty) {
      msg = "${action.isEmpty ? field : '$action($field)'} :$msg";
    } else if (action.isNotEmpty) {
      msg = "$action: $msg";
    }
    log(msg, name: "IN_APP_DATABASE");
  }

  T execute<T extends Object?>(String action, T Function() callback) {
    return _version(action, callback);
  }

  static InAppDatabase? _i;

  static InAppDatabase get i {
    if (_i != null) return _i!;
    throw "Not initialized yet!";
  }

  static InAppDatabase get I => i;

  static InAppDatabase get instance => i;

  static void init({
    String? name,
    bool showLogs = false,
    InAppDatabaseVersion? version,
    required InAppDatabaseDelegate delegate,
  }) {
    _i ??= InAppDatabase._(
      name: name ?? "__in_app_database__",
      showLogs: showLogs,
      version: version,
      delegate: delegate,
    );
    i._log("initialized!");
  }

  InAppQueryReference collection(String field) {
    final reference = _version.ref(name, field);
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

  Future<bool> drop(
    String field, {
    bool related = true,
    Iterable<String> Function(String path, Iterable<String>)? filter,
  }) async {
    try {
      return execute("drop", () async {
        if (!related) return _delegate.drop([field]);
        final paths = await this.paths;
        if (filter != null) {
          final keys = filter(field, paths);
          return _delegate.drop(keys);
        }
        final x = field.replaceAll(name, '').split("/").firstOrNull ?? '/';
        final normalizedPath = x.endsWith('/') ? x : '$x/';
        final keysToDelete = paths.where((key) {
          return key.startsWith(normalizedPath);
        }).toList();
        final feedback = await _delegate.drop(keysToDelete);
        _log("dropped!", field: field, action: "drop");
        return feedback;
      });
    } catch (msg) {
      _log(msg, field: field, action: "drop");
      return false;
    }
  }

  Future<InAppSnapshot> _r({
    required InAppReadType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
  }) {
    return _delegate.read(collectionPath).then((raw) {
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
    return _delegate.read(collectionPath).then((root) {
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
        return _delegate.write(collectionPath, value);
      });
    });
  }

  Future<String?> _wb(String path, Map base) async {
    String? body;
    if (base.isNotEmpty) {
      final limitation = await _delegate.limitation(path);
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
    _i = null;
    _log("disposed!");
  }
}
