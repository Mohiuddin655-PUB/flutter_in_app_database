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
  final Map<String, _InAppNotifier> _notifiers = {};

  InAppDatabase._({
    required this.name,
    required InAppDatabaseReader reader,
    required InAppDatabaseWriter writer,
  })  : _reader = reader,
        _writer = writer;

  static InAppDatabase? _i;

  static InAppDatabase get i => _i!;

  static InAppDatabase get I => i;

  static InAppDatabase get instance => i;

  static Future<InAppDatabase> init({
    String? name,
    required InAppDatabaseReader reader,
    required InAppDatabaseWriter writer,
  }) async {
    _i ??= InAppDatabase._(
      name: name ?? "__in_app_database__",
      reader: reader,
      writer: writer,
    );
    return _i!;
  }

  InAppQueryReference ref(String field) {
    return InAppQueryReference(
      db: this,
      reference: "$name$field",
      path: field,
      id: field,
    );
  }

  InAppQueryReference collection(String field) => ref(field);

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
        return const InAppUnknownSnapshot("Data not found!");
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
    if (type.isDocument) {
      return _reader(collectionPath).then((root) {
        final raw = root is String ? jsonDecode(root) : root;
        final base = raw is Map ? raw : {};
        final data = value == null ? null : jsonEncode(value);
        final id = documentId;
        if (data != null) {
          base[id] = data;
        } else {
          base.remove(id);
        }
        final body = jsonEncode(base);
        return _writer(collectionPath, body);
      });
    } else {
      final body = value is Map ? jsonEncode(value) : null;
      return _writer(collectionPath, body);
    }
  }
}
