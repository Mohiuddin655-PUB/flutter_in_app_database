import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:in_app_query/in_app_query.dart';

import '../core/paging_options.dart';

part 'base.dart';
part 'collection.dart';
part 'counter.dart';
part 'document.dart';
part 'notifier.dart';
part 'params.dart';
part 'query.dart';
part 'reference.dart';
part 'snapshots.dart';

class InAppDatabase {
  final String name;
  final InAppDatabaseReader reader;
  final InAppDatabaseWriter writer;
  final Map<String, InAppNotifier> notifiers = {};

  InAppDatabase._({
    required this.name,
    required this.reader,
    required this.writer,
  });

  static InAppDatabase? _i;

  static InAppDatabase get i => _i!;

  static Future<InAppDatabase> init({
    required InAppDatabaseReader reader,
    required InAppDatabaseWriter writer,
  }) async {
    _i ??= InAppDatabase._(
      name: "__in_app_database__",
      reader: reader,
      writer: writer,
    );
    return _i!;
  }

  InAppQueryNotifier addListener(
    String reference, [
    InAppQuerySnapshot? value,
  ]) {
    final i = notifiers[reference];
    if (i == null) notifiers[reference] = InAppQueryNotifier(value);
    final x = i ?? notifiers[reference];
    return x is InAppQueryNotifier ? x : InAppQueryNotifier(value);
  }

  InAppDocumentNotifier addChildListener(
    String reference,
    String id, [
    InAppDocumentSnapshot? value,
  ]) {
    return addListener(reference).set(id, value);
  }

  InAppQueryReference ref(String field) {
    return InAppQueryReference(
      db: this,
      reference: "$name$field",
      collectionPath: field,
      collectionId: field,
    );
  }

  InAppQueryReference collection(String field) => ref(field);

  Future<InAppSnapshot> _r(InAppReadParams r) {
    return reader(r.collectionPath).then((raw) {
      final type = r.type;
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
          return InAppQuerySnapshot(r.collectionId, data);
        } else if (type.isDocument) {
          final docId = r.documentId;
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

  Future<bool> _w(InAppWriteParams w) async {
    return reader(w.collectionPath).then((value) {
      final raw = value is String ? jsonDecode(value) : null;
      final base = raw is Map ? raw : {};
      final data = w.value;
      final id = w.documentId;
      if (data != null) {
        base[id] = data;
      } else {
        base.remove(id);
      }
      final body = jsonEncode(base);
      return writer(w.collectionPath, body);
    });
  }

  Future<InAppSnapshot> read({
    required InAppReadType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
  }) {
    return _r(InAppReadParams(
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      documentPath: "$collectionPath/$documentId",
      documentId: documentId,
      type: type,
    ));
  }

  Future<bool> write({
    required InAppWriteType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
    Object? value,
  }) {
    return _w(InAppWriteParams(
      reference: reference,
      collectionPath: collectionPath,
      collectionId: collectionId,
      documentPath: "$collectionPath/$documentId",
      documentId: documentId,
      value: value == null ? null : jsonEncode(value),
      type: type,
    ));
  }
}
