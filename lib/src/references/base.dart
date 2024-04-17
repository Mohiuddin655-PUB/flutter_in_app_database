import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../external/configs.dart';
import '../utils/query.dart';

part 'collection.dart';
part 'document.dart';
part 'instance.dart';
part 'notifier.dart';
part 'query.dart';
part 'reference.dart';

typedef InAppDocument = Map<String, Object?>;
typedef InAppValue = Object?;

class InAppDocumentSnapshot {
  final String id;
  final InAppDocument? _doc;

  InAppDocument? get data => _doc;

  bool get exists => _doc != null && _doc!.isNotEmpty;

  const InAppDocumentSnapshot(
    this.id, [
    this._doc,
  ]);

  InAppDocumentSnapshot copy({
    String? path,
    InAppDocument? doc,
  }) {
    return InAppDocumentSnapshot(path ?? this.id, doc ?? _doc);
  }

  @override
  String toString() {
    return "InAppDocumentSnapshot(path: $id, doc: $_doc)";
  }
}

class InAppSetOptions {
  final bool merge;

  const InAppSetOptions({
    this.merge = false,
  });
}

class InAppQuerySnapshot {
  final String id;
  final List<InAppDocumentSnapshot> docs;
  final List<InAppDocumentChange> docChanges;

  bool get exists => docs.isNotEmpty;

  const InAppQuerySnapshot(
    this.id, [
    this.docs = const [],
    this.docChanges = const [],
  ]);

  @override
  String toString() {
    return "InAppQuerySnapshot (path: $id, docs: $docs, docChanges: $docChanges)";
  }
}

class InAppDocumentChange {
  final InAppDocumentSnapshot doc;

  const InAppDocumentChange({
    required this.doc,
  });

  @override
  String toString() {
    return "InAppDocumentChange(doc: $doc)";
  }
}
