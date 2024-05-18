import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:in_app_query/in_app_query.dart';

import '../core/field_value.dart';
import '../core/paging_options.dart';

part 'base.dart';
part 'collection.dart';
part 'counter.dart';
part 'document.dart';
part 'merger.dart';
part 'notifier.dart';
part 'query.dart';
part 'reference.dart';
part 'snapshots.dart';

class InAppDatabase {
  final String name;
  final InAppDatabaseReader _reader;
  final InAppDatabaseWriter _writer;
  final InAppDatabaseLimit? _limit;
  final Map<String, _InAppNotifier> _notifiers = {};

  InAppDatabase._({
    required this.name,
    required InAppDatabaseReader reader,
    required InAppDatabaseWriter writer,
    InAppDatabaseLimit? limit,
  })  : _reader = reader,
        _writer = writer,
        _limit = limit;

  static InAppDatabase? _i;

  static InAppDatabase get i => _i!;

  static InAppDatabase get I => i;

  static InAppDatabase get instance => i;

  static InAppDatabase init({
    String? name,
    required InAppDatabaseReader reader,
    required InAppDatabaseWriter writer,
    InAppDatabaseLimit? limiter,
  }) {
    _i ??= InAppDatabase._(
      name: name ?? "__in_app_database__",
      reader: reader,
      writer: writer,
      limit: limiter,
    );
    return _i!;
  }

  InAppQueryReference collection(String field) {
    return InAppQueryReference(
      db: this,
      reference: "$name$field",
      path: field,
      id: field,
    );
  }

  _InAppQueryNotifier _addNotifier(
    String reference, [
    InAppQuerySnapshot? value,
  ]) {
    final i = _notifiers[reference];
    if (i == null) _notifiers[reference] = _InAppQueryNotifier(value);
    final x = i ?? _notifiers[reference];
    return x is _InAppQueryNotifier ? x : _InAppQueryNotifier(value);
  }

  _InAppDocumentNotifier _addChildNotifier(
    String reference,
    String id, [
    InAppDocumentSnapshot? value,
  ]) {
    return _addNotifier(reference).set(id, value);
  }

  Future<InAppSnapshot> _r({
    required InAppReadType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
  }) {
    return _reader(collectionPath).then((raw) {
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
    return _reader(collectionPath).then((root) {
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
      return _wb(collectionPath, base).then((_) {
        return _writer(collectionPath, _);
      });
    });
  }

  Future<String?> _wb(String path, Map base) async {
    String? body;
    if (base.isNotEmpty) {
      if (_limit != null) {
        final limitation = (await _limit!(path));
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
      } else {
        body = jsonEncode(base);
      }
    }
    return body;
  }
}
