part of 'database.dart';

abstract class InAppSnapshot {
  const InAppSnapshot();
}

class InAppQuerySnapshot extends InAppSnapshot {
  final String id;
  final List<InAppDocumentSnapshot> docs;
  final List<InAppDocumentChangeSnapshot> docChanges;

  bool get exists => docs.isNotEmpty;

  const InAppQuerySnapshot(
    this.id, [
    this.docs = const [],
    this.docChanges = const [],
  ]);

  @override
  String toString() {
    return "InAppQuerySnapshot(id: $id, docs: $docs, docChanges: $docChanges)";
  }
}

class InAppCounterSnapshot extends InAppSnapshot {
  final String id;
  final int docs;
  final int docChanges;

  bool get exists => docs > 0;

  const InAppCounterSnapshot(
    this.id, [
    this.docs = 0,
    this.docChanges = 0,
  ]);

  @override
  String toString() {
    return "InAppCounterSnapshot(id: $id, docs: $docs, docChanges: $docChanges)";
  }
}

class InAppDocumentChangeSnapshot extends InAppSnapshot {
  final InAppDocumentSnapshot doc;

  const InAppDocumentChangeSnapshot({
    required this.doc,
  });

  @override
  String toString() {
    return "InAppDocumentChange(doc: $doc)";
  }
}

class InAppDocumentSnapshot extends InAppSnapshot {
  final String id;
  final InAppDocument? _doc;

  InAppDocument? get data => _doc;

  bool get exists => _doc != null && _doc!.isNotEmpty;

  const InAppDocumentSnapshot(
    this.id, [
    this._doc,
  ]);

  InAppDocumentSnapshot copy({
    String? id,
    InAppDocument? doc,
  }) {
    return InAppDocumentSnapshot(id ?? this.id, doc ?? _doc);
  }

  @override
  String toString() {
    return "InAppDocumentSnapshot(id: $id, doc: $_doc)";
  }
}

class InAppErrorSnapshot extends InAppSnapshot {
  final String message;

  const InAppErrorSnapshot(this.message);

  @override
  String toString() {
    return "InAppUnknownSnapshot(error: $message)";
  }
}

class InAppUnknownSnapshot extends InAppSnapshot {
  final String error;

  const InAppUnknownSnapshot(this.error);

  @override
  String toString() {
    return "InAppFailureSnapshot(error: $error)";
  }
}
