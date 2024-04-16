import 'dart:async';

import 'package:in_app_database/in_app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../external/configs.dart';
import '../utils/query.dart';

part 'collection.dart';
part 'document.dart';
part 'instance.dart';
part 'query.dart';
part 'reference.dart';

typedef InAppDocument = Map<String, Object?>;
typedef InAppValue = Object?;

class InAppDocumentSnapshot {
  final String path;
  final InAppDocument? _doc;

  InAppDocument? get data => _doc;

  bool get exists => _doc != null && _doc!.isNotEmpty;

  String get id => path.split("/").where((i) => i.isNotEmpty).last;

  const InAppDocumentSnapshot(
    this.path,
    this._doc,
  );
}

class InAppSetOptions {
  final bool merge;

  const InAppSetOptions({
    this.merge = false,
  });
}

class InAppQuerySnapshot {
  final String path;
  final List<InAppDocumentSnapshot> docs;
  final List<InAppDocumentChange> docChanges;

  bool get exists => docs.isNotEmpty;

  const InAppQuerySnapshot(
    this.path,
    this.docs, [
    this.docChanges = const [],
  ]);
}

class InAppDocumentChange {
  final InAppDocumentSnapshot doc;

  const InAppDocumentChange({
    required this.doc,
  });
}
